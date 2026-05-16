-- ============================================================
-- INVENTORY THRESHOLD — Migration additive
-- À exécuter APRÈS inventory_migration.sql
-- ============================================================

-- ── 1. Ajouter la colonne threshold ─────────────────────────
ALTER TABLE public.inventory_items
  ADD COLUMN IF NOT EXISTS low_stock_threshold NUMERIC NULL;

-- ── 2. RPC deduct_order_stock — mise à jour ──────────────────
-- Après chaque déduction, si current_stock <= low_stock_threshold
-- et qu'aucune notification low_stock n'existe déjà pour cet item
-- dans les dernières 24h, on insère une notification dans la table
-- notifications du shop.

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
      SUM(ir.usage_value * oi.quantity) AS total_deduction
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
    -- Déclenche si : threshold défini ET stock ≤ threshold
    -- ET pas de notification low_stock déjà envoyée dans les 24h pour cet item
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
