import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category.dart';
import '../services/supabase_provider.dart';

final comboCategoryRepositoryProvider = Provider<ComboCategoryRepository>((ref) {
  return ComboCategoryRepository(ref.watch(supabaseClientProvider));
});

class ComboCategoryRepository {
  ComboCategoryRepository(this._client);
  final SupabaseClient _client;

  Future<List<Category>> getComboCategories(String shopId) async {
    final data = await _client
        .from('combo_categories')
        .select()
        .eq('shop_id', shopId)
        .order('sort_order');
    return data.map((e) => Category.fromJson(e)).toList();
  }

  Future<Category> createComboCategory({
    required String shopId,
    required String label,
    int sortOrder = 0,
  }) async {
    final data = await _client
        .from('combo_categories')
        .insert({'shop_id': shopId, 'label': label, 'sort_order': sortOrder})
        .select()
        .single();
    return Category.fromJson(data);
  }

  Future<void> deleteComboCategory(String categoryId) async {
    await _client.from('combo_categories').delete().eq('id', categoryId);
  }
}
