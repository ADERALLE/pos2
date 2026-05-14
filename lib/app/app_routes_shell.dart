import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_v1/app/shared/offline_banner.dart';
import 'package:pos_v1/core/models/staff.dart';
import 'package:pos_v1/core/services/sync_service.dart';
import 'package:pos_v1/core/viewmodels/auth_viewmodel.dart';
import 'package:pos_v1/core/viewmodels/notification_viewmodel.dart';
import 'package:pos_v1/i10n/app_localizations.dart';

class ScaffoldWithNestedNavigation extends ConsumerWidget {
  const ScaffoldWithNestedNavigation({
    Key? key,
    required this.navigationShell,
  }) : super(key: key ?? const ValueKey('ScaffoldWithNestedNavigation'));

  final StatefulNavigationShell navigationShell;

  void _goBranch(BuildContext context, WidgetRef ref, int index) {
    final staff = ref.read(currentStaffProvider);
    final isCashier = staff?.role == StaffRole.cashier;
    if (isCashier && index >= 2) return;
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(syncServiceProvider);

    final staff = ref.watch(currentStaffProvider);
    if (staff == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 600) {
        return _ScaffoldWithNavigationBar(
          body: navigationShell,
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (i) => _goBranch(context, ref, i),
        );
      } else {
        // Always compact rail — never extended.
        return _ScaffoldWithNavigationRail(
          body: navigationShell,
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (i) => _goBranch(context, ref, i),
        );
      }
    });
  }
}

// ── bottom nav bar ────────────────────────────────────────────────────────────

class _ScaffoldWithNavigationBar extends ConsumerWidget {
  const _ScaffoldWithNavigationBar({
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });
  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staff = ref.watch(currentStaffProvider);
    final isCashier = staff?.role == StaffRole.cashier;
    final scheme = Theme.of(context).colorScheme;

    final shopId = staff?.shopId ?? '';
    final unread = shopId.isNotEmpty
        ? ref.watch(notificationsProvider(shopId)).value?.length ?? 0
        : 0;

    return Scaffold(
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(child: body),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          border: Border(
            top: BorderSide(color: scheme.outlineVariant.withOpacity(0.5)),
          ),
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          backgroundColor: Colors.transparent,
          elevation: 0,
          indicatorColor: scheme.primaryContainer,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: scheme.onSurfaceVariant),
              selectedIcon:
              Icon(Icons.home_rounded, color: scheme.onPrimaryContainer),
              label: AppLocalizations.of(context)!.navHome,
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined,
                  color: scheme.onSurfaceVariant),
              selectedIcon:
              Icon(Icons.receipt_long, color: scheme.onPrimaryContainer),
              label: AppLocalizations.of(context)!.navOrders,
            ),
            if (!isCashier) ...[
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: unread > 0,
                  label: Text(unread > 99 ? '99+' : '$unread'),
                  child: Icon(Icons.notifications_outlined,
                      color: scheme.onSurfaceVariant),
                ),
                selectedIcon: Badge(
                  isLabelVisible: unread > 0,
                  label: Text(unread > 99 ? '99+' : '$unread'),
                  child: Icon(Icons.notifications_rounded,
                      color: scheme.onPrimaryContainer),
                ),
                label: AppLocalizations.of(context)!.navAlerts,
              ),
              NavigationDestination(
                icon:
                Icon(Icons.tune_outlined, color: scheme.onSurfaceVariant),
                selectedIcon:
                Icon(Icons.tune, color: scheme.onPrimaryContainer),
                label: AppLocalizations.of(context)!.navSettings,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── compact navigation rail (no extended mode) ────────────────────────────────

class _ScaffoldWithNavigationRail extends ConsumerWidget {
  const _ScaffoldWithNavigationRail({
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });
  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staff = ref.watch(currentStaffProvider);
    final isCashier = staff?.role == StaffRole.cashier;
    final scheme = Theme.of(context).colorScheme;

    final shopId = staff?.shopId ?? '';
    final unread = shopId.isNotEmpty
        ? ref.watch(notificationsProvider(shopId)).value?.length ?? 0
        : 0;

    return Scaffold(
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    border: Border(
                      right: BorderSide(
                        color: scheme.outlineVariant.withOpacity(0.4),
                      ),
                    ),
                  ),
                  child: NavigationRail(
                    extended: false,
                    selectedIndex: selectedIndex,
                    onDestinationSelected: onDestinationSelected,
                    backgroundColor: Colors.transparent,
                    minWidth: 64,
                    useIndicator: true,
                    indicatorColor: scheme.primaryContainer,
                    selectedIconTheme: IconThemeData(
                      color: scheme.onPrimaryContainer,
                      size: 22,
                    ),
                    unselectedIconTheme: IconThemeData(
                      color: scheme.onSurfaceVariant,
                      size: 22,
                    ),
                    leading: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          // color: scheme.primary,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        // Replaced Icon with Image.asset
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0), // Padding to keep icon within container bounds
                            child: Image.asset(
                              'assets/images/logomark_icon.png',
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                    ),
                    destinations: [
                      NavigationRailDestination(
                        icon: Icon(Icons.home_outlined,
                            color: scheme.onSurfaceVariant),
                        selectedIcon: Icon(Icons.home_rounded,
                            color: scheme.onPrimaryContainer),
                        label: Text(AppLocalizations.of(context)!.navHome),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.receipt_long_outlined,
                            color: scheme.onSurfaceVariant),
                        selectedIcon: Icon(Icons.receipt_long,
                            color: scheme.onPrimaryContainer),
                        label: Text(AppLocalizations.of(context)!.navOrders),
                      ),
                      if (!isCashier) ...[
                        NavigationRailDestination(
                          icon: Badge(
                            isLabelVisible: unread > 0,
                            label: Text(unread > 99 ? '99+' : '$unread'),
                            child: Icon(Icons.notifications_outlined,
                                color: scheme.onSurfaceVariant),
                          ),
                          selectedIcon: Badge(
                            isLabelVisible: unread > 0,
                            label: Text(unread > 99 ? '99+' : '$unread'),
                            child: Icon(Icons.notifications_rounded,
                                color: scheme.onPrimaryContainer),
                          ),
                          label:
                          Text(AppLocalizations.of(context)!.navAlerts),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.tune_outlined,
                              color: scheme.onSurfaceVariant),
                          selectedIcon: Icon(Icons.tune,
                              color: scheme.onPrimaryContainer),
                          label:
                          Text(AppLocalizations.of(context)!.navSettings),
                        ),
                      ],
                    ],
                  ),
                ),
                Expanded(child: body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}