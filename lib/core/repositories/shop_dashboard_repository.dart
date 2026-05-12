// lib/core/repositories/shop_dashboard_repository.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_provider.dart';

part 'shop_dashboard_repository.g.dart';

@riverpod
ShopDashboardRepository shopDashboardRepository(Ref ref) {
  return ShopDashboardRepository(ref.watch(supabaseClientProvider));
}

class ShopDashboardRepository {
  ShopDashboardRepository(this._client);
  final SupabaseClient _client;

  /// Calls the `get_shop_dashboard_summary` Postgres RPC.
  /// The DB does all aggregation — only a single small JSON object
  /// is transferred over the wire regardless of order volume.
  Future<Map<String, dynamic>> getDashboardSummary({
    required String shopId,
    required DateTime from,
    required DateTime to,
  }) async {
    // Normalise to start-of-day / end-of-day boundaries (local time → ISO)
    final start = DateTime(from.year, from.month, from.day);
    final end   = DateTime(to.year,   to.month,   to.day, 23, 59, 59);

    final data = await _client.rpc(
      'get_shop_dashboard_summary',
      params: {
        'p_shop_id': shopId,
        'p_from':    start.toIso8601String(),
        'p_to':      end.toIso8601String(),
      },
    );

    // `rpc` returns the JSON value directly when the function returns JSON
    if (data is Map<String, dynamic>) return data;

    // Supabase sometimes wraps it in a list
    if (data is List && data.isNotEmpty && data.first is Map<String, dynamic>) {
      return data.first as Map<String, dynamic>;
    }

    throw StateError('Unexpected RPC response type: ${data.runtimeType}');
  }
}