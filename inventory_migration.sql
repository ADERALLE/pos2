-- ============================================================
-- INVENTORY MANAGEMENT — Migration SQL
-- À exécuter dans Supabase SQL Editor
-- Ordre : Tables → Index → RPCs → RLS
-- ============================================================


-- ────────────────────────────────────────────────────────────
-- 1. TABLES
-- ────────────────────────────────────────────────────────────

CREATE TABLE public.inventory_items (
  id                   UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  shop_id              UUID        NOT NULL REFERENCES public.shops(id) ON DELETE CASCADE,
  label                TEXT        NOT NULL,
  unit_type            TEXT        NOT NULL CHECK (unit_type IN ('unit', 'g', 'ml')),
  current_stock        NUMERIC     NOT NULL DEFAULT 0,
  stop_orders_on_empty BOOLEAN     NOT NULL DEFAULT false,
  created_at           TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.inventory_recipes (
  id                  UUID    PRIMARY KEY DEFAULT uuid_generate_v4(),
  shop_id             UUID    NOT NULL REFERENCES public.shops(id) ON DELETE CASCADE,
  menu_item_id        UUID    NOT NULL REFERENCES public.menu_items(id) ON DELETE CASCADE,
  inventory_item_id   UUID    NOT NULL REFERENCES public.inventory_items(id) ON DELETE CASCADE,
  usage_value         NUMERIC NOT NULL CHECK (usage_value > 0),
  UNIQUE (menu_item_id, inventory_item_id)
);

CREATE TABLE public.inventory_transactions (
  id                  UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  shop_id             UUID        NOT NULL REFERENCES public.shops(id) ON DELETE CASCADE,
  inventory_item_id   UUID        NOT NULL REFERENCES public.inventory_items(id) ON DELETE CASCADE,
  order_id            UUID        REFERENCES public.orders(id) ON DELETE SET NULL,
  shift_id            UUID        REFERENCES public.shifts(id) ON DELETE SET NULL,
  type                TEXT        NOT NULL CHECK (type IN ('sale', 'refill', 'waste', 'correction_set', 'correction_delta')),
  amount              NUMERIC     NOT NULL,
  -- Conventions de signe :
  --   sale             → négatif  (ex: -2.5)
  --   refill           → positif  (ex: +10)
  --   waste            → négatif  (ex: -1)
  --   correction_set   → positif  (valeur absolue du nouveau stock, ex: 42)
  --   correction_delta → signé    (ex: -3 perte, +5 retour)
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- ────────────────────────────────────────────────────────────
-- 2. INDEX
-- ────────────────────────────────────────────────────────────

-- Lookup rapide des recettes par item de menu (utilisé dans check_stock + deduct)
CREATE INDEX idx_inventory_recipes_menu_item_id
  ON public.inventory_recipes (menu_item_id);

-- Lookup rapide des transactions par order_id (utilisé dans l'idempotency guard)
CREATE INDEX idx_inventory_transactions_order_id
  ON public.inventory_transactions (order_id);

-- Lookup rapide des transactions par shift_id (utilisé dans le shift reporting)
CREATE INDEX idx_inventory_transactions_shift_id
  ON public.inventory_transactions (shift_id);

-- Lookup rapide des items par shop_id (utilisé dans le Realtime Flutter)
CREATE INDEX idx_inventory_items_shop_id
  ON public.inventory_items (shop_id);


-- ────────────────────────────────────────────────────────────
-- 3. RPCs
-- ────────────────────────────────────────────────────────────

-- ── RPC 1 : check_stock_availability ────────────────────────
-- Appelée par Flutter à chaque ajout au panier.
-- Retourne false si un ingredient bloquant manque de stock prédit.
-- Prend en compte les choice groups : seuls les menu_item_ids sélectionnés
-- sont vérifiés (p_selected_item_ids), pas tous les items du combo.
-- p_extra_pending : usage supplémentaire déjà engagé par le cart Flutter
--   (items en cours d'ajout, pas encore soumis comme orders DB).
--   Format JSONB : { "inventory_item_id_uuid": usage_numeric, ... }

CREATE OR REPLACE FUNCTION check_stock_availability(
  p_target_id         UUID,
  p_is_combo          BOOLEAN,
  p_shop_id           UUID,
  p_requested_qty     NUMERIC,
  p_selected_item_ids UUID[],
  p_extra_pending     JSONB    DEFAULT '{}'
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
  v_inv_item      RECORD;
  v_pending_used  NUMERIC;
  v_cart_used     NUMERIC;
  v_available     NUMERIC;
BEGIN
  -- ── 1. Itérer sur chaque ingrédient bloquant, avec usage agrégé correct ───
  --
  -- Pour un item simple :
  --   usage_per_combo_unit = ir.usage_value  (cmi_qty = 1 implicite)
  -- Pour un combo :
  --   usage_per_combo_unit = SUM(ir.usage_value * cmi.quantity)
  --   groupé par inventory_item, en tenant compte de cmi.quantity
  --   (ex: 2x Orange → 2 × 600g = 1200g par combo commandé)

  FOR v_inv_item IN

    -- ── Cas simple item ───────────────────────────────────────────────────
    SELECT
      ii.id,
      ii.current_stock,
      ir.usage_value AS usage_per_unit
    FROM inventory_recipes ir
    JOIN inventory_items ii ON ii.id = ir.inventory_item_id
    WHERE p_is_combo = false
      AND ir.menu_item_id = p_target_id
      AND ir.shop_id = p_shop_id
      AND ii.stop_orders_on_empty = true

    UNION ALL

    -- ── Cas combo : agréger usage × cmi.quantity par ingredient ──────────
    SELECT
      ii.id,
      ii.current_stock,
      SUM(ir.usage_value * cmi.quantity) AS usage_per_unit
    FROM combo_menu_items cmi
    JOIN inventory_recipes ir
      ON ir.menu_item_id = cmi.menu_item_id
     AND ir.shop_id = p_shop_id
    JOIN inventory_items ii ON ii.id = ir.inventory_item_id
    WHERE p_is_combo = true
      AND cmi.combo_menu_id = p_target_id
      AND (
        cmi.choice_group IS NULL                       -- items fixes toujours inclus
        OR cmi.menu_item_id = ANY(p_selected_item_ids) -- choix sélectionné seulement
      )
      AND ii.stop_orders_on_empty = true
    GROUP BY ii.id, ii.current_stock

  LOOP
    -- ── 2. Déductions déjà engagées en DB (orders pending + inprogress) ───
    -- On inclut redo_count car deduct_order_stock déduit (quantity + redo_count).
    SELECT COALESCE(SUM(ir2.usage_value * (oi.quantity + oi.redo_count)), 0)
    INTO v_pending_used
    FROM order_items oi
    JOIN orders o ON o.id = oi.order_id
    JOIN inventory_recipes ir2 ON ir2.menu_item_id = oi.menu_item_id
    WHERE ir2.inventory_item_id = v_inv_item.id
      AND o.shop_id = p_shop_id
      AND o.status IN ('pending', 'inprogress');

    -- ── 3. Déductions issues du cart Flutter (pas encore en DB) ──────────
    v_cart_used := COALESCE(
      (p_extra_pending ->> v_inv_item.id::TEXT)::NUMERIC,
      0
    );

    v_available := v_inv_item.current_stock - v_pending_used - v_cart_used;

    IF (v_available - (p_requested_qty::NUMERIC * v_inv_item.usage_per_unit)) < 0 THEN
      RETURN false;
    END IF;
  END LOOP;

  RETURN true;
END;
$$;


-- ── RPC 2 : deduct_order_stock ───────────────────────────────
-- Appelée par Flutter uniquement quand une commande passe à "done".
-- Idempotente : safe en cas de retry réseau.
-- Les combos sont déjà aplatis en menu_item_ids individuels par Flutter
-- lors de la création de la commande → aucun dépaquetage nécessaire ici.

CREATE OR REPLACE FUNCTION deduct_order_stock(
  p_order_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
  v_shop_id  UUID;
  v_shift_id UUID;
  v_item     RECORD;
BEGIN
  -- IDEMPOTENCY GUARD : si déjà déduit pour cette commande, sortir silencieusement
  IF EXISTS (
    SELECT 1 FROM inventory_transactions
    WHERE order_id = p_order_id AND type = 'sale'
  ) THEN
    RETURN true;
  END IF;

  -- Récupérer shop_id et shift_id de la commande
  SELECT shop_id, shift_id
  INTO v_shop_id, v_shift_id
  FROM orders
  WHERE id = p_order_id;

  -- Pour chaque order_item → joindre les recettes → déduire et insérer la transaction
  FOR v_item IN
    SELECT
      ir.inventory_item_id,
      SUM(ir.usage_value * oi.quantity) AS total_deduction
    FROM order_items oi
    JOIN inventory_recipes ir ON ir.menu_item_id = oi.menu_item_id
    WHERE oi.order_id = p_order_id
      AND ir.shop_id = v_shop_id
    GROUP BY ir.inventory_item_id
  LOOP
    -- GREATEST(..., 0) : protection contre le stock négatif en cas de race condition
    -- entre deux commandes simultanées (clamp à 0 plutôt qu'une exception)
    UPDATE inventory_items
    SET current_stock = GREATEST(current_stock - v_item.total_deduction, 0)
    WHERE id = v_item.inventory_item_id;

    INSERT INTO inventory_transactions
      (shop_id, inventory_item_id, order_id, shift_id, type, amount)
    VALUES
      (v_shop_id, v_item.inventory_item_id, p_order_id, v_shift_id, 'sale', -v_item.total_deduction);
  END LOOP;

  RETURN true;
END;
$$;


-- ── RPC 3 : manual_stock_adjustment ─────────────────────────
-- Appelée depuis l'UI Settings > Inventaire pour les ajustements manuels.
-- Types acceptés :
--   refill           → réapprovisionnement (p_amount positif)
--   waste            → perte/péremption     (p_amount positif, la RPC applique le signe)
--   correction_set   → reset absolu        (p_amount >= 0, ex: inventaire physique)
--   correction_delta → delta signé         (p_amount signé, ex: -3 ou +2)

CREATE OR REPLACE FUNCTION manual_stock_adjustment(
  p_inventory_item_id UUID,
  p_shop_id           UUID,
  p_shift_id          UUID,
  p_type              TEXT,
  p_amount            NUMERIC
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
  v_transaction_amount NUMERIC;
BEGIN
  -- Validation du type
  IF p_type NOT IN ('refill', 'waste', 'correction_set', 'correction_delta') THEN
    RAISE EXCEPTION 'Invalid transaction type: %. Expected: refill, waste, correction_set, correction_delta', p_type;
  END IF;

  -- Validation de l'amount selon le type
  IF p_type IN ('refill', 'waste') AND p_amount <= 0 THEN
    RAISE EXCEPTION 'Amount must be strictly positive for type %', p_type;
  END IF;

  IF p_type = 'correction_set' AND p_amount < 0 THEN
    RAISE EXCEPTION 'Amount must be >= 0 for correction_set (absolute stock value)';
  END IF;

  IF p_type = 'correction_delta' AND p_amount = 0 THEN
    RAISE EXCEPTION 'Amount cannot be zero for correction_delta';
  END IF;

  -- Mise à jour du stock
  UPDATE inventory_items
  SET current_stock = CASE
    WHEN p_type = 'refill'           THEN current_stock + p_amount
    WHEN p_type = 'waste'            THEN GREATEST(current_stock - p_amount, 0)
    WHEN p_type = 'correction_set'   THEN p_amount
    WHEN p_type = 'correction_delta' THEN GREATEST(current_stock + p_amount, 0)
  END
  WHERE id = p_inventory_item_id
    AND shop_id = p_shop_id;

  -- Calculer le montant à stocker en transaction
  v_transaction_amount := CASE
    WHEN p_type = 'refill'           THEN p_amount
    WHEN p_type = 'waste'            THEN -p_amount
    WHEN p_type = 'correction_set'   THEN p_amount
    WHEN p_type = 'correction_delta' THEN p_amount
  END;

  INSERT INTO inventory_transactions
    (shop_id, inventory_item_id, shift_id, type, amount)
  VALUES (
    p_shop_id,
    p_inventory_item_id,
    p_shift_id,
    p_type,
    v_transaction_amount
  );
END;
$$;


-- ────────────────────────────────────────────────────────────
-- 4. ROW LEVEL SECURITY (RLS)
-- ────────────────────────────────────────────────────────────

ALTER TABLE public.inventory_items         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory_recipes       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory_transactions  ENABLE ROW LEVEL SECURITY;

-- Les policies utilisent auth.uid() via la table staff pour retrouver le shop_id
-- du user connecté. Adapter si votre fonction helper existe déjà (ex: get_my_shop_id()).

-- inventory_items : accès limité au shop du user connecté
CREATE POLICY "shop_isolation" ON public.inventory_items
  FOR ALL
  USING (
    shop_id IN (
      SELECT shop_id FROM public.staff WHERE auth_user_id = auth.uid()
    )
  );

-- inventory_recipes : idem
CREATE POLICY "shop_isolation" ON public.inventory_recipes
  FOR ALL
  USING (
    shop_id IN (
      SELECT shop_id FROM public.staff WHERE auth_user_id = auth.uid()
    )
  );

-- inventory_transactions : idem
CREATE POLICY "shop_isolation" ON public.inventory_transactions
  FOR ALL
  USING (
    shop_id IN (
      SELECT shop_id FROM public.staff WHERE auth_user_id = auth.uid()
    )
  );
