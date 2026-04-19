import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category.dart';
import '../models/menu_item.dart';
import '../services/supabase_provider.dart';

part 'menu_repository.g.dart';

@riverpod
MenuRepository menuRepository(Ref ref) {
  return MenuRepository(ref.watch(supabaseClientProvider));
}

class MenuRepository {
  MenuRepository(this._client);
  final SupabaseClient _client;

  // ── categories ──────────────────────────────────────────

  Future<List<Category>> getCategories(String shopId) async {
    final data = await _client
        .from('categories')
        .select()
        .eq('shop_id', shopId)
        .order('sort_order');
    return data.map((e) => Category.fromJson(e)).toList();
  }

  Future<Category> createCategory({
    required String shopId,
    required String label,
    bool isSupp = false,
    int sortOrder = 0,
  }) async {
    final data = await _client
        .from('categories')
        .insert({
          'shop_id': shopId,
          'label': label,
          'is_supp': isSupp,
          'sort_order': sortOrder,
        })
        .select()
        .single();
    return Category.fromJson(data);
  }

  Future<Category> updateCategory({
    required String categoryId,
    String? label,
    bool? isSupp,
    int? sortOrder,
  }) async {
    final data = await _client
        .from('categories')
        .update({
      if (label != null) 'label': label,
      if (isSupp != null) 'is_supp': isSupp,
      if (sortOrder != null) 'sort_order': sortOrder,
    })
        .eq('id', categoryId)
        .select()
        .single();
    return Category.fromJson(data);
  }

  Future<void> deleteCategory(String categoryId) async {
    await _client.from('categories').delete().eq('id', categoryId);
  }

  // ── combo categories ──────────────────────────────────────

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

  // ── menu items ───────────────────────────────────────────

  Future<List<MenuItem>> getMenuItems(String shopId) async {
    final data = await _client
        .from('menu_items')
        .select()
        .eq('shop_id', shopId)
        .order('sort_order');
    return data.map((e) => MenuItem.fromJson(e)).toList();
  }

  Future<MenuItem> createMenuItem({
    required String shopId,
    required String name,
    required double price,
    String? categoryId,
    String? imageUrl,
    int sortOrder = 0,
  }) async {
    final data = await _client
        .from('menu_items')
        .insert({
      'shop_id': shopId,
      'name': name,
      'price': price,
      if (categoryId != null) 'category_id': categoryId,
      if (imageUrl != null) 'image_url': imageUrl,
      'sort_order': sortOrder,
    })
        .select()
        .single();
    return MenuItem.fromJson(data);
  }

  Future<MenuItem> updateMenuItem({
    required String itemId,
    String? name,
    double? price,
    String? categoryId,
    String? imageUrl,
    bool? isActive,
    int? sortOrder,
  }) async {
    final data = await _client
        .from('menu_items')
        .update({
      if (name != null) 'name': name,
      if (price != null) 'price': price,
      if (categoryId != null) 'category_id': categoryId,
      if (imageUrl != null) 'image_url': imageUrl,
      if (isActive != null) 'is_active': isActive,
      if (sortOrder != null) 'sort_order': sortOrder,
    })
        .eq('id', itemId)
        .select()
        .single();
    return MenuItem.fromJson(data);
  }

  Future<void> deleteMenuItem(String itemId) async {
    await _client.from('menu_items').delete().eq('id', itemId);
  }
}