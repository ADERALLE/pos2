# Technical Specification V3: Predictive Inventory Management (Production-Ready)

> **Changelog vs V2:** Choice groups fixes in RPC 1 · Correct order statuses · Negative stock race condition guard · `shop_id` on transactions · `p_shop_id` on RPC 3 · RPC 3 amount validation · Offline-first behavior documented · Realtime subscription · Flutter UI spec · Cache TTL instead of bare debounce · Combo unpacking removed from RPC 2 (already done by Flutter)

---

## 1. Database Schema

### `inventory_items`
```sql
CREATE TABLE public.inventory_items (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  shop_id       UUID NOT NULL REFERENCES public.shops(id),
  label         TEXT NOT NULL,
  unit_type     TEXT NOT NULL CHECK (unit_type IN ('unit', 'g', 'ml')),
  current_stock NUMERIC NOT NULL DEFAULT 0,
  stop_orders_on_empty BOOLEAN NOT NULL DEFAULT false,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### `inventory_recipes`
```sql
CREATE TABLE public.inventory_recipes (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  shop_id             UUID NOT NULL REFERENCES public.shops(id),
  menu_item_id        UUID NOT NULL REFERENCES public.menu_items(id),
  inventory_item_id   UUID NOT NULL REFERENCES public.inventory_items(id),
  usage_value         NUMERIC NOT NULL CHECK (usage_value > 0),
  UNIQUE (menu_item_id, inventory_item_id)
);
```

### `inventory_transactions`
```sql
CREATE TABLE public.inventory_transactions (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  shop_id             UUID NOT NULL REFERENCES public.shops(id),  -- ajouté (RLS + reporting)
  inventory_item_id   UUID NOT NULL REFERENCES public.inventory_items(id),
  order_id            UUID REFERENCES public.orders(id),          -- nullable
  shift_id            UUID REFERENCES public.shifts(id),          -- nullable
  type                TEXT NOT NULL CHECK (type IN ('sale', 'refill', 'waste', 'correction')),
  amount              NUMERIC NOT NULL,  -- négatif pour sales/waste, positif pour refill/correction
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

> **Note `stop_orders_on_empty` :** Ce flag est intentionnellement au niveau de `inventory_items`. Si l'ingrédient "Pain" est épuisé, tous les plats qui l'utilisent doivent être bloqués — c'est le comportement attendu. Si un item doit rester commandable même à 0 stock (ex: boisson rare gérée manuellement), laisser ce flag à `false`.

---

## 2. RPCs

### RPC 1 — `check_stock_availability`

**Signature corrigée :**
```sql
CREATE OR REPLACE FUNCTION check_stock_availability(
  p_target_id          UUID,
  p_is_combo           BOOLEAN,
  p_shop_id            UUID,
  p_requested_qty      NUMERIC,
  p_selected_item_ids  UUID[]   -- NOUVEAU : ids des menu_items choisis dans les choice groups
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
  v_menu_item_ids UUID[];
  v_inv_item      RECORD;
  v_pending_used  NUMERIC;
  v_available     NUMERIC;
BEGIN
  -- 1. Résoudre les menu_item_ids à vérifier
  IF p_is_combo THEN
    SELECT ARRAY_AGG(DISTINCT cmi.menu_item_id)
    INTO v_menu_item_ids
    FROM combo_menu_items cmi
    WHERE cmi.combo_menu_id = p_target_id
      AND (
        cmi.choice_group IS NULL                              -- items fixes toujours inclus
        OR cmi.menu_item_id = ANY(p_selected_item_ids)        -- items de choice group sélectionnés seulement
      );
  ELSE
    v_menu_item_ids := ARRAY[p_target_id];
  END IF;

  -- 2. Si aucune recette n'existe → pas de contrainte stock → disponible
  IF NOT EXISTS (
    SELECT 1 FROM inventory_recipes ir
    WHERE ir.menu_item_id = ANY(v_menu_item_ids)
      AND ir.shop_id = p_shop_id
  ) THEN
    RETURN true;
  END IF;

  -- 3. Pour chaque inventory_item bloquant, vérifier le stock prédit
  FOR v_inv_item IN
    SELECT
      ii.id,
      ii.current_stock,
      ir.usage_value
    FROM inventory_recipes ir
    JOIN inventory_items ii ON ii.id = ir.inventory_item_id
    WHERE ir.menu_item_id = ANY(v_menu_item_ids)
      AND ir.shop_id = p_shop_id
      AND ii.stop_orders_on_empty = true
  LOOP
    -- Déductions en cours (commandes pending + inprogress, pas encore done)
    SELECT COALESCE(SUM(ir2.usage_value * oi.quantity), 0)
    INTO v_pending_used
    FROM order_items oi
    JOIN orders o ON o.id = oi.order_id
    JOIN inventory_recipes ir2 ON ir2.menu_item_id = oi.menu_item_id
    WHERE ir2.inventory_item_id = v_inv_item.id
      AND o.shop_id = p_shop_id
      AND o.status IN ('pending', 'inprogress');  -- les deux statuts actifs

    v_available := v_inv_item.current_stock - v_pending_used;

    IF (v_available - (p_requested_qty::NUMERIC * v_inv_item.usage_value)) < 0 THEN
      RETURN false;
    END IF;
  END LOOP;

  RETURN true;
END;
$$;
```

---

### RPC 2 — `deduct_order_stock`

**Signature :**
```sql
CREATE OR REPLACE FUNCTION deduct_order_stock(
  p_order_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
  v_shop_id UUID;
  v_shift_id UUID;
  v_item    RECORD;
BEGIN
  -- IDEMPOTENCY GUARD : si déjà déduit, sortir silencieusement
  IF EXISTS (
    SELECT 1 FROM inventory_transactions
    WHERE order_id = p_order_id AND type = 'sale'
  ) THEN
    RETURN true;
  END IF;

  -- Récupérer shop_id et shift_id de la commande
  SELECT shop_id, shift_id INTO v_shop_id, v_shift_id
  FROM orders WHERE id = p_order_id;

  -- Pour chaque order_item → chercher ses recettes → déduire
  -- Note: les combos sont déjà aplatis en menu_item_id individuels
  -- par Flutter lors de la création de la commande. Pas de dépaquetage nécessaire ici.
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
    -- Déduction avec protection contre le stock négatif (race condition)
    UPDATE inventory_items
    SET current_stock = GREATEST(current_stock - v_item.total_deduction, 0)
    WHERE id = v_item.inventory_item_id;
    -- Note: GREATEST(…, 0) évite le stock négatif. En cas de race condition
    -- entre deux commandes simultanées, on clamp à 0 plutôt que d'échouer.
    -- Si la règle métier exige une erreur plutôt qu'un clamp, remplacer par
    -- un CHECK (current_stock >= 0) et gérer l'exception côté client.

    INSERT INTO inventory_transactions
      (shop_id, inventory_item_id, order_id, shift_id, type, amount)
    VALUES
      (v_shop_id, v_item.inventory_item_id, p_order_id, v_shift_id, 'sale', -v_item.total_deduction);
  END LOOP;

  RETURN true;
END;
$$;
```

---

### RPC 3 — `manual_stock_adjustment`

**Signature corrigée :**
```sql
CREATE OR REPLACE FUNCTION manual_stock_adjustment(
  p_inventory_item_id UUID,
  p_shop_id           UUID,   -- AJOUTÉ pour RLS
  p_shift_id          UUID,
  p_type              TEXT,
  p_amount            NUMERIC
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
  -- Validation du type
  IF p_type NOT IN ('refill', 'waste', 'correction') THEN
    RAISE EXCEPTION 'Invalid transaction type: %. Expected: refill, waste, correction', p_type;
  END IF;

  -- Validation de l'amount
  IF p_amount = 0 THEN
    RAISE EXCEPTION 'Amount cannot be zero';
  END IF;

  -- Convention: le caller passe toujours un amount positif.
  -- La RPC applique le signe selon le type.
  UPDATE inventory_items
  SET current_stock = CASE
    WHEN p_type = 'refill'     THEN current_stock + p_amount
    WHEN p_type = 'waste'      THEN GREATEST(current_stock - p_amount, 0)
    WHEN p_type = 'correction' THEN p_amount  -- correction = set absolu
  END
  WHERE id = p_inventory_item_id
    AND shop_id = p_shop_id;  -- RLS guard

  INSERT INTO inventory_transactions
    (shop_id, inventory_item_id, shift_id, type, amount)
  VALUES (
    p_shop_id,
    p_inventory_item_id,
    p_shift_id,
    p_type,
    CASE
      WHEN p_type = 'refill'     THEN p_amount
      WHEN p_type = 'waste'      THEN -p_amount
      WHEN p_type = 'correction' THEN p_amount
    END
  );
END;
$$;
```

---

## 3. Shift Reporting Query

```sql
SELECT
  i.label,
  i.unit_type,
  SUM(ABS(t.amount)) FILTER (WHERE t.type = 'sale')                    AS expected_usage,
  SUM(t.amount)      FILTER (WHERE t.type = 'refill')                  AS manual_refills,
  SUM(t.amount)      FILTER (WHERE t.type IN ('waste', 'correction'))  AS adjustments
FROM inventory_transactions t
JOIN inventory_items i ON t.inventory_item_id = i.id
WHERE t.shift_id = $1                      -- transactions manuelles du shift
  OR (t.order_id IN (
    SELECT id FROM orders WHERE shift_id = $1
  ))                                        -- transactions issues des commandes du shift
GROUP BY i.id, i.label, i.unit_type;
```

---

## 4. Flutter Client Implementation

### 4.1 Nouveau modèle `InventoryItem`

```dart
@freezed
class InventoryItem with _$InventoryItem {
  const factory InventoryItem({
    required String id,
    required String shopId,
    required String label,
    required String unitType,      // 'unit' | 'g' | 'ml'
    required double currentStock,
    required bool stopOrdersOnEmpty,
    required DateTime createdAt,
  }) = _InventoryItem;

  factory InventoryItem.fromJson(Map<String, dynamic> json) =>
      _$InventoryItemFromJson(json);
}
```

### 4.2 `InventoryRepository`

```dart
class InventoryRepository {
  Future<bool> checkStockAvailability({
    required String targetId,
    required bool isCombo,
    required String shopId,
    required double requestedQty,
    required List<String> selectedItemIds,  // choice group selections
  });

  Future<void> deductOrderStock(String orderId);

  Future<void> manualStockAdjustment({
    required String inventoryItemId,
    required String shopId,
    required String shiftId,
    required String type,   // 'refill' | 'waste' | 'correction'
    required double amount, // toujours positif, la RPC applique le signe
  });

  Future<List<InventoryItem>> getInventoryItems(String shopId);
  Future<void> upsertInventoryItem(InventoryItem item);
  Future<void> deleteInventoryItem(String id);

  // CRUD inventory_recipes
  Future<List<InventoryRecipe>> getRecipes(String menuItemId);
  Future<void> upsertRecipe(InventoryRecipe recipe);
  Future<void> deleteRecipe(String id);
}
```

### 4.3 Stock check dans le Cart — avec cache TTL

```dart
// Dans CartNotifier ou un provider dédié
final _stockCache = <String, ({bool available, DateTime cachedAt})>{};
const _cacheTtl = Duration(seconds: 5);

Future<bool> checkStock(CartItem item) async {
  // Offline → skip check, laisser ajouter (optimiste)
  if (!ref.read(isOnlineProvider)) return true;

  final cacheKey = '${item.cartKey}_${item.quantity}';
  final cached = _stockCache[cacheKey];
  if (cached != null && DateTime.now().difference(cached.cachedAt) < _cacheTtl) {
    return cached.available;
  }

  final result = await ref.read(inventoryRepositoryProvider).checkStockAvailability(
    targetId: item.isCombo ? item.comboMenu!.id : item.menuItem!.id,
    isCombo: item.isCombo,
    shopId: shopId,
    requestedQty: item.quantity.toDouble(),
    selectedItemIds: item.selectedChoices.values.toList(),  // fix choice groups
  );

  _stockCache[cacheKey] = (available: result, cachedAt: DateTime.now());
  return result;
}
```

> Le cache TTL à 5s est par clé `(cartKey + quantity)`. Ajouter la même quantité du même item dans les 5s suivantes utilise le cache. Au-delà, on re-vérifie. Invalider tout le cache après un appel `deductOrderStock`.

### 4.4 Déclenchement de RPC 2

RPC 2 doit être appelé **uniquement dans `markDone`**, après que le statut est passé à `done` :

```dart
// Dans order_viewmodel.dart → markDone()
Future<void> markDone(String orderId, String shopId, { required PaymentResult payment }) async {
  await ref.read(orderRepositoryProvider).updateStatus(
    orderId: orderId,
    status: OrderStatus.done,
    paymentMethod: payment.paymentMethod,
    cashAmount: payment.cashAmount,
    cardAmount: payment.cardAmount,
    tip: payment.tip,
  );

  // Déduire le stock — idempotent, safe en cas de retry
  await ref.read(inventoryRepositoryProvider).deductOrderStock(orderId);

  await refresh(shopId);
  ref.invalidate(shiftOrdersProvider);
  ref.invalidate(shopOrderHistoryProvider(shopId));
}
```

> **Offline :** si la commande est créée offline via `OfflineQueueService`, le `markDone` sera rejoué lors de la sync. `deductOrderStock` sera alors appelé après la sync — l'idempotency guard garantit qu'une double exécution reste sans effet.

### 4.5 Realtime sur `inventory_items`

Même pattern que les `ShiftOrders` :

```dart
// Dans un InventoryNotifier
void _startRealtime(String shopId) {
  _realtimeSub?.cancel();
  try {
    final stream = supabase
      .from('inventory_items')
      .stream(primaryKey: ['id'])
      .eq('shop_id', shopId);

    _realtimeSub = stream
      .handleError((_) {})
      .listen((_) => refresh(shopId));
  } catch (_) {}
}
```

Cela permet que si caissier A vend le dernier stock, les autres appareils voient l'item se griser **en temps réel** sans recharger.

### 4.6 Affichage "rupture de stock" sur la grille

Dans `new_order_page.dart`, wrap chaque item tile :

```dart
// Griser l'item + badge "Épuisé" si stop_orders_on_empty = true et currentStock = 0
final isOutOfStock = inventoryItems
  .where((i) => i.stopOrdersOnEmpty && i.currentStock <= 0)
  .any((i) => /* linked via inventory_recipes à ce menu_item_id */);
```

Visuellement : opacité 0.4 + badge rouge "Épuisé" en overlay. L'item n'est pas cliquable.

---

## 5. UI — Settings > Inventaire

Nouveau tile dans Settings (section "Management") → route `/settings/inventory` :

```
/settings/inventory
  → Liste des inventory_items (label, unit_type, current_stock, stop_orders_on_empty)
  → FAB pour créer un item
  → Tap sur un item → /settings/inventory/:id
      → Modifier label / unit_type / stop_orders_on_empty
      → Section "Recettes liées" : list des menu_items avec usage_value
          → Ajouter/modifier/supprimer un lien menu_item ↔ inventory_item
      → Bouton "Ajustement manuel" → bottom sheet
          → Type : Refill / Waste / Correction
          → Montant (toujours positif)
          → Confirmation → appel RPC 3

/shift-summary (déjà existant)
  → Ajouter section ou tab "Stock consommé" avec la Shift Reporting Query
```

---

## 6. Récapitulatif des décisions de conception

| Décision | Choix retenu | Raison |
|---|---|---|
| Stock négatif | `GREATEST(stock - déduction, 0)` | Évite les exceptions en prod, acceptable pour un POS |
| Race condition | Pas de `SELECT FOR UPDATE` | Trop de contention sur un POS rapide ; `GREATEST` suffit |
| Offline + stock check | Skip le check si offline | UX > cohérence stricte ; l'idempotency guard protège la déduction |
| Debounce vs cache | Cache TTL 5s par clé | Plus efficace qu'un debounce sur des taps rapides différents |
| `stop_orders_on_empty` | Niveau `inventory_items` | Simple et correct pour le cas d'usage POS |
| Combo unpack dans RPC 2 | Non nécessaire | Flutter aplatit déjà les combos en `order_items` individuels |
| Trigger de RPC 2 | `markDone()` uniquement | Correspond exactement à `OrderStatus.done` |
