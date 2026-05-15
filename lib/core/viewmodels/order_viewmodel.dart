import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pos_v1/app/shared/payment_dialog.dart';
import 'package:pos_v1/core/appconstants.dart';
import 'package:pos_v1/core/models/cart_item.dart';
import 'package:pos_v1/core/models/combo_menu.dart';
import 'package:pos_v1/core/models/menu_item.dart';
import 'package:pos_v1/core/models/order.dart';
import 'package:pos_v1/core/models/order_item.dart';
import 'package:pos_v1/core/repositories/inventory_repository.dart';
import 'package:pos_v1/core/repositories/order_repository.dart';
import 'package:pos_v1/core/services/connectivity_service.dart';
import 'package:pos_v1/core/services/offline_queue_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'order_viewmodel.g.dart';

const _uuid = Uuid();

bool _isNetworkError(Object e) =>
    e is SocketException ||
        e.toString().contains('ClientException') ||
        e.toString().contains('Failed host lookup') ||
        e.toString().contains('RealtimeSubscribeException') ||
        e.toString().contains('WebSocketChannelException');

// ── active orders (manager) ───────────────────────────────────────────────────

@Riverpod(keepAlive: true)
class ActiveOrders extends _$ActiveOrders {
  @override
  Future<List<Order>> build(String shopId) async {
    try {
      return await ref.read(orderRepositoryProvider).getActiveOrders(shopId);
    } catch (e) {
      if (_isNetworkError(e)) return state.value ?? [];
      rethrow;
    }
  }

  Future<void> refresh(String shopId) async {
    if (!ref.mounted) return;
    try {
      final orders = await ref.read(orderRepositoryProvider).getActiveOrders(shopId);
      if (!ref.mounted) return;
      state = AsyncData(orders);
    } catch (e) {
      if (_isNetworkError(e)) return;
      if (!ref.mounted) return;
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> markDone(
      String orderId,
      String shopId, {
        required PaymentResult payment,
      }) async {
    await ref.read(orderRepositoryProvider).updateStatus(
      orderId: orderId,
      status: OrderStatus.done,
      paymentMethod: payment.paymentMethod,
      cashAmount: payment.cashAmount,
      cardAmount: payment.cardAmount,
      tip: payment.tip,
    );
    // Déduire le stock — idempotent, safe en cas de retry
    try {
      await ref.read(inventoryRepositoryProvider).deductOrderStock(orderId);
    } catch (_) {}
    await refresh(shopId);
    ref.invalidate(shiftOrdersProvider);
    ref.invalidate(shopOrderHistoryProvider(shopId));
  }

  Future<void> cancel(String orderId, String shopId) async {
    await ref.read(orderRepositoryProvider).cancelOrder(orderId);
    await refresh(shopId);
    ref.invalidate(shopOrderHistoryProvider(shopId));
  }
}

// ── order history (manager) ───────────────────────────────────────────────────

@riverpod
class OrderHistory extends _$OrderHistory {
  @override
  Future<List<Order>> build(String shopId) async {
    try {
      return await ref.read(orderRepositoryProvider).getOrderHistory(shopId);
    } catch (e) {
      if (_isNetworkError(e)) return state.value ?? [];
      rethrow;
    }
  }

  Future<void> refresh(String shopId) async {
    if (!ref.mounted) return;
    try {
      final orders = await ref.read(orderRepositoryProvider).getOrderHistory(shopId);
      if (!ref.mounted) return;
      state = AsyncData(orders);
    } catch (e) {
      if (_isNetworkError(e)) return;
      if (!ref.mounted) return;
      state = AsyncError(e, StackTrace.current);
    }
  }
}

// ── cashier order history (paginated) ────────────────────────────────────────

@Riverpod(keepAlive: true)
class MyOrderHistory extends _$MyOrderHistory {
  int _page = 0;
  bool _hasMore = true;

  @override
  Future<List<Order>> build(String cashierId) async {
    _page = 0;
    try {
      final results = await ref.read(orderRepositoryProvider).getMyOrderHistory(cashierId, page: 0);
      _hasMore = results.length == 20;
      return results;
    } catch (e) {
      if (_isNetworkError(e)) return state.value ?? [];
      rethrow;
    }
  }

  Future<void> loadMore(String cashierId) async {
    if (!_hasMore || state.isLoading) return;
    _page++;
    try {
      final more = await ref.read(orderRepositoryProvider).getMyOrderHistory(cashierId, page: _page);
      if (!ref.mounted) return;
      if (more.length < 20) _hasMore = false;
      if (more.isEmpty) return;
      state = AsyncData([...?state.value, ...more]);
    } catch (e) {
      if (_isNetworkError(e)) { _page--; return; }
      rethrow;
    }
  }

  bool get hasMore => _hasMore;
}

// ── shop order history (paginated) ────────────────────────────────────────────

@Riverpod(keepAlive: true)
class ShopOrderHistory extends _$ShopOrderHistory {
  int _page = 0;
  bool _hasMore = true;

  @override
  Future<List<Order>> build(String shopId) async {
    _page = 0;
    try {
      final results = await ref.read(orderRepositoryProvider).getShopOrderHistory(shopId, page: 0);
      _hasMore = results.length == 20;
      return results;
    } catch (e) {
      if (_isNetworkError(e)) return state.value ?? [];
      rethrow;
    }
  }

  Future<void> loadMore(String shopId) async {
    if (!_hasMore || state.isLoading) return;
    _page++;
    try {
      final more = await ref.read(orderRepositoryProvider).getShopOrderHistory(shopId, page: _page);
      if (!ref.mounted) return;
      if (more.length < 20) _hasMore = false;
      if (more.isEmpty) return;
      state = AsyncData([...?state.value, ...more]);
    } catch (e) {
      if (_isNetworkError(e)) { _page--; return; }
      rethrow;
    }
  }

  bool get hasMore => _hasMore;
}

// ── cashier active orders (offline-aware) ─────────────────────────────────────

@Riverpod(keepAlive: true)
class MyActiveOrders extends _$MyActiveOrders {
  @override
  Future<List<Order>> build(String cashierId) async {
    try {
      return await ref.read(orderRepositoryProvider).getMyActiveOrders(cashierId);
    } catch (e) {
      if (_isNetworkError(e)) return state.value ?? [];
      rethrow;
    }
  }

  Future<void> refresh(String cashierId) async {
    if (!ref.mounted) return;
    try {
      final orders = await ref.read(orderRepositoryProvider).getMyActiveOrders(cashierId);
      if (!ref.mounted) return;
      state = AsyncData(orders);
    } catch (e) {
      if (_isNetworkError(e)) return;
      if (!ref.mounted) return;
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> markDone(
      String orderId,
      String cashierId, {
        required PaymentResult payment,
      }) async {
    final online = ref.read(isOnlineProvider);

    if (online) {
      await ref.read(orderRepositoryProvider).updateStatus(
        orderId: orderId,
        status: OrderStatus.done,
        paymentMethod: payment.paymentMethod,
        cashAmount: payment.cashAmount,
        cardAmount: payment.cardAmount,
        tip: payment.tip,
      );
      // Déduire le stock — idempotent, safe en cas de retry
      try {
        await ref.read(inventoryRepositoryProvider).deductOrderStock(orderId);
      } catch (_) {}
      if (!ref.mounted) return;
      await refresh(cashierId);
      ref.invalidate(shiftOrdersProvider);
      ref.invalidate(myOrderHistoryProvider(cashierId));
    } else {
      await OfflineQueueService().enqueueMarkDone({
        'order_id': orderId,
        'cashier_id': cashierId,
        'payment_method': payment.paymentMethod,
        'cash_amount': payment.cashAmount,
        'card_amount': payment.cardAmount,
        'tip': payment.tip,
      });
      // Optimistic: remove from active list immediately
      if (state.hasValue) {
        state = AsyncData(state.value!.where((o) => o.id != orderId).toList());
      }
    }
  }

  Future<void> cancel(String orderId, String cashierId) async {
    final online = ref.read(isOnlineProvider);

    if (online) {
      await ref.read(orderRepositoryProvider).cancelOrder(orderId);
      if (!ref.mounted) return;
      await refresh(cashierId);
      ref.invalidate(shiftOrdersProvider);
      ref.invalidate(myOrderHistoryProvider(cashierId));
    } else {
      await OfflineQueueService().enqueueCancel({'order_id': orderId, 'cashier_id': cashierId});
      if (state.hasValue) {
        state = AsyncData(state.value!.where((o) => o.id != orderId).toList());
      }
    }
  }
}

// ── shift orders — safe realtime ──────────────────────────────────────────────

@Riverpod(keepAlive: true)
class ShiftOrders extends _$ShiftOrders {
  StreamSubscription<dynamic>? _realtimeSub;

  @override
  Future<List<Order>> build(String shiftId) async {
    ref.onDispose(() => _realtimeSub?.cancel());

    if (ref.read(isOnlineProvider)) _startRealtime(shiftId);

    ref.listen<bool>(isOnlineProvider, (_, isNowOnline) {
      if (isNowOnline) {
        _startRealtime(shiftId);
        refresh(shiftId);
      } else {
        _realtimeSub?.cancel();
        _realtimeSub = null;
      }
    });

    try {
      return await ref.read(orderRepositoryProvider).getShiftOrders(shiftId);
    } catch (e) {
      if (_isNetworkError(e)) return state.value ?? [];
      rethrow;
    }
  }

  void _startRealtime(String shiftId) {
    _realtimeSub?.cancel();
    try {
      final stream = ref
          .read(orderRepositoryProvider)
          .client
          .from('orders')
          .stream(primaryKey: ['id']).eq('shift_id', shiftId);

      _realtimeSub = stream
          .handleError((_) {})
          .listen((_) => refresh(shiftId));
    } catch (_) {}
  }

  Future<void> refresh(String shiftId) async {
    if (!ref.mounted) return;
    try {
      final orders = await ref.read(orderRepositoryProvider).getShiftOrders(shiftId);
      if (!ref.mounted) return;
      state = AsyncData(orders);
    } catch (e) {
      if (_isNetworkError(e)) return;
    }
  }
}

// ── editing order ─────────────────────────────────────────────────────────────

/// Holds the active order currently being edited. Null when not in edit mode.
final editingOrderProvider = StateProvider<Order?>((ref) => null);

// ── cart (offline-aware) ──────────────────────────────────────────────────────

@riverpod
class Cart extends _$Cart {
  @override
  List<CartItem> build() => [];

  void addItem(MenuItem item) {
    final key = item.id;
    final existing = state.where((c) => c.cartKey == key).firstOrNull;
    if (existing != null) {
      state = [
        for (final c in state)
          if (c.cartKey == key)
            CartItem(menuItem: c.menuItem, quantity: c.quantity + 1, note: c.note)
          else
            c,
      ];
    } else {
      state = [...state, CartItem(menuItem: item)];
    }
  }

  void addCombo(ComboMenu combo) {
    final key = 'combo_${combo.id}';
    final existing = state.where((c) => c.cartKey == key).firstOrNull;
    if (existing != null) {
      state = [
        for (final c in state)
          if (c.cartKey == key)
            CartItem(comboMenu: c.comboMenu, quantity: c.quantity + 1, note: c.note, selectedChoices: c.selectedChoices)
          else
            c,
      ];
    } else {
      state = [...state, CartItem(comboMenu: combo)];
    }
  }

  void addComboWithChoices(ComboMenu combo, Map<String, String> choices) {
    final item = CartItem(comboMenu: combo, selectedChoices: Map.of(choices));
    final key = item.cartKey;
    final existing = state.where((c) => c.cartKey == key).firstOrNull;
    if (existing != null) {
      state = [
        for (final c in state)
          if (c.cartKey == key)
            CartItem(comboMenu: c.comboMenu, quantity: c.quantity + 1, note: c.note, selectedChoices: c.selectedChoices)
          else
            c,
      ];
    } else {
      state = [...state, item];
    }
  }

  // ── Stock-aware add methods (RPC 1) ────────────────────────────────────────
  // Cache TTL : 5s par clé (targetId + qty + choiceIds).
  // Offline → skip le check et laisse ajouter (optimiste).

  final _stockCache = <String, ({bool available, DateTime cachedAt})>{};
  static const _cacheTtl = Duration(seconds: 5);

  /// Vérifie le stock puis ajoute l'item. Retourne false si bloqué.
  Future<bool> tryAddItem(MenuItem item) async {
    final existingQty = state
        .where((c) => c.cartKey == item.id)
        .fold(0, (s, c) => s + c.quantity);
    final ok = await _checkStock(
      targetId: item.id,
      isCombo: false,
      requestedQty: (existingQty + 1).toDouble(),
      selectedItemIds: [],
    );
    if (ok) addItem(item);
    return ok;
  }

  /// Vérifie le stock puis ajoute le combo sans choices. Retourne false si bloqué.
  Future<bool> tryAddCombo(ComboMenu combo) async {
    final existingQty = state
        .where((c) => c.isCombo && c.comboMenu?.id == combo.id)
        .fold(0, (s, c) => s + c.quantity);
    final ok = await _checkStock(
      targetId: combo.id,
      isCombo: true,
      requestedQty: (existingQty + 1).toDouble(),
      selectedItemIds: [],
    );
    if (ok) addCombo(combo);
    return ok;
  }

  /// Vérifie le stock puis ajoute le combo avec choices. Retourne false si bloqué.
  Future<bool> tryAddComboWithChoices(ComboMenu combo, Map<String, String> choices) async {
    final selectedItemIds = choices.values.toList();
    final existingQty = state
        .where((c) => c.isCombo && c.comboMenu?.id == combo.id)
        .fold(0, (s, c) => s + c.quantity);
    final ok = await _checkStock(
      targetId: combo.id,
      isCombo: true,
      requestedQty: (existingQty + 1).toDouble(),
      selectedItemIds: selectedItemIds,
    );
    if (ok) addComboWithChoices(combo, choices);
    return ok;
  }

  Future<bool> _checkStock({
    required String targetId,
    required bool isCombo,
    required double requestedQty,
    required List<String> selectedItemIds,
  }) async {
    if (!ref.read(isOnlineProvider)) return true;

    final sortedIds = [...selectedItemIds]..sort();
    final cacheKey = '${targetId}_${requestedQty}_${sortedIds.join(",")}';

    final cached = _stockCache[cacheKey];
    if (cached != null &&
        DateTime.now().difference(cached.cachedAt) < _cacheTtl) {
      return cached.available;
    }

    try {
      final available =
          await ref.read(inventoryRepositoryProvider).checkStockAvailability(
                targetId: targetId,
                isCombo: isCombo,
                shopId: AppConstants.shopId,
                requestedQty: requestedQty,
                selectedItemIds: selectedItemIds,
              );
      _stockCache[cacheKey] = (available: available, cachedAt: DateTime.now());
      return available;
    } catch (_) {
      // En cas d'erreur réseau inattendue, fail open (ne pas bloquer l'utilisateur)
      return true;
    }
  }

  void invalidateStockCache() => _stockCache.clear();

  void removeItem(String cartKey) {
    state = state.where((c) => c.cartKey != cartKey).toList();
  }

  void updateQuantity(String cartKey, int quantity) {
    if (quantity <= 0) return removeItem(cartKey);
    state = [
      for (final c in state)
        if (c.cartKey == cartKey)
          CartItem(
            menuItem: c.menuItem,
            comboMenu: c.comboMenu,
            quantity: quantity,
            note: c.note,
            selectedChoices: c.selectedChoices,
          )
        else
          c,
    ];
  }

  void updateNote(String cartKey, String? note) {
    state = [
      for (final c in state)
        if (c.cartKey == cartKey)
          CartItem(
            menuItem: c.menuItem,
            comboMenu: c.comboMenu,
            quantity: c.quantity,
            note: note,
            selectedChoices: c.selectedChoices,
          )
        else
          c,
    ];
  }

  void clear() => state = [];

  /// Reconstructs the cart from an existing [order] so it can be edited.
  /// Standalone items are matched by [menuItemId]; combo groups are matched
  /// by name (stripping the " #N" unit-suffix added at submit time).
  void loadOrderForEdit(
      Order order,
      List<MenuItem> menuItems,
      List<ComboMenu> comboMenus,
      ) {
    const sep = ' \u2013 '; // " – " used in submitOrder
    final comboSuffixRegex = RegExp(r' #\d+$');

    final cartItems = <CartItem>[];
    final Map<String, List<OrderItem>> comboGroups = {};

    for (final item in order.orderItems) {
      final sepIdx = item.name.indexOf(sep);
      if (sepIdx > 0) {
        final groupName = item.name.substring(0, sepIdx);
        comboGroups.putIfAbsent(groupName, () => []).add(item);
      } else {
        final menuItem =
            menuItems.where((m) => m.id == item.menuItemId).firstOrNull;
        if (menuItem != null) {
          cartItems.add(CartItem(menuItem: menuItem, quantity: item.quantity));
        }
      }
    }

    for (final entry in comboGroups.entries) {
      final groupName = entry.key; // e.g. "Combo A" or "Combo A #2"
      final items = entry.value;

      // Strip " #N" suffix to recover the real combo name.
      final baseName = groupName.replaceAll(comboSuffixRegex, '').trim();
      final combo =
          comboMenus.where((c) => c.name == baseName).firstOrNull;
      if (combo == null) continue;

      // Reconstruct selected choices for this unit.
      final selectedChoices = <String, String>{};
      for (final item in items) {
        final ci = combo.comboMenuItems
            .where((ci) =>
        ci.menuItemId == item.menuItemId && ci.choiceGroup != null)
            .firstOrNull;
        if (ci != null) {
          selectedChoices[ci.choiceGroup!] = ci.menuItemId;
        }
      }

      // If we already have this combo+choices combination, increment quantity.
      final tempItem =
      CartItem(comboMenu: combo, selectedChoices: Map.of(selectedChoices));
      final key = tempItem.cartKey;
      final existingIdx =
      cartItems.indexWhere((c) => c.isCombo && c.cartKey == key);
      if (existingIdx >= 0) {
        cartItems[existingIdx].quantity++;
      } else {
        cartItems.add(CartItem(
          comboMenu: combo,
          quantity: 1,
          selectedChoices: Map.of(selectedChoices),
        ));
      }
    }

    state = List.of(cartItems);
  }

  double get total => state.fold(0, (sum, c) => sum + c.subtotal);

  /// Builds the flat items list from the current cart state (shared by
  /// both [submitOrder] and [updateExistingOrder]).
  List<Map<String, dynamic>> _buildItemsPayload() {
    final items = <Map<String, dynamic>>[];

    // Pre-compute total units per combo ID across all cart entries so we can
    // assign globally-unique " #N" suffixes. This ensures two entries of the
    // same combo with *different* choices (each qty 1) get distinct group names
    // like "Combo A #1" and "Combo A #2" instead of both being "Combo A".
    final comboTotals = <String, int>{};
    for (final c in state) {
      if (c.isCombo) {
        final id = c.comboMenu!.id;
        comboTotals[id] = (comboTotals[id] ?? 0) + c.quantity;
      }
    }
    final comboCounters = <String, int>{};

    for (final c in state) {
      if (c.isCombo) {
        final comboId = c.comboMenu!.id;
        final totalUnits = comboTotals[comboId]!;
        final startUnit = comboCounters[comboId] ?? 0;

        final selectedIds = c.selectedChoices.values.toSet();
        final effectiveItems = c.comboMenu!.comboMenuItems.where((ci) {
          if (ci.choiceGroup == null) return true;
          return selectedIds.contains(ci.menuItemId);
        }).toList();

        for (int u = 0; u < c.quantity; u++) {
          final unitNum = startUnit + u + 1;
          final suffix = totalUnits > 1 ? ' #$unitNum' : '';
          for (final ci in effectiveItems) {
            final mi = ci.menuItem;
            if (mi == null) continue;
            items.add({
              'menu_item_id': mi.id,
              'name': '${c.comboMenu!.name}$suffix – ${mi.name}',
              'unit_price': 0.0,
              'quantity': ci.quantity,
            });
          }
          if (effectiveItems.isNotEmpty) {
            final lastQty = (items.last['quantity'] as int).clamp(1, double.maxFinite.toInt());
            items.last['unit_price'] = c.comboMenu!.price / lastQty;
          }
        }

        comboCounters[comboId] = startUnit + c.quantity;
      } else {
        items.add({
          'menu_item_id': c.menuItem!.id,
          'name': c.menuItem!.name,
          'unit_price': c.menuItem!.price,
          'quantity': c.quantity,
        });
      }
    }
    return items;
  }

  /// Updates an existing order in-place (same id, same status).
  Future<void> updateExistingOrder({
    required String orderId,
    String? tableLabel,
    String? note,
  }) async {
    final items = _buildItemsPayload();
    await ref.read(orderRepositoryProvider).updateOrderItems(
      orderId: orderId,
      items: items,
      tableLabel: tableLabel,
      note: note,
    );
    clear();
  }

  /// Returns true if the order was queued offline.
  Future<bool> submitOrder({
    required String shopId,
    required String cashierId,
    String? shiftId,
    String? tableLabel,
    String? note,
  }) async {
    final online = ref.read(isOnlineProvider);
    final items = _buildItemsPayload();

    if (online) {
      await ref.read(orderRepositoryProvider).createOrder(
        shopId: shopId,
        cashierId: cashierId,
        items: items,
        shiftId: shiftId,
        tableLabel: tableLabel,
        note: note,
      );
      clear();
      return false;
    } else {
      await OfflineQueueService().enqueueCreate({
        'local_id': _uuid.v4(),
        'shop_id': shopId,
        'cashier_id': cashierId,
        'items': items,
        'shift_id': shiftId,
        'table_label': tableLabel,
        'note': note,
        'queued_at': DateTime.now().toIso8601String(),
      });
      clear();
      return true;
    }
  }
}

// ── manager cashier filter ────────────────────────────────────────────────────

/// Holds the cashier ID the manager has chosen to filter by; null = show all.
final selectedCashierIdProvider = StateProvider<String?>((ref) => null);

/// Fetches the list of all staff (id + name) for the shop so the manager can
/// pick one from a filter chip row.
@riverpod
Future<List<({String id, String name, String role})>> shopStaffList(Ref ref, String shopId) async {
  final client = ref.read(orderRepositoryProvider).client;
  final data = await client
      .from('staff')
      .select('id, name, role')
      .eq('shop_id', shopId)
      .order('name');
  return (data as List)
      .map((e) => (id: e['id'] as String, name: e['name'] as String, role: e['role'] as String))
      .toList();
}

// ── order search ──────────────────────────────────────────────────────────────

@riverpod
class OrderSearch extends _$OrderSearch {
  Timer? _debounce;

  @override
  Future<List<Order>> build() async {
    ref.onDispose(() => _debounce?.cancel());
    return [];
  }

  void search(String query, {String? shopId, String? cashierId}) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      state = const AsyncData([]);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      if (!ref.mounted) return;
      state = const AsyncLoading();
      try {
        final results = await ref.read(orderRepositoryProvider).searchOrders(
          query: query,
          shopId: shopId,
          cashierId: cashierId,
        );
        if (!ref.mounted) return;
        state = AsyncData(results);
      } catch (e) {
        if (!ref.mounted) return;
        state = AsyncError(e, StackTrace.current);
      }
    });
  }
}