// lib/viewmodels/shift_viewmodel.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/shift.dart';
import '../repositories/shift_repository.dart';

part 'shift_viewmodel.g.dart';

@riverpod
class ActiveShift extends _$ActiveShift {
  @override
  Future<Shift?> build(String staffId) {
    return ref.read(shiftRepositoryProvider).getActiveShift(staffId);
  }
  void resume(Shift shift) {
    state = AsyncData(shift);
  }
  Future<void> openShift({
    required String shopId,
    required String staffId,
    String? note,
    double rotationAmount = 0,

  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
          () => ref.read(shiftRepositoryProvider).openShift(
        shopId: shopId,
        staffId: staffId,
        note: note,
        rotationAmount: rotationAmount,

          ),
    );
  }

  Future<void> closeShift({
    required String shiftId,
    String? note,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(shiftRepositoryProvider).closeShift(
        shiftId: shiftId,
        note: note,
      );
      return null;
    });
  }
}

@riverpod
class ShopShifts extends _$ShopShifts {
  @override
  Future<List<Shift>> build(String shopId) {
    return ref.read(shiftRepositoryProvider).getShopShifts(shopId);
  }

  Future<void> refresh(String shopId) async {
    if (!ref.mounted) return;
    state = const AsyncLoading();
    if (!ref.mounted) return;
    state = await AsyncValue.guard(
          () => ref.read(shiftRepositoryProvider).getShopShifts(shopId),
    );
  }
}

@riverpod
class StaffShifts extends _$StaffShifts {
  @override
  Future<List<Shift>> build(String staffId) {
    return ref.read(shiftRepositoryProvider).getStaffShifts(staffId);
  }

  Future<void> refresh(String staffId) async {
    if (!ref.mounted) return;
    state = const AsyncLoading();
    if (!ref.mounted) return;
    state = await AsyncValue.guard(
          () => ref.read(shiftRepositoryProvider).getStaffShifts(staffId),
    );
  }
}