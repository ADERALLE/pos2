import 'dart:async';
import 'dart:io';

import 'package:pos_v1/app/shared/payment_dialog.dart';
import 'package:pos_v1/core/models/cart_item.dart';
import 'package:pos_v1/core/models/menu_item.dart';
import 'package:pos_v1/core/models/order.dart';
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

// ── cart (offline-aware) ──────────────────────────────────────────────────────

@riverpod
class Cart extends _$Cart {
  @override
  List<CartItem> build() => [];

  void addItem(MenuItem item) {
    final existing = state.where((c) => c.menuItem.id == item.id).firstOrNull;
    if (existing != null) {
      state = [
        for (final c in state)
          if (c.menuItem.id == item.id)
            CartItem(menuItem: c.menuItem, quantity: c.quantity + 1, note: c.note)
          else
            c,
      ];
    } else {
      state = [...state, CartItem(menuItem: item)];
    }
  }

  void removeItem(String menuItemId) {
    state = state.where((c) => c.menuItem.id != menuItemId).toList();
  }

  void updateQuantity(String menuItemId, int quantity) {
    if (quantity <= 0) return removeItem(menuItemId);
    state = [
      for (final c in state)
        if (c.menuItem.id == menuItemId)
          CartItem(menuItem: c.menuItem, quantity: quantity, note: c.note)
        else
          c,
    ];
  }

  void updateNote(String menuItemId, String? note) {
    state = [
      for (final c in state)
        if (c.menuItem.id == menuItemId)
          CartItem(menuItem: c.menuItem, quantity: c.quantity, note: note)
        else
          c,
    ];
  }

  void clear() => state = [];

  double get total => state.fold(0, (sum, c) => sum + c.subtotal);

  /// Returns true if the order was queued offline.
  Future<bool> submitOrder({
    required String shopId,
    required String cashierId,
    String? shiftId,
    String? tableLabel,
    String? note,
  }) async {
    final online = ref.read(isOnlineProvider);

    final items = state
        .map((c) => {
      'menu_item_id': c.menuItem.id,
      'name': c.menuItem.name,
      'unit_price': c.menuItem.price,
      'quantity': c.quantity,
    })
        .toList();

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