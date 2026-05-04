import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/category.dart';
import '../models/menu_item.dart';
import '../repositories/menu_repository.dart';
import '../services/menu_cache_service.dart'; // Ensure this path is correct
import 'combo_menu_viewmodel.dart';

part 'menu_viewmodel.g.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

bool _isNetworkError(Object e) =>
    e is SocketException ||
        e.toString().contains('ClientException') ||
        e.toString().contains('Failed host lookup');

// ── Category List ─────────────────────────────────────────────────────────────

@riverpod
class CategoryList extends _$CategoryList {
  final _cache = MenuCacheService();

  @override
  Future<List<Category>> build(String shopId) async {
    return _fetchCategories(shopId);
  }

  Future<List<Category>> _fetchCategories(String shopId) async {
    try {
      final cats = await ref.read(menuRepositoryProvider).getCategories(shopId);
      // Persist for offline use
      await _cache.saveCategories(cats.map((c) => c.toJson()).toList());
      return cats;
    } catch (e) {
      if (_isNetworkError(e)) {
        final cached = await _cache.loadCategories();
        if (cached != null) {
          return cached.map(Category.fromJson).toList();
        }
        return [];
      }
      rethrow;
    }
  }

  Future<void> create({required String shopId, required String label, bool isSupp = false}) async {
    await ref.read(menuRepositoryProvider).createCategory(
      shopId: shopId,
      label: label,
      isSupp: isSupp,
    );
    await _refresh(shopId);
  }

  Future<void> editCategory({
    required String categoryId,
    required String shopId,
    String? label,
    bool? isSupp,
  }) async {
    await ref
        .read(menuRepositoryProvider)
        .updateCategory(categoryId: categoryId, label: label, isSupp: isSupp);
    await _refresh(shopId);
  }

  Future<void> deleteCategory({
    required String categoryId,
    required String shopId,
  }) async {
    await ref.read(menuRepositoryProvider).deleteCategory(categoryId);
    await _refresh(shopId);
  }

  Future<void> _refresh(String shopId) async {
    if (!ref.mounted) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchCategories(shopId));
  }
}

// ── Combo Category List ───────────────────────────────────────────────────────

@riverpod
class ComboCategoryList extends _$ComboCategoryList {
  @override
  Future<List<Category>> build(String shopId) async {
    return _fetchComboCategories(shopId);
  }

  Future<List<Category>> _fetchComboCategories(String shopId) async {
    return ref.read(menuRepositoryProvider).getComboCategories(shopId);
  }

  Future<void> create({required String shopId, required String label}) async {
    await ref.read(menuRepositoryProvider).createComboCategory(
      shopId: shopId,
      label: label,
    );
    await _refresh(shopId);
  }

  Future<void> deleteCategory({
    required String categoryId,
    required String shopId,
  }) async {
    await ref.read(menuRepositoryProvider).deleteComboCategory(categoryId);
    await _refresh(shopId);
    ref.invalidate(comboMenuListProvider(shopId));
  }

  Future<void> _refresh(String shopId) async {
    if (!ref.mounted) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchComboCategories(shopId));
  }
}

// ── Menu Item List ────────────────────────────────────────────────────────────

@riverpod
class MenuItemList extends _$MenuItemList {
  final _cache = MenuCacheService();

  @override
  Future<List<MenuItem>> build(String shopId) async {
    return _fetchMenuItems(shopId);
  }

  Future<List<MenuItem>> _fetchMenuItems(String shopId) async {
    try {
      final items = await ref.read(menuRepositoryProvider).getMenuItems(shopId);

      // Persist JSON for offline use
      await _cache.saveMenuItems(items.map((i) => i.toJson()).toList());

      // Pre-cache images in the background
      final imageUrls = items
          .map((i) => i.imageUrl)
          .whereType<String>()
          .where((u) => u.isNotEmpty)
          .toList();
      _cache.preCacheImages(imageUrls);

      return items;
    } catch (e) {
      if (_isNetworkError(e)) {
        final cached = await _cache.loadMenuItems();
        if (cached != null) {
          return cached.map(MenuItem.fromJson).toList();
        }
        return [];
      }
      rethrow;
    }
  }

  Future<void> create({
    required String shopId,
    required String name,
    required double price,
    String? categoryId,
    String? imageUrl,
  }) async {
    await ref.read(menuRepositoryProvider).createMenuItem(
      shopId: shopId,
      name: name,
      price: price,
      categoryId: categoryId,
      imageUrl: imageUrl,
    );
    await _refresh(shopId);
  }

  Future<void> editItem({
    required String itemId,
    required String shopId,
    String? name,
    double? price,
    String? categoryId,
    String? imageUrl,
    bool? isActive,
  }) async {
    await ref.read(menuRepositoryProvider).updateMenuItem(
      itemId: itemId,
      name: name,
      price: price,
      categoryId: categoryId,
      imageUrl: imageUrl,
      isActive: isActive,
    );
    await _refresh(shopId);
  }

  Future<void> deleteItem({
    required String itemId,
    required String shopId,
  }) async {
    await ref.read(menuRepositoryProvider).deleteMenuItem(itemId);
    await _refresh(shopId);
  }

  Future<void> _refresh(String shopId) async {
    if (!ref.mounted) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchMenuItems(shopId));
  }
}