import 'package:pos_v1/core/models/shift.dart';
import 'package:pos_v1/core/repositories/order_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';
import '../services/supabase_provider.dart';

part 'order_repository.g.dart';

@riverpod
OrderRepository orderRepository(Ref ref) {
  return OrderRepository(ref.watch(supabaseClientProvider));
}

class OrderRepository {
  OrderRepository(this._client);
  final SupabaseClient _client;
  SupabaseClient get client => _client;
  static const int _pageSize = 20;

  Future<List<Order>> getActiveOrders(String shopId) async {
    final data = await _client
        .from('orders')
        .select('*, staff(name), order_items(*, order_notes(*))')
        .eq('shop_id', shopId)
        .inFilter('status', ['pending', 'inprogress'])
        .order('created_at');
    return data.map((e) => Order.fromSupabase(e)).toList();
  }

  Future<List<Order>> getShopOrderHistory(String shopId, {int page = 0}) async {
    final data = await _client
        .from('orders')
        .select('*, staff(name), order_items(*, order_notes(*))')
        .eq('shop_id', shopId)
        .inFilter('status', ['done', 'cancelled'])
        .order('created_at', ascending: false)
        .range(page * _pageSize, (page + 1) * _pageSize - 1);
    return data.map((e) => Order.fromSupabase(e)).toList();
  }

  Future<List<Order>> getOrderHistory(String shopId) async {
    final data = await _client
        .from('orders')
        .select('*, staff(name), order_items(*, order_notes(*))')
        .eq('shop_id', shopId)
        .inFilter('status', ['done', 'cancelled'])
        .order('created_at', ascending: false)
        .limit(50);
    return data.map((e) => Order.fromSupabase(e)).toList();
  }

  Future<List<Order>> getMyOrderHistory(String cashierId, {int page = 0}) async {
    final data = await _client
        .from('orders')
        .select('*, order_items(*, order_notes(*))')
        .eq('cashier_id', cashierId)
        .inFilter('status', ['done', 'cancelled'])
        .order('created_at', ascending: false)
        .range(page * _pageSize, (page + 1) * _pageSize - 1);
    return data.map((e) => Order.fromJson(e)).toList();
  }

  Future<List<Order>> getMyActiveOrders(String cashierId) async {
    final data = await _client
        .from('orders')
        .select('*, order_items(*, order_notes(*))')
        .eq('cashier_id', cashierId)
        .inFilter('status', ['pending', 'inprogress'])
        .order('created_at');
    return data.map((e) => Order.fromJson(e)).toList();
  }

  Future<List<Order>> getShiftOrders(String shiftId) async {
    final data = await _client
        .from('orders')
        .select('*, order_items(*, order_notes(*))')
        .eq('shift_id', shiftId)
        .order('created_at', ascending: false);
    return data.map((e) => Order.fromJson(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getStaffShiftStats(String shopId) async {
    final data = await _client
        .from('shifts')
        .select('*, staff(name, role), orders(total, status, cash_amount, card_amount, tip)')
        .eq('shop_id', shopId)
        .order('opened_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>?> getLatestShiftByStaff(String staffId) async {
    return await _client
        .from('shifts')
        .select('*, staff(name), orders(total, status, cash_amount, card_amount, tip)')
        .eq('staff_id', staffId)
        .order('opened_at', ascending: false)
        .limit(1)
        .maybeSingle();
  }

  Future<Order> createOrder({
    required String shopId,
    required String cashierId,
    required List<Map<String, dynamic>> items,
    String? tableLabel,
    String? note,
    String? shiftId,
  }) async {
    final orderData = await _client
        .from('orders')
        .insert({
      'shop_id': shopId,
      'cashier_id': cashierId,
      if (tableLabel != null) 'table_label': tableLabel,
      if (note != null) 'note': note,
      if (shiftId != null) 'shift_id': shiftId,
    })
        .select()
        .single();

    final orderId = orderData['id'] as String;

    await _client.from('order_items').insert(
      items.map((i) => {...i, 'order_id': orderId}).toList(),
    );

    final full = await _client
        .from('orders')
        .select('*, order_items(*, order_notes(*))')
        .eq('id', orderId)
        .single();

    return Order.fromJson(full);
  }

  Future<Order> updateStatus({
    required String orderId,
    required OrderStatus status,
    String paymentMethod = 'cash',
    double cashAmount = 0,
    double cardAmount = 0,
    double tip = 0,
  }) async {
    final data = await _client
        .from('orders')
        .update({
      'status': status.name,
      'payment_method': paymentMethod,
      'cash_amount': cashAmount,
      'card_amount': cardAmount,
      'tip': tip,
    })
        .eq('id', orderId)
        .select('*, order_items(*, order_notes(*))')
        .single();
    return Order.fromJson(data);
  }

  Future<void> cancelOrder(String orderId) async {
    await _client
        .from('orders')
        .update({'status': OrderStatus.cancelled.name}).eq('id', orderId);
  }

  /// Replaces the items of an existing order in-place and recalculates the total.
  Future<Order> updateOrderItems({
    required String orderId,
    required List<Map<String, dynamic>> items,
    String? tableLabel,
    String? note,
  }) async {
    // Compute new total from items list.
    final newTotal = items.fold<double>(
      0,
      (sum, i) => sum + (i['unit_price'] as double) * (i['quantity'] as int),
    );

    // Update the order header (label, note, total).
    await _client.from('orders').update({
      'table_label': tableLabel,
      'note': note,
      'total': newTotal,
    }).eq('id', orderId);

    // Replace all existing items.
    await _client.from('order_items').delete().eq('order_id', orderId);
    await _client.from('order_items').insert(
      items.map((i) => {...i, 'order_id': orderId}).toList(),
    );

    final full = await _client
        .from('orders')
        .select('*, order_items(*, order_notes(*))')
        .eq('id', orderId)
        .single();
    return Order.fromJson(full);
  }

  Future<Map<String, dynamic>> getShiftSummary(String shiftId) async {
    final orders = await _client
        .from('orders')
        .select('*, order_items(*, order_notes(*))')
        .eq('shift_id', shiftId)
        .order('created_at', ascending: false);

    final shiftData = await _client
        .from('shifts')
        .select('passation_amount')
        .eq('id', shiftId)
        .single();

    final passationAmount = (shiftData['passation_amount'] as num).toDouble();
    final orderList = orders.map((e) => Order.fromJson(e)).toList();
    final doneOrders = orderList.where((o) => o.status == OrderStatus.done).toList();
    final cancelledOrders = orderList.where((o) => o.status == OrderStatus.cancelled).toList();

    // Use cash_amount / card_amount for accurate split-payment accounting.
    final cashRevenue = doneOrders.fold(0.0, (sum, o) => sum + o.cashAmount);
    final cardRevenue = doneOrders.fold(0.0, (sum, o) => sum + o.cardAmount);
    final totalTips   = doneOrders.fold(0.0, (sum, o) => sum + o.tip);

    // Cash to hand over = cash collected + rotation taken at shift start − tips (tips stay with cashier)
    final cashToHandOver = (cashRevenue + passationAmount - totalTips).clamp(0.0, double.infinity);

    return {
      'orders': orderList,
      'totalOrders': orderList.length,
      'doneOrders': doneOrders.length,
      'cancelledOrders': cancelledOrders.length,
      'totalRevenue': cashRevenue + cardRevenue,
      'cashRevenue': cashRevenue,
      'cardRevenue': cardRevenue,
      'totalTips': totalTips,
      'passationAmount': passationAmount,
      'cashToHandOver': cashToHandOver,
    };
  }

  Future<List<Order>> searchOrders({
    required String query,
    String? shopId,
    String? cashierId,
  }) async {
    final q = query.trim();
    if (q.isEmpty) return [];

    var request = _client
        .from('orders')
        .select('*, staff(name), order_items(*, order_notes(*))')
        .ilike('id_short', '%$q%');
    if (shopId != null) request = request.eq('shop_id', shopId);
    if (cashierId != null) request = request.eq('cashier_id', cashierId);

    final rows = await request.order('created_at', ascending: false).limit(50);
    return rows
        .map((e) => shopId != null ? Order.fromSupabase(e) : Order.fromJson(e))
        .toList();
  }

  Future<Shift> getShiftById(String shiftId) async {
    final data = await _client
        .from('shifts')
        .select()
        .eq('id', shiftId)
        .single();
    return Shift.fromJson(data);
  }
}