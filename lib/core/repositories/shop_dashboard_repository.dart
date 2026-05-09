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

  Future<List<Map<String, dynamic>>> getOrdersInRange({
    required String shopId,
    required DateTime from,
    required DateTime to,
  }) async {
    // Normalise: start of [from] day → end of [to] day (local midnight-based)
    final start = DateTime(from.year, from.month, from.day);
    final end   = DateTime(to.year, to.month, to.day, 23, 59, 59);

    final data = await _client
        .from('orders')
        .select(
      'id, total, created_at, cash_amount, card_amount, tip, '
          'order_items(quantity, menu_items(name))',
    )
        .eq('shop_id', shopId)
        .eq('status', 'done')
        .gte('created_at', start.toIso8601String())
        .lte('created_at', end.toIso8601String());

    return List<Map<String, dynamic>>.from(data);
  }
}