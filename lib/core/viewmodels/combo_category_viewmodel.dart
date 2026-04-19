import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/category.dart';
import '../repositories/combo_category_repository.dart';

part 'combo_category_viewmodel.g.dart';

@riverpod
class ComboCategoryList extends _$ComboCategoryList {
  @override
  Future<List<Category>> build(String shopId) => _fetch(shopId);

  Future<List<Category>> _fetch(String shopId) =>
      ref.read(comboCategoryRepositoryProvider).getComboCategories(shopId);

  Future<void> create({
    required String shopId,
    required String label,
  }) async {
    await ref.read(comboCategoryRepositoryProvider).createComboCategory(
          shopId: shopId,
          label: label,
        );
    await _refresh(shopId);
  }

  Future<void> deleteCategory({
    required String categoryId,
    required String shopId,
  }) async {
    await ref
        .read(comboCategoryRepositoryProvider)
        .deleteComboCategory(categoryId);
    await _refresh(shopId);
  }

  Future<void> _refresh(String shopId) async {
    if (!ref.mounted) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(shopId));
  }
}
