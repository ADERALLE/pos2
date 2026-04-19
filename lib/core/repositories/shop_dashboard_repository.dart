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

  Future<List<Map<String, dynamic>>> getDailyOrders({
    required String shopId,
    required DateTime date,
  }) async {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final data = await _client
        .from('orders')
        .select(
      'id, total, created_at, cash_amount, card_amount, tip, '
          'order_items(quantity, menu_items(name))',
    )
        .eq('shop_id', shopId)
        .eq('status', 'done')
        .gte('created_at', '${dateStr}T00:00:00')
        .lte('created_at', '${dateStr}T23:59:59');

    return List<Map<String, dynamic>>.from(data);
  }
}