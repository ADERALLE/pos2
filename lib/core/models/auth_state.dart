import 'staff.dart';

class AuthState {
  const AuthState({this.staff});
  final Staff? staff;

  bool get isAuthenticated => staff != null;
}