import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/staff.dart';
import '../repositories/staff_repository.dart';

part 'staff_viewmodel.g.dart';

@riverpod
class StaffList extends _$StaffList {
  @override
  Future<List<Staff>> build(String shopId) {
    return ref.read(staffRepositoryProvider).getStaff(shopId);
  }

  Future<void> create({
    required String shopId,
    required String name,
    required StaffRole role,
    String? pin,
  }) async {
    await ref.read(staffRepositoryProvider).createStaff(
      shopId: shopId,
      name: name,
      role: role,
      pin: pin,
    );
    await _refresh(shopId);
  }

  Future<void> update2({
    required String staffId,
    required String shopId,
    String? name,
    StaffRole? role,
    String? pin,
    bool? isActive,
  }) async {
    await ref.read(staffRepositoryProvider).updateStaff(
      staffId: staffId,
      name: name,
      role: role,
      pin: pin,
      isActive: isActive,
    );
    await _refresh(shopId);
  }

  Future<void> delete({
    required String staffId,
    required String shopId,
  }) async {
    await ref.read(staffRepositoryProvider).deleteStaff(staffId);
    await _refresh(shopId);
  }

  Future<void> _refresh(String shopId) async {
    if (!ref.mounted) return;
    state = const AsyncLoading();
    if (!ref.mounted) return;
    state = await AsyncValue.guard(
          () => ref.read(staffRepositoryProvider).getStaff(shopId),
    );
  }
}