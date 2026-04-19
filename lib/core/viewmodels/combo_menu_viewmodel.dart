import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/combo_menu.dart';
import '../repositories/combo_menu_repository.dart';

part 'combo_menu_viewmodel.g.dart';

bool _isNetworkError(Object e) =>
    e is SocketException ||
    e.toString().contains('ClientException') ||
    e.toString().contains('Failed host lookup');

@riverpod
class ComboMenuList extends _$ComboMenuList {
  @override
  Future<List<ComboMenu>> build(String shopId) async {
    return _fetch(shopId);
  }

  Future<List<ComboMenu>> _fetch(String shopId) async {
    try {
      return await ref.read(comboMenuRepositoryProvider).getComboMenus(shopId);
    } catch (e) {
      if (_isNetworkError(e)) return state.value ?? [];
      rethrow;
    }
  }

  Future<void> create({
    required String shopId,
    required String name,
    required double price,
    String? description,
    String? imageUrl,
    String? categoryId,
    required List<Map<String, dynamic>> items,
  }) async {
    final repo = ref.read(comboMenuRepositoryProvider);
    final combo = await repo.createComboMenu(
      shopId: shopId,
      name: name,
      price: price,
      description: description,
      imageUrl: imageUrl,
      categoryId: categoryId,
    );
    if (items.isNotEmpty) {
      await repo.setComboItems(comboId: combo.id, items: items);
    }
    await _refresh(shopId);
  }

  Future<void> edit({
    required String comboId,
    required String shopId,
    String? name,
    double? price,
    String? description,
    String? imageUrl,
    String? categoryId,
    bool clearCategory = false,
    bool? isActive,
    List<Map<String, dynamic>>? items,
  }) async {
    final repo = ref.read(comboMenuRepositoryProvider);
    await repo.updateComboMenu(
      comboId: comboId,
      name: name,
      price: price,
      description: description,
      imageUrl: imageUrl,
      categoryId: categoryId,
      clearCategory: clearCategory,
      isActive: isActive,
    );
    if (items != null) {
      await repo.setComboItems(comboId: comboId, items: items);
    }
    await _refresh(shopId);
  }

  Future<void> delete({
    required String comboId,
    required String shopId,
  }) async {
    await ref.read(comboMenuRepositoryProvider).deleteComboMenu(comboId);
    await _refresh(shopId);
  }

  Future<void> _refresh(String shopId) async {
    if (!ref.mounted) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(shopId));
  }
}
