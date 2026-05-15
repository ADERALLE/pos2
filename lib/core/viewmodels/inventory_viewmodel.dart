import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/inventory_item.dart';
import '../models/inventory_recipe.dart';
import '../repositories/inventory_repository.dart';

part 'inventory_viewmodel.g.dart';

bool _isNetworkError(Object e) =>
    e is SocketException ||
    e.toString().contains('ClientException') ||
    e.toString().contains('Failed host lookup');

// ── Inventory Items (with Realtime) ──────────────────────────────────────────

@Riverpod(keepAlive: true)
class InventoryItemList extends _$InventoryItemList {
  StreamSubscription<dynamic>? _realtimeSub;

  @override
  Future<List<InventoryItem>> build(String shopId) async {
    ref.onDispose(() => _realtimeSub?.cancel());
    _startRealtime(shopId);
    try {
      return await ref.read(inventoryRepositoryProvider).getInventoryItems(shopId);
    } catch (e) {
      if (_isNetworkError(e)) return state.valueOrNull ?? [];
      rethrow;
    }
  }

  void _startRealtime(String shopId) {
    _realtimeSub?.cancel();
    try {
      final stream = ref
          .read(inventoryRepositoryProvider)
          .client
          .from('inventory_items')
          .stream(primaryKey: ['id']).eq('shop_id', shopId);
      _realtimeSub = stream.handleError((_) {}).listen((_) => refresh(shopId));
    } catch (_) {}
  }

  Future<void> refresh(String shopId) async {
    if (!ref.mounted) return;
    try {
      final items =
          await ref.read(inventoryRepositoryProvider).getInventoryItems(shopId);
      if (!ref.mounted) return;
      state = AsyncData(items);
    } catch (e) {
      if (_isNetworkError(e)) return;
    }
  }

  Future<void> create({
    required String shopId,
    required String label,
    required String unitType,
    double currentStock = 0,
    bool stopOrdersOnEmpty = false,
  }) async {
    await ref.read(inventoryRepositoryProvider).upsertInventoryItem(
          shopId: shopId,
          label: label,
          unitType: unitType,
          currentStock: currentStock,
          stopOrdersOnEmpty: stopOrdersOnEmpty,
        );
    await refresh(shopId);
  }

  Future<void> update(InventoryItem item) async {
    await ref.read(inventoryRepositoryProvider).upsertInventoryItem(
          id: item.id,
          shopId: item.shopId,
          label: item.label,
          unitType: item.unitType,
          currentStock: item.currentStock,
          stopOrdersOnEmpty: item.stopOrdersOnEmpty,
        );
    await refresh(item.shopId);
  }

  Future<void> delete(String id, String shopId) async {
    await ref.read(inventoryRepositoryProvider).deleteInventoryItem(id);
    await refresh(shopId);
  }
}

// ── Inventory Recipes ─────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
class InventoryRecipeList extends _$InventoryRecipeList {
  @override
  Future<List<InventoryRecipe>> build(String shopId) async {
    try {
      return await ref
          .read(inventoryRepositoryProvider)
          .getRecipesForShop(shopId);
    } catch (e) {
      if (_isNetworkError(e)) return state.valueOrNull ?? [];
      rethrow;
    }
  }

  Future<void> refresh(String shopId) async {
    if (!ref.mounted) return;
    try {
      final recipes = await ref
          .read(inventoryRepositoryProvider)
          .getRecipesForShop(shopId);
      if (!ref.mounted) return;
      state = AsyncData(recipes);
    } catch (e) {
      if (_isNetworkError(e)) return;
    }
  }

  Future<void> upsert({
    String? id,
    required String shopId,
    required String menuItemId,
    required String inventoryItemId,
    required double usageValue,
  }) async {
    await ref.read(inventoryRepositoryProvider).upsertRecipe(
          id: id,
          shopId: shopId,
          menuItemId: menuItemId,
          inventoryItemId: inventoryItemId,
          usageValue: usageValue,
        );
    await refresh(shopId);
  }

  Future<void> delete(String id, String shopId) async {
    await ref.read(inventoryRepositoryProvider).deleteRecipe(id);
    await refresh(shopId);
  }
}

// ── Out-of-stock menu_item_ids (computed) ─────────────────────────────────────
// Retourne le Set des menu_item_id bloqués :
//   inventory_item avec stop_orders_on_empty=true && current_stock <= 0
//   → liés via inventory_recipes

@riverpod
Set<String> outOfStockMenuItemIds(Ref ref, String shopId) {
  final items =
      ref.watch(inventoryItemListProvider(shopId)).valueOrNull ?? [];
  final recipes =
      ref.watch(inventoryRecipeListProvider(shopId)).valueOrNull ?? [];

  final blockedInventoryIds = items
      .where((i) => i.stopOrdersOnEmpty && i.currentStock <= 0)
      .map((i) => i.id)
      .toSet();

  return recipes
      .where((r) => blockedInventoryIds.contains(r.inventoryItemId))
      .map((r) => r.menuItemId)
      .toSet();
}

// ── Shift stock usage (reporting) ─────────────────────────────────────────────
// Retourne pour un shift la liste des ingrédients consommés :
// [ {label, unit_type, expected_usage, manual_refills, adjustments} ]

@riverpod
Future<List<Map<String, dynamic>>> shiftStockUsage(
    Ref ref, String shiftId) async {
  final repo = ref.read(inventoryRepositoryProvider);
  try {
    final rows = await repo.client
        .from('inventory_transactions')
        .select(
          'inventory_item_id, type, amount, inventory_items(label, unit_type)')
        .eq('shift_id', shiftId);
    // Aggregate by inventory_item_id
    final Map<String, Map<String, dynamic>> agg = {};
    for (final row in rows as List) {
      final id = row['inventory_item_id'] as String;
      final type = row['type'] as String;
      final amount = (row['amount'] as num).toDouble();
      final item = row['inventory_items'] as Map<String, dynamic>? ?? {};
      agg.putIfAbsent(id, () => {
            'label': item['label'] ?? id,
            'unit_type': item['unit_type'] ?? 'unit',
            'expected_usage': 0.0,
            'manual_refills': 0.0,
            'adjustments': 0.0,
          });
      if (type == 'order_deduction') {
        agg[id]!['expected_usage'] =
            (agg[id]!['expected_usage'] as double) + amount;
      } else if (type == 'refill') {
        agg[id]!['manual_refills'] =
            (agg[id]!['manual_refills'] as double) + amount;
      } else {
        // waste / correction_set / correction_delta → adjustments
        agg[id]!['adjustments'] =
            (agg[id]!['adjustments'] as double) + amount;
      }
    }
    return agg.values.toList();
  } catch (_) {
    return [];
  }
}
