/// Typed result returned by the `get_staff_stats` Supabase RPC.
/// All monetary values are in MAD.
class StaffStats {
  const StaffStats({
    required this.totalShifts,
    required this.totalOrders,
    required this.totalRevenue,
    required this.cashRevenue,
    required this.cardRevenue,
    required this.totalTips,
    required this.passationAmount,
    required this.cashToHandOver,
    this.avgShiftDuration,
  });

  final int totalShifts;
  final int totalOrders;
  final double totalRevenue;
  final double cashRevenue;
  final double cardRevenue;
  final double totalTips;
  final double passationAmount;
  final double cashToHandOver;

  /// Average closed-shift duration in minutes. Null when there are no closed
  /// shifts yet (e.g. a brand-new employee whose only shift is still open).
  final int? avgShiftDuration;

  factory StaffStats.fromMap(Map<String, dynamic> m) => StaffStats(
    totalShifts: (m['total_shifts'] as num).toInt(),
    totalOrders: (m['total_orders'] as num).toInt(),
    totalRevenue: (m['total_revenue'] as num).toDouble(),
    cashRevenue: (m['cash_revenue'] as num).toDouble(),
    cardRevenue: (m['card_revenue'] as num).toDouble(),
    totalTips: (m['total_tips'] as num).toDouble(),
    passationAmount: (m['passation_amount'] as num).toDouble(),
    cashToHandOver: (m['cash_to_hand_over'] as num).toDouble(),
    avgShiftDuration: (m['avg_shift_duration'] as num?)?.toInt(),
  );
}