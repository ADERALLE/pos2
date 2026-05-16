import 'package:pos_v1/core/viewmodels/order_viewmodel.dart';
import 'package:pos_v1/core/viewmodels/inventory_viewmodel.dart';
import 'package:pos_v1/core/viewmodels/notification_viewmodel.dart';
import 'package:pos_v1/core/viewmodels/all_notifications_viewmodel.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/auth_state.dart';
import '../models/staff.dart';
import '../repositories/staff_repository.dart';

part 'auth_viewmodel.g.dart';

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  @override
  AuthState build() => const AuthState();

  Future<bool> login(Staff staff, String? pin) async {
    final hasPin = staff.pin != null && staff.pin!.isNotEmpty;

    // Staff with no PIN: allow login immediately, no check needed.
    if (!hasPin) {
      state = AuthState(staff: staff);
      return true;
    }

    // Staff with a PIN: pin must match exactly.
    if (pin == null || pin != staff.pin) return false;

    state = AuthState(staff: staff);
    return true;
  }

  Future<void> logout() async {
    state = const AuthState();
    // Invalidate all keepAlive providers so the next user gets fresh data
    ref.invalidate(activeOrdersProvider);
    ref.invalidate(myActiveOrdersProvider);
    ref.invalidate(shiftOrdersProvider);
    ref.invalidate(cartProvider);
    ref.invalidate(inventoryItemListProvider);
    ref.invalidate(inventoryRecipeListProvider);
    ref.invalidate(notificationsProvider);
    ref.invalidate(allNotificationsProvider);
  }
}

@riverpod
Staff? currentStaff(Ref ref) {
  return ref.watch(authProvider).staff;
}