import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pos_v1/core/models/staff_stats.dart';
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

  // ── Staff list ──────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getStaffList(String shopId) async {
    final data = await _client
        .from('staff')
        .select('id, name, role, is_active')
        .eq('shop_id', shopId)
        .eq('is_active', true)
        .order('name');
    return List<Map<String, dynamic>>.from(data);
  }

  // ── Latest shift (Last Shift tab) ───────────────────────────────────────────

  /// Returns the single most-recent shift with its orders embedded.
  /// One row, one round-trip — no aggregation on the client.
  Future<Map<String, dynamic>?> getLatestShift(String staffId) async {
    final data = await _client
        .from('shifts')
        .select('*, orders(id, total, status, cash_amount, card_amount, tip)')
        .eq('staff_id', staffId)
        .order('opened_at', ascending: false)
        .limit(1)
        .maybeSingle();
    return data;
  }

  // ── Paginated shift list (All Shifts tab) ───────────────────────────────────

  /// Fetches one page of shifts for the list view.
  /// Minimal columns — no embedded orders, no heavy payload.
  Future<List<Map<String, dynamic>>> getShiftsByStaff({
    required String staffId,
    int page = 0,
  }) async {
    final data = await _client
        .from('shifts')
        .select(
      'id, shop_id, staff_id, opened_at, closed_at, '
          'passation_amount, opening_note, closing_note, '
          'orders(id, status, cash_amount, card_amount)',
    )
        .eq('staff_id', staffId)
        .order('opened_at', ascending: false)
        .range(page * pageSize, (page + 1) * pageSize - 1);
    return List<Map<String, dynamic>>.from(data);
  }

  // ── All-time stats (All Shifts tab header) ──────────────────────────────────

  /// Delegates all aggregation to the `get_staff_stats` PostgreSQL function.
  /// Returns one row — zero raw order/shift rows are transferred.
  Future<StaffStats> getStaffStats(String staffId) async {
    final data = await _client
        .rpc('get_staff_stats', params: {'p_staff_id': staffId})
        .single();
    return StaffStats.fromMap(data as Map<String, dynamic>);
  }
}