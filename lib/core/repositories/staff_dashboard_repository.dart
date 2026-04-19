import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_provider.dart';

part 'staff_dashboard_repository.g.dart';

@riverpod
StaffDashboardRepository staffDashboardRepository(Ref ref) {
  return StaffDashboardRepository(ref.watch(supabaseClientProvider));
}

class StaffDashboardRepository {
  StaffDashboardRepository(this._client);
  final SupabaseClient _client;

  static const int pageSize = 10;

  Future<List<Map<String, dynamic>>> getStaffList(String shopId) async {
    final data = await _client
        .from('staff')
        .select('id, name, role, is_active')
        .eq('shop_id', shopId)
        .eq('is_active', true)
        .order('name');
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> getShiftsByStaff({
    required String staffId,
    int page = 0,
  }) async {
    final data = await _client
        .from('shifts')
        .select('*, orders(id, total, status, cash_amount, card_amount, tip)')
        .eq('staff_id', staffId)
        .order('opened_at', ascending: false)
        .range(page * pageSize, (page + 1) * pageSize - 1);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>> getStaffStats(String staffId) async {
    final shifts = await _client
        .from('shifts')
        .select('id, opened_at, closed_at, passation_amount, orders(total, status, cash_amount, card_amount, tip)')
        .eq('staff_id', staffId);

    int totalShifts  = shifts.length;
    int totalOrders  = 0;
    double totalTips = 0;
    double cashRevenue  = 0;
    double cardRevenue  = 0;
    double totalPassation = 0;
    Duration totalDuration = Duration.zero;

    for (final s in shifts) {
      final orders = s['orders'] as List? ?? [];
      totalOrders  += orders.length;
      totalPassation += (s['passation_amount'] as num? ?? 0).toDouble();

      for (final o in orders) {
        if (o['status'] == 'done') {
          // Use the explicit amount columns for accurate split-payment accounting.
          cashRevenue += (o['cash_amount'] as num? ?? 0).toDouble();
          cardRevenue += (o['card_amount'] as num? ?? 0).toDouble();
          totalTips   += (o['tip']         as num? ?? 0).toDouble();
        }
      }

      if (s['closed_at'] != null) {
        totalDuration += DateTime.parse(s['closed_at'])
            .difference(DateTime.parse(s['opened_at']));
      }
    }

    final cashToHandOver =
    (cashRevenue + totalPassation - totalTips).clamp(0.0, double.infinity);

    return {
      'totalShifts':    totalShifts,
      'totalOrders':    totalOrders,
      'totalRevenue':   cashRevenue + cardRevenue,
      'cashRevenue':    cashRevenue,
      'cardRevenue':    cardRevenue,
      'totalTips':      totalTips,
      'passationAmount': totalPassation,
      'cashToHandOver': cashToHandOver,
      'avgShiftDuration': totalShifts > 0
          ? totalDuration.inMinutes ~/ totalShifts
          : 0,
    };
  }
}