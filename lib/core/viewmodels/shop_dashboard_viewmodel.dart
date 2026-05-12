// lib/core/viewmodels/shop_dashboard_viewmodel.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../repositories/shop_dashboard_repository.dart';

part 'shop_dashboard_viewmodel.g.dart';

// ── Date range ────────────────────────────────────────────────────────────────

enum RangeMode { day, nDays, week, month, year }

class DateRange {
  const DateRange({required this.from, required this.to, required this.mode});

  final DateTime from;
  final DateTime to;
  final RangeMode mode;

  /// Human-readable label shown in the AppBar.
  String get label {
    switch (mode) {
      case RangeMode.day:
        return _fmt(from);
      case RangeMode.nDays:
        return '${_fmt(from)} – ${_fmt(to)}';
      case RangeMode.week:
        return 'Week of ${_fmt(from)}';
      case RangeMode.month:
        return _monthLabel(from);
      case RangeMode.year:
        return '${from.year}';
    }
  }

  /// True if the range end is today or in the future.
  bool get isLatest {
    final today = DateTime.now();
    return !to.isBefore(DateTime(today.year, today.month, today.day));
  }

  DateRange next()     => _shift(1);
  DateRange previous() => _shift(-1);

  DateRange _shift(int direction) {
    switch (mode) {
      case RangeMode.day:
        final d = from.add(Duration(days: direction));
        return DateRange(from: d, to: d, mode: mode);

      case RangeMode.nDays:
        final span = to.difference(from).inDays + 1;
        final d = from.add(Duration(days: span * direction));
        return DateRange(from: d, to: d.add(Duration(days: span - 1)), mode: mode);

      case RangeMode.week:
        final d = from.add(Duration(days: 7 * direction));
        return DateRange(from: d, to: d.add(const Duration(days: 6)), mode: mode);

      case RangeMode.month:
        final m    = from.month + direction;
        final year = from.year + (m - 1) ~/ 12;
        final month = ((m - 1) % 12) + 1;
        final start = DateTime(year, month, 1);
        final end   = DateTime(year, month + 1, 1).subtract(const Duration(days: 1));
        return DateRange(from: start, to: end, mode: mode);

      case RangeMode.year:
        final y = from.year + direction;
        return DateRange(from: DateTime(y, 1, 1), to: DateTime(y, 12, 31), mode: mode);
    }
  }

  // ── Factory constructors ───────────────────────────────────────────────────

  factory DateRange.today() {
    final d = _today();
    return DateRange(from: d, to: d, mode: RangeMode.day);
  }

  factory DateRange.lastNDays(int n) {
    final end   = _today();
    final start = end.subtract(Duration(days: n - 1));
    return DateRange(from: start, to: end, mode: RangeMode.nDays);
  }

  factory DateRange.thisWeek() {
    final today  = _today();
    final monday = today.subtract(Duration(days: today.weekday - 1));
    return DateRange(from: monday, to: monday.add(const Duration(days: 6)), mode: RangeMode.week);
  }

  factory DateRange.thisMonth() {
    final today = _today();
    final start = DateTime(today.year, today.month, 1);
    final end   = DateTime(today.year, today.month + 1, 1).subtract(const Duration(days: 1));
    return DateRange(from: start, to: end, mode: RangeMode.month);
  }

  factory DateRange.thisYear() {
    final y = DateTime.now().year;
    return DateRange(from: DateTime(y, 1, 1), to: DateTime(y, 12, 31), mode: RangeMode.year);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  static const _months = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String _fmt(DateTime d)        => '${_months[d.month]} ${d.day}, ${d.year}';
  static String _monthLabel(DateTime d) => '${_months[d.month]} ${d.year}';

  @override
  bool operator ==(Object other) =>
      other is DateRange && other.from == from && other.to == to && other.mode == mode;

  @override
  int get hashCode => Object.hash(from, to, mode);
}

// ── Summary models ────────────────────────────────────────────────────────────

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
    required this.range,
  });

  final int totalOrders;
  final double totalRevenue;
  final double cashRevenue;
  final double cardRevenue;
  final double totalTips;
  final double avgOrderValue;
  final List<TopItem> topItems;
  final List<HourlyBucket> ordersByHour;
  final DateRange range;
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

// ── Provider ──────────────────────────────────────────────────────────────────

@riverpod
Future<DailySummary> dailySummary(
    Ref ref,
    String shopId,
    DateRange range,
    ) async {
  // Single RPC call — DB returns one small JSON object, no matter the order volume.
  final raw = await ref
      .read(shopDashboardRepositoryProvider)
      .getDashboardSummary(shopId: shopId, from: range.from, to: range.to);

  // ── KPIs ──────────────────────────────────────────────────────────────────
  final totalOrders = (raw['total_orders'] as num? ?? 0).toInt();
  final cashRevenue = (raw['cash_revenue'] as num? ?? 0).toDouble();
  final cardRevenue = (raw['card_revenue'] as num? ?? 0).toDouble();
  final totalTips   = (raw['total_tips']   as num? ?? 0).toDouble();
  final totalRevenue = cashRevenue + cardRevenue;

  // ── Hourly buckets ────────────────────────────────────────────────────────
  // RPC guarantees 24 rows ordered 0–23; fall back to zeros if null.
  final rawHourly = raw['orders_by_hour'] as List? ?? [];
  final ordersByHour = rawHourly.isNotEmpty
      ? rawHourly
      .map((e) => HourlyBucket(
    hour:  (e['hour']  as num).toInt(),
    count: (e['count'] as num).toInt(),
  ))
      .toList()
      : List.generate(24, (h) => HourlyBucket(hour: h, count: 0));

  // ── Top items ─────────────────────────────────────────────────────────────
  final rawTop = raw['top_items'] as List? ?? [];
  final topItems = rawTop
      .map((e) => TopItem(
    name:     e['name']     as String? ?? 'Unknown',
    quantity: (e['quantity'] as num).toInt(),
  ))
      .toList();

  return DailySummary(
    totalOrders:   totalOrders,
    totalRevenue:  totalRevenue,
    cashRevenue:   cashRevenue,
    cardRevenue:   cardRevenue,
    totalTips:     totalTips,
    avgOrderValue: totalOrders > 0 ? totalRevenue / totalOrders : 0.0,
    topItems:      topItems,
    ordersByHour:  ordersByHour,
    range:         range,
  );
}