-- ============================================================
-- CANCEL ITEM — Migration additive
-- À exécuter APRÈS redo_migration.sql
-- Permet de marquer un item comme "gaspillé / non remplacé" :
--   • le stock est déjà consommé (inclus dans quantity)
--   • le prix est retiré de la facture (total + subtotal mis à jour)
-- ============================================================

-- ── 1. Colonne cancel_count sur order_items ──────────────────
ALTER TABLE public.order_items
  ADD COLUMN IF NOT EXISTS cancel_count SMALLINT NOT NULL DEFAULT 0
    CHECK (cancel_count >= 0);

-- Garantir que cancel_count ne dépasse jamais quantity
-- (constraint différée pour éviter les erreurs au chargement de migration)
ALTER TABLE public.order_items
  DROP CONSTRAINT IF EXISTS order_items_cancel_not_exceed_quantity;
ALTER TABLE public.order_items
  ADD CONSTRAINT order_items_cancel_not_exceed_quantity
    CHECK (cancel_count <= quantity);

-- ── 2. RPC cancel_order_item ─────────────────────────────────
-- Incrémente cancel_count d'un item et déduit son unit_price
-- du subtotal de l'item ET du total de la commande.
-- Idempotente : p_prev_cancel_count protège contre la double-déduction.
-- Aucune déduction de stock n'est faite ici : le stock du café cramé
-- est déjà comptabilisé dans quantity (et sera déduit à deduct_order_stock).

CREATE OR REPLACE FUNCTION cancel_order_item(
  p_order_item_id    UUID,
  p_prev_cancel_count SMALLINT  -- valeur actuelle côté Flutter avant l'appel
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_unit_price NUMERIC;
  v_quantity   INTEGER;
  v_cancel     SMALLINT;
  v_order_id   UUID;
BEGIN
  SELECT unit_price, quantity, cancel_count, order_id
    INTO v_unit_price, v_quantity, v_cancel, v_order_id
    FROM order_items
   WHERE id = p_order_item_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'order_item % not found', p_order_item_id;
  END IF;

  -- Idempotency : annuler si déjà incrémenté depuis l'envoi Flutter
  IF v_cancel != p_prev_cancel_count THEN
    RAISE EXCEPTION 'cancel_count changed concurrently (expected %, got %)',
      p_prev_cancel_count, v_cancel;
  END IF;

  IF v_cancel >= v_quantity THEN
    RAISE EXCEPTION 'cannot cancel more items than ordered (quantity=%, cancel_count=%)',
      v_quantity, v_cancel;
  END IF;

  -- Incrémenter cancel_count et diminuer le subtotal de l'item
  UPDATE order_items
     SET cancel_count = cancel_count + 1,
         subtotal     = GREATEST(subtotal - v_unit_price, 0)
   WHERE id = p_order_item_id;

  -- Diminuer le total de la commande
  UPDATE orders
     SET total = GREATEST(total - v_unit_price, 0)
   WHERE id = v_order_id;
END;
$$;
