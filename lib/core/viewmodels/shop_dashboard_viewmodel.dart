// lib/core/viewmodels/shop_dashboard_viewmodel.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../repositories/shop_dashboard_repository.dart';

part 'shop_dashboard_viewmodel.g.dart';

class DailySummary {
  const DailySummary({
    required this.totalOrders,
    required this.totalRevenue,
    required this.cashRevenue,
    required this.cardRevenue,
    required this.totalTips,
    required this.avgOrderValue,
    required this.topItems,
    required this.ordersByHour,
    required this.date,
  });

  final int totalOrders;
  final double totalRevenue;
  final double cashRevenue;
  final double cardRevenue;
  final double totalTips;
  final double avgOrderValue;
  final List<TopItem> topItems;
  final List<HourlyBucket> ordersByHour;
  final DateTime date;
}

class TopItem {
  const TopItem({required this.name, required this.quantity});
  final String name;
  final int quantity;
}

class HourlyBucket {
  const HourlyBucket({required this.hour, required this.count});
  final int hour;
  final int count;
}

@riverpod
Future<DailySummary> dailySummary(
    Ref ref,
    String shopId,
    DateTime date,
    ) async {
  final orders = await ref
      .read(shopDashboardRepositoryProvider)
      .getDailyOrders(shopId: shopId, date: date);

  final totalOrders = orders.length;
  double cashRevenue = 0;
  double cardRevenue = 0;
  double totalTips   = 0;

  final itemMap   = <String, int>{};
  final bucketMap = <int, int>{};

  for (final order in orders) {
    // Use the explicit amount columns instead of guessing from payment_method.
    cashRevenue += (order['cash_amount'] as num? ?? 0).toDouble();
    cardRevenue += (order['card_amount'] as num? ?? 0).toDouble();
    totalTips   += (order['tip']         as num? ?? 0).toDouble();

    final dt = DateTime.parse(order['created_at'] as String);
    bucketMap[dt.hour] = (bucketMap[dt.hour] ?? 0) + 1;

    final items = order['order_items'] as List? ?? [];
    for (final item in items) {
      final name = item['menu_items']?['name'] as String? ?? 'Unknown';
      final qty  = item['quantity'] as int? ?? 1;
      itemMap[name] = (itemMap[name] ?? 0) + qty;
    }
  }

  final totalRevenue = cashRevenue + cardRevenue;

  final topItems = itemMap.entries
      .map((e) => TopItem(name: e.key, quantity: e.value))
      .toList()
    ..sort((a, b) => b.quantity.compareTo(a.quantity));

  final ordersByHour = List.generate(
    24,
        (h) => HourlyBucket(hour: h, count: bucketMap[h] ?? 0),
  );

  return DailySummary(
    totalOrders:   totalOrders,
    totalRevenue:  totalRevenue,
    cashRevenue:   cashRevenue,
    cardRevenue:   cardRevenue,
    totalTips:     totalTips,
    avgOrderValue: totalOrders > 0 ? totalRevenue / totalOrders : 0.0,
    topItems:      topItems.take(5).toList(),
    ordersByHour:  ordersByHour,
    date:          date,
  );
}