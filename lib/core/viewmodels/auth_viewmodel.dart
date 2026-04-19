import 'package:pos_v1/core/viewmodels/order_viewmodel.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/auth_state.dart';
import '../models/staff.dart';
import '../repositories/staff_repository.dart';

part 'auth_viewmodel.g.dart';

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  @override
  AuthState build() => const AuthState();

  Future<bool> login(Staff staff, String pin) async {
    if (staff.pin == null || staff.pin != pin) return false;
    state = AuthState(staff: staff);
    return true;
  }

  Future<void> logout() async {
     state = const AuthState();
     // ref.invalidate(activeOrdersProvider);
     // ref.invalidate(myActiveOrdersProvider);
     // ref.invalidate(shiftOrdersProvider);
     //
     // ref.invalidate(orderHistoryProvider);
     // ref.invalidate(myOrderHistoryProvider);
     // ref.invalidate(shopOrderHistoryProvider);
     //
     // ref.invalidate(currentStaffProvider);
  }
}

@riverpod
Staff? currentStaff(Ref ref) {
  return ref.watch(authProvider).staff;
}