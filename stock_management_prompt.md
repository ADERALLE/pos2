This is an incredibly sharp and professional architectural review. You caught exactly the kind of edge cases that turn into midnight debugging sessions—especially the lack of an idempotency guard on RPC 2 and the missing combo-unpacking step in RPC 1. Normalizing the volume to strictly `ml` is also a massive headache saved.

Here is the **Version 2 (V2)** of the technical specification prompt, incorporating every single point from your assessment to make it 100% production-ready.

---

### **Technical Specification: Predictive Inventory Management System (V2)**

**Objective:**
Extend the existing POS database schema to support a predictive, unit-agnostic inventory management system using Supabase PostgreSQL. The system uses strict base units (`ml`, `g`, `unit`) to avoid conversion bugs. Stock deduction is executed strictly via **Manual RPC calls** (no triggers) with built-in idempotency to prevent double-deduction during network retries.

#### **1. Database Schema Additions (Strict & Normalized)**

Create the following tables. Note the addition of `shop_id` for row-level security (RLS) scoping and `UNIQUE` constraints to prevent silent duplicates.

* **`inventory_items`**
* `id` (UUID, PK)
* `shop_id` (UUID, FK to `shops`)
* `label` (TEXT)
* `unit_type` (TEXT) — *Check constraint: `IN ('unit', 'g', 'ml')` STRICTLY NORMALIZED (do not use 'l' or 'kg').*
* `current_stock` (NUMERIC)
* `stop_orders_on_empty` (BOOLEAN) — *Default `false`.*
* `created_at` (TIMESTAMPTZ)


* **`inventory_recipes`**
* `id` (UUID, PK)
* `shop_id` (UUID, FK to `shops`) — *Crucial for cross-shop queries and RLS.*
* `menu_item_id` (UUID, FK to `menu_items`)
* `inventory_item_id` (UUID, FK to `inventory_items`)
* `usage_value` (NUMERIC) — *Base unit deduction per 1 qty sold.*
* **Constraint:** `UNIQUE(menu_item_id, inventory_item_id)` to prevent overlapping deductions.


* **`inventory_transactions`**
* `id` (UUID, PK)
* `inventory_item_id` (UUID, FK to `inventory_items`)
* `order_id` (UUID, FK to `orders`, Nullable)
* `shift_id` (UUID, FK to `shifts`, Nullable)
* `type` (TEXT) — *Check constraint: `IN ('sale', 'refill', 'waste', 'correction')*`
* `amount` (NUMERIC) — *Positive for refills, negative for sales/waste.*
* `created_at` (TIMESTAMPTZ)



---

#### **2. Supabase RPCs (Manual Execution via Client)**

**RPC 1: `check_stock_availability(p_target_id UUID, p_is_combo BOOLEAN, p_shop_id UUID, p_requested_qty NUMERIC)**`

* **Purpose:** Called by the frontend to validate cart additions.
* **Combo Logic:** If `p_is_combo` is true, unpack `p_target_id` via `combo_menu_items` to get the base `menu_item_id`s. Otherwise, treat `p_target_id` as the `menu_item_id`.
* **Logic:**
1. Scope the query strictly to `p_shop_id`.
2. Check if the target(s) exist in `inventory_recipes`. If no, return `true`.
3. For linked `inventory_items` where `stop_orders_on_empty` is `true`, calculate **Predicted Available Stock**:
   `Available = current_stock - Pending_Deductions`
   *(Pending_Deductions = sum of `usage_value * order_items.quantity` for orders where `status = 'pending'` and `shop_id = p_shop_id`)*
4. Ensure explicit type casting when checking: `IF (Available - (p_requested_qty::numeric * usage_value)) < 0 THEN RETURN false;`



**RPC 2: `deduct_order_stock(p_order_id UUID)**`

* **Purpose:** Called explicitly by the frontend *only* when `orders.status` transitions to `'completed'`.
* **Idempotency Guard (CRITICAL):**
* `IF EXISTS (SELECT 1 FROM inventory_transactions WHERE order_id = p_order_id AND type = 'sale') THEN RETURN true; END IF;` (Skip silently to handle network retries gracefully).


* **Logic:**
1. Fetch `order_items` for `p_order_id`. Unpack combo items via `combo_menu_items`.
2. Multiply quantities by recipe `usage_value`.
3. Subtract from `inventory_items.current_stock`.
4. Insert records into `inventory_transactions` (`type = 'sale'`).



**RPC 3: `manual_stock_adjustment(p_inventory_item_id UUID, p_shift_id UUID, p_type TEXT, p_amount NUMERIC)**`

* **Validation Check:** Add explicit RPC-level error raising: `IF p_type NOT IN ('refill', 'waste', 'correction') THEN RAISE EXCEPTION 'Invalid transaction type'; END IF;`
* **Logic:** Add/subtract `p_amount` from `current_stock` and insert the transaction row linked to `p_shift_id` (leaving `order_id` null).

---

#### **3. Shift Reporting Logic**

Ensure the RPC or API endpoint fetching shift usage utilizes parameterized queries (no string interpolation) to prevent SQL injection and cache execution plans.

```sql
SELECT 
    i.label, i.unit_type,
    SUM(ABS(t.amount)) FILTER (WHERE t.type = 'sale') AS expected_usage,
    SUM(t.amount) FILTER (WHERE t.type = 'refill') AS manual_refills,
    SUM(t.amount) FILTER (WHERE t.type IN ('waste', 'correction')) AS adjustments
FROM inventory_transactions t
JOIN inventory_items i ON t.inventory_item_id = i.id
LEFT JOIN orders o ON t.order_id = o.id
WHERE t.shift_id = $1 OR o.shift_id = $1
GROUP BY i.id, i.label, i.unit_type;

```

---

#### **4. Flutter Client Implementation Directives**

* **Cart Validation:** Call `check_stock_availability` per item *as they are added to the cart*, not just at final checkout.
* **Debouncing:** Implement a debouncer (e.g., 300ms) or local cache on `check_stock_availability` if the menu contains many items with `stop_orders_on_empty = true` to prevent spamming the Supabase instance on rapid cart taps.