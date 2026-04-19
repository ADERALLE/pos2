import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../repositories/combo_category_repository.dart';

final comboCategoryListProvider = AsyncNotifierProviderFamily<
    ComboCategoryList, List<Category>, String>(ComboCategoryList.new);

class ComboCategoryList extends FamilyAsyncNotifier<List<Category>, String> {
  @override
  Future<List<Category>> build(String arg) => _fetch(arg);

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
    await _refresh();
  }

  Future<void> deleteCategory({
    required String categoryId,
    required String shopId,
  }) async {
    await ref
        .read(comboCategoryRepositoryProvider)
        .deleteComboCategory(categoryId);
    await _refresh();
  }

  Future<void> _refresh() async {
    if (!ref.mounted) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(arg));
  }
}
