import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_v1/app/shared/offline_banner.dart';
import 'package:pos_v1/core/models/staff.dart';
import 'package:pos_v1/core/services/sync_service.dart';
import 'package:pos_v1/core/viewmodels/auth_viewmodel.dart';
import 'package:pos_v1/core/viewmodels/notification_viewmodel.dart';

class ScaffoldWithNestedNavigation extends ConsumerWidget {
  const ScaffoldWithNestedNavigation({
    Key? key,
    required this.navigationShell,
  }) : super(key: key ?? const ValueKey('ScaffoldWithNestedNavigation'));

  final StatefulNavigationShell navigationShell;

  void _goBranch(BuildContext context, WidgetRef ref, int index) {
    final staff = ref.read(currentStaffProvider);
    final isCashier = staff?.role == StaffRole.cashier;
    if (isCashier && index >= 3) return;
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Bootstrap the sync service once at shell level.
    // It watches connectivity and drains the queue automatically.
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
        return _ScaffoldWithNavigationRail(
          body: navigationShell,
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (i) => _goBranch(context, ref, i),
          isExtended: constraints.maxWidth >= 900,
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
          // Offline / syncing banner sits above all page content
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
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined,
                  color: scheme.onSurfaceVariant),
              selectedIcon:
              Icon(Icons.receipt_long, color: scheme.onPrimaryContainer),
              label: 'Orders',
            ),
            if (!isCashier)
             ...[
               NavigationDestination(
                 icon: Badge(
                   isLabelVisible: unread > 0,
                   label: Text(unread > 99 ? '99+' : '$unread'),
                   child: Icon(Icons.notifications_outlined, color: scheme.onSurfaceVariant),
                 ),
                 selectedIcon: Badge(
                   isLabelVisible: unread > 0,
                   label: Text(unread > 99 ? '99+' : '$unread'),
                   child: Icon(Icons.notifications_rounded, color: scheme.onPrimaryContainer),
                 ),
                 label: 'Alerts',
               ),
               NavigationDestination(
                icon: Icon(Icons.tune_outlined, color: scheme.onSurfaceVariant),
                selectedIcon:
                Icon(Icons.tune, color: scheme.onPrimaryContainer),
                label: 'Settings',
              ),
             ]
          ],
        ),
      ),
    );
  }
}

// ── navigation rail ───────────────────────────────────────────────────────────

class _ScaffoldWithNavigationRail extends ConsumerWidget {
  const _ScaffoldWithNavigationRail({
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.isExtended,
  });
  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool isExtended;

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
          // Offline / syncing banner spans full width above the rail+body
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
                    extended: isExtended,
                    selectedIndex: selectedIndex,
                    onDestinationSelected: onDestinationSelected,
                    backgroundColor: Colors.transparent,
                    minWidth: 64,
                    minExtendedWidth: 180,
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
                    selectedLabelTextStyle: TextStyle(
                      color: scheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                    unselectedLabelTextStyle: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    leading: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: isExtended
                          ? Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.coffee_rounded,
                                color: scheme.onPrimary,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'POS',
                              style: TextStyle(
                                color: scheme.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      )
                          : Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.coffee_rounded,
                          color: scheme.onPrimary,
                          size: 18,
                        ),
                      ),
                    ),
                    destinations: [
                      NavigationRailDestination(
                        icon: Icon(Icons.home_outlined,
                            color: scheme.onSurfaceVariant),
                        selectedIcon: Icon(Icons.home_rounded,
                            color: scheme.onPrimaryContainer),
                        label: const Text('Home'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.receipt_long_outlined,
                            color: scheme.onSurfaceVariant),
                        selectedIcon: Icon(Icons.receipt_long,
                            color: scheme.onPrimaryContainer),
                        label: const Text('Orders'),
                      ),
                      if (!isCashier)
                        ...[

                          NavigationRailDestination(
                            icon: Badge(
                              isLabelVisible: unread > 0,
                              label: Text(unread > 99 ? '99+' : '$unread'),
                              child: Icon(Icons.notifications_outlined, color: scheme.onSurfaceVariant),
                            ),
                            selectedIcon: Badge(
                              isLabelVisible: unread > 0,
                              label: Text(unread > 99 ? '99+' : '$unread'),
                              child: Icon(Icons.notifications_rounded, color: scheme.onPrimaryContainer),
                            ),
                            label: const Text('Alerts'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.tune_outlined,
                                color: scheme.onSurfaceVariant),
                            selectedIcon: Icon(Icons.tune,
                                color: scheme.onPrimaryContainer),
                            label: const Text('Settings'),
                          ),
                        ]
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