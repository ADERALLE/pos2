-- ============================================================
-- REDO / REMAKE — Migration additive
-- À exécuter APRÈS inventory_migration.sql et inventory_threshold_migration.sql
-- ============================================================

-- ── 1. Colonne redo_count sur order_items ────────────────────
-- Nombre de fois que cet item a dû être refait (café cramé, verre renversé…).
-- La déduction de stock lors du markDone utilisera (quantity + redo_count).
-- Le total de l'ordre reste inchangé (remplacement, pas consommation facturée).

ALTER TABLE public.order_items
  ADD COLUMN IF NOT EXISTS redo_count SMALLINT NOT NULL DEFAULT 0 CHECK (redo_count >= 0);

-- ── 2. Mettre à jour deduct_order_stock pour tenir compte de redo_count ──────
-- Remplace la version de inventory_migration.sql.

CREATE OR REPLACE FUNCTION deduct_order_stock(
  p_order_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
  v_shop_id   UUID;
  v_shift_id  UUID;
  v_item      RECORD;
  v_new_stock NUMERIC;
BEGIN
  -- IDEMPOTENCY GUARD
  IF EXISTS (
    SELECT 1 FROM inventory_transactions
    WHERE order_id = p_order_id AND type = 'sale'
  ) THEN
    RETURN true;
  END IF;

  SELECT shop_id, shift_id
  INTO v_shop_id, v_shift_id
  FROM orders
  WHERE id = p_order_id;

  FOR v_item IN
    SELECT
      ir.inventory_item_id,
      SUM(ir.usage_value * (oi.quantity + oi.redo_count)) AS total_deduction
    FROM order_items oi
    JOIN inventory_recipes ir ON ir.menu_item_id = oi.menu_item_id
    WHERE oi.order_id = p_order_id
      AND ir.shop_id = v_shop_id
    GROUP BY ir.inventory_item_id
  LOOP
    UPDATE inventory_items
    SET current_stock = GREATEST(current_stock - v_item.total_deduction, 0)
    WHERE id = v_item.inventory_item_id
    RETURNING current_stock INTO v_new_stock;

    INSERT INTO inventory_transactions
      (shop_id, inventory_item_id, order_id, shift_id, type, amount)
    VALUES
      (v_shop_id, v_item.inventory_item_id, p_order_id, v_shift_id, 'sale', -v_item.total_deduction);

    -- ── Threshold notification ──────────────────────────────
    IF EXISTS (
      SELECT 1 FROM inventory_items
      WHERE id = v_item.inventory_item_id
        AND low_stock_threshold IS NOT NULL
        AND v_new_stock <= low_stock_threshold
    ) THEN
      IF NOT EXISTS (
        SELECT 1 FROM notifications
        WHERE shop_id = v_shop_id
          AND title = 'low_stock'
          AND body LIKE '%' || v_item.inventory_item_id::TEXT || '%'
          AND created_at > now() - INTERVAL '24 hours'
      ) THEN
        INSERT INTO notifications (shop_id, title, body)
        SELECT
          v_shop_id,
          'low_stock',
          ii.label || '|' || ii.id::TEXT || '|' || v_new_stock::TEXT || '|' || ii.unit_type
        FROM inventory_items ii
        WHERE ii.id = v_item.inventory_item_id;
      END IF;
    END IF;

  END LOOP;

  RETURN true;
END;
$$;

-- ── 3. RPC redo_order_item_stock ─────────────────────────────────────────────
-- Appelée quand un item est marqué à refaire sur un ordre déjà DONE
-- (stock déjà déduit). Incrémente redo_count et déduit l'équivalent stock.
-- Idempotente : passe p_prev_redo_count pour éviter la double-déduction.
-- Si l'ordre n'est pas encore done, seul redo_count est mis à jour ;
-- la déduction supplémentaire sera faite lors du prochain deduct_order_stock.

CREATE OR REPLACE FUNCTION redo_order_item_stock(
  p_order_item_id  UUID,
  p_prev_redo_count SMALLINT  -- valeur AVANT l'incrémentation côté Flutter
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
  v_shop_id   UUID;
  v_shift_id  UUID;
  v_order_id  UUID;
  v_done      BOOLEAN;
  v_item      RECORD;
BEGIN
  -- Récupérer le contexte
  SELECT o.id, o.shop_id, o.shift_id, (o.status = 'done')
  INTO v_order_id, v_shop_id, v_shift_id, v_done
  FROM order_items oi
  JOIN orders o ON o.id = oi.order_id
  WHERE oi.id = p_order_item_id;

  -- Incrémenter redo_count — idempotent : on ne change que si la valeur actuelle
  -- correspond exactement à ce que Flutter nous a envoyé.
  -- Si redo_count a déjà été incrémenté (retry réseau), la UPDATE touche 0 lignes.
  UPDATE order_items
  SET redo_count = redo_count + 1
  WHERE id = p_order_item_id
    AND redo_count = p_prev_redo_count;

  -- Si aucune ligne touchée → idempotency : quelqu'un a déjà incrémenté, on sort.
  IF NOT FOUND THEN
    RETURN;
  END IF;

  -- Si l'ordre est déjà done → déduire 1 unité supplémentaire (la quantité du redo)
  -- L'idempotency guard : on ne déduit que si redo_count ACTUEL = p_prev_redo_count + 1
  IF v_done THEN
    FOR v_item IN
      SELECT
        ir.inventory_item_id,
        ir.usage_value AS usage_per_unit
      FROM order_items oi
      JOIN inventory_recipes ir ON ir.menu_item_id = oi.menu_item_id
      WHERE oi.id = p_order_item_id
        AND ir.shop_id = v_shop_id
    LOOP
      UPDATE inventory_items
      SET current_stock = GREATEST(current_stock - v_item.usage_per_unit, 0)
      WHERE id = v_item.inventory_item_id;

      INSERT INTO inventory_transactions
        (shop_id, inventory_item_id, order_id, shift_id, type, amount)
      VALUES
        (v_shop_id, v_item.inventory_item_id, v_order_id, v_shift_id, 'sale', -v_item.usage_per_unit);
    END LOOP;
  END IF;
END;
$$;
