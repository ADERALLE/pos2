import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/combo_menu.dart';
import '../services/supabase_provider.dart';

part 'combo_menu_repository.g.dart';

@riverpod
ComboMenuRepository comboMenuRepository(Ref ref) {
  return ComboMenuRepository(ref.watch(supabaseClientProvider));
}

class ComboMenuRepository {
  ComboMenuRepository(this._client);
  final SupabaseClient _client;

  /// Fetches all combo menus for a shop, including nested items with their
  /// menu_item details.
  Future<List<ComboMenu>> getComboMenus(String shopId) async {
    final data = await _client
        .from('combo_menus')
        .select('*, combo_menu_items(*, menu_items(*))')
        .eq('shop_id', shopId)
        .order('sort_order');
    return data.map((e) => ComboMenu.fromJson(e)).toList();
  }

  Future<ComboMenu> createComboMenu({
    required String shopId,
    required String name,
    required double price,
    String? description,
    String? imageUrl,
    String? categoryId,
    int sortOrder = 0,
  }) async {
    final data = await _client
        .from('combo_menus')
        .insert({
          'shop_id': shopId,
          'name': name,
          'price': price,
          if (description != null) 'description': description,
          if (imageUrl != null) 'image_url': imageUrl,
          if (categoryId != null) 'category_id': categoryId,
          'sort_order': sortOrder,
        })
        .select()
        .single();
    return ComboMenu.fromJson(data);
  }

  Future<ComboMenu> updateComboMenu({
    required String comboId,
    String? name,
    double? price,
    String? description,
    String? imageUrl,
    String? categoryId,
    bool? clearCategory,
    bool? isActive,
    int? sortOrder,
  }) async {
    final data = await _client
        .from('combo_menus')
        .update({
          if (name != null) 'name': name,
          if (price != null) 'price': price,
          if (description != null) 'description': description,
          if (imageUrl != null) 'image_url': imageUrl,
          if (isActive != null) 'is_active': isActive,
          if (sortOrder != null) 'sort_order': sortOrder,
          if (categoryId != null) 'category_id': categoryId,
          if (clearCategory == true) 'category_id': null,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', comboId)
        .select()
        .single();
    return ComboMenu.fromJson(data);
  }

  Future<void> deleteComboMenu(String comboId) async {
    await _client.from('combo_menus').delete().eq('id', comboId);
  }

  /// Replaces the full set of items in a combo with the given list.
  /// Each entry must contain `menu_item_id` and `quantity`.
  Future<void> setComboItems({
    required String comboId,
    required List<Map<String, dynamic>> items,
  }) async {
    // Remove existing items first, then batch-insert the new set.
    await _client.from('combo_menu_items').delete().eq('combo_menu_id', comboId);
    if (items.isNotEmpty) {
      await _client.from('combo_menu_items').insert(
        items
            .map((i) => {
                  'combo_menu_id': comboId,
                  'menu_item_id': i['menu_item_id'],
                  'quantity': i['quantity'] ?? 1,
                  if (i['choice_group'] != null) 'choice_group': i['choice_group'],
                })
            .toList(),
      );
    }
  }
}
