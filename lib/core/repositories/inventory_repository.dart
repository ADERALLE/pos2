import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/inventory_item.dart';
import '../models/inventory_recipe.dart';
import '../services/supabase_provider.dart';

part 'inventory_repository.g.dart';

@riverpod
InventoryRepository inventoryRepository(Ref ref) {
  return InventoryRepository(ref.watch(supabaseClientProvider));
}

class InventoryRepository {
  InventoryRepository(this._client);
  final SupabaseClient _client;

  SupabaseClient get client => _client;

  // ── inventory_items ──────────────────────────────────────

  Future<List<InventoryItem>> getInventoryItems(String shopId) async {
    final data = await _client
        .from('inventory_items')
        .select()
        .eq('shop_id', shopId)
        .order('label');
    return data.map((e) => InventoryItem.fromJson(e)).toList();
  }

  Future<InventoryItem> upsertInventoryItem({
    String? id,
    required String shopId,
    required String label,
    required String unitType,
    double currentStock = 0,
    bool stopOrdersOnEmpty = false,
  }) async {
    final data = await _client
        .from('inventory_items')
        .upsert({
          if (id != null) 'id': id,
          'shop_id': shopId,
          'label': label,
          'unit_type': unitType,
          'current_stock': currentStock,
          'stop_orders_on_empty': stopOrdersOnEmpty,
        })
        .select()
        .single();
    return InventoryItem.fromJson(data);
  }

  Future<void> deleteInventoryItem(String id) async {
    await _client.from('inventory_items').delete().eq('id', id);
  }

  // ── inventory_recipes ────────────────────────────────────

  Future<List<InventoryRecipe>> getRecipesForShop(String shopId) async {
    final data = await _client
        .from('inventory_recipes')
        .select()
        .eq('shop_id', shopId);
    return data.map((e) => InventoryRecipe.fromJson(e)).toList();
  }

  Future<List<InventoryRecipe>> getRecipesForMenuItem(String menuItemId) async {
    final data = await _client
        .from('inventory_recipes')
        .select()
        .eq('menu_item_id', menuItemId);
    return data.map((e) => InventoryRecipe.fromJson(e)).toList();
  }

  Future<InventoryRecipe> upsertRecipe({
    String? id,
    required String shopId,
    required String menuItemId,
    required String inventoryItemId,
    required double usageValue,
  }) async {
    final data = await _client
        .from('inventory_recipes')
        .upsert({
          if (id != null) 'id': id,
          'shop_id': shopId,
          'menu_item_id': menuItemId,
          'inventory_item_id': inventoryItemId,
          'usage_value': usageValue,
        })
        .select()
        .single();
    return InventoryRecipe.fromJson(data);
  }

  Future<void> deleteRecipe(String id) async {
    await _client.from('inventory_recipes').delete().eq('id', id);
  }

  // ── RPCs ─────────────────────────────────────────────────

  /// RPC 1 — vérifie la disponibilité stock avant ajout au panier.
  /// [selectedItemIds] = menu_item_ids sélectionnés dans les choice groups.
  Future<bool> checkStockAvailability({
    required String targetId,
    required bool isCombo,
    required String shopId,
    required double requestedQty,
    required List<String> selectedItemIds,
  }) async {
    final result = await _client.rpc('check_stock_availability', params: {
      'p_target_id': targetId,
      'p_is_combo': isCombo,
      'p_shop_id': shopId,
      'p_requested_qty': requestedQty,
      'p_selected_item_ids': selectedItemIds,
    });
    return result as bool;
  }

  /// RPC 2 — déduit le stock quand une commande passe à "done". Idempotente.
  Future<bool> deductOrderStock(String orderId) async {
    final result = await _client.rpc('deduct_order_stock', params: {
      'p_order_id': orderId,
    });
    return result as bool;
  }

  /// RPC 3 — ajustement manuel du stock (refill / waste / correction).
  /// [type] : 'refill' | 'waste' | 'correction_set' | 'correction_delta'
  /// [amount] : positif pour refill/waste/correction_set ; signé pour correction_delta.
  Future<void> manualStockAdjustment({
    required String inventoryItemId,
    required String shopId,
    required String shiftId,
    required String type,
    required double amount,
  }) async {
    await _client.rpc('manual_stock_adjustment', params: {
      'p_inventory_item_id': inventoryItemId,
      'p_shop_id': shopId,
      'p_shift_id': shiftId,
      'p_type': type,
      'p_amount': amount,
    });
  }
}
