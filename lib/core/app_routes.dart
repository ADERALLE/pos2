import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_v1/app/auth/login_page.dart';
import 'package:pos_v1/app/home/shift_summary_page.dart';
import 'package:pos_v1/app/notifications/notifications_page.dart';
import 'package:pos_v1/app/orders/new_order_page.dart';
import 'package:pos_v1/app/settings/shop_dashboard/shop_dashboard_page.dart';
import 'package:pos_v1/app/settings/staff/staff_detail_page.dart';
import 'package:pos_v1/app/settings/staff/staffdashboard.dart';
import 'package:pos_v1/core/models/shift.dart';
import 'package:pos_v1/core/models/staff.dart';
import 'package:pos_v1/core/viewmodels/auth_viewmodel.dart';
import '../app/app_routes_shell.dart';
import '../app/home/home_page.dart';
import '../app/orders/orders_page.dart';
import '../app/settings/menu/menu_page.dart';
import '../app/settings/settings.dart';
import '../app/settings/staff/stafflist.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(this._ref) {
    _ref.listen(authProvider, (_, __) => notifyListeners());
  }
  final Ref _ref;
}

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = _AuthNotifier(ref);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final container = ProviderScope.containerOf(context);
      final isAuth = container.read(authProvider).isAuthenticated;
      final staff = container.read(currentStaffProvider);
      final isLogin = state.matchedLocation == '/login';

      if (!isAuth && !isLogin) return '/login';
      if (isAuth && isLogin) return '/home';

      // block cashiers from settings
      if (staff?.role == StaffRole.cashier &&
          state.matchedLocation.startsWith('/settings')) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: '/shift-summary',
        builder: (context, state) {
          final shift = state.extra as Shift;
          return ShiftSummaryPage(shift: shift);
        },
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNestedNavigation(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomePage(),
                routes: [
                  GoRoute(
                    path: 'new-order',  // ← nested here
                    builder: (_, __) => const NewOrderPage(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/orders',
                builder: (context, state) => const OrdersPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/notifications',
                builder: (context, state) => const NotificationsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsPage(),
                routes: [
                  GoRoute(
                    path: 'staff',
                    builder: (context, state) => const StaffListPage(),
                  ),
                  GoRoute(
                    path: 'menu',
                    builder: (context, state) => const MenuPage(),
                  ),
                  GoRoute(
                    path: 'staff-dashboard',
                    builder: (_, __) => const StaffDashboardPage(),
                    routes: [
                      GoRoute(
                        path: ':staffId',
                        builder: (context, state) {
                          final extra = state.extra as Map<String, dynamic>;
                          return StaffDetailPage(staff: extra);
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'shop-dashboard',
                    builder: (context, state) {
                      final date = state.extra as DateTime? ?? DateTime.now();
                      return ShopDashboardPage(date: date);
                    },
                  ),
// nested under /settings
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});