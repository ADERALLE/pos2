import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_v1/core/appconstants.dart';
import 'package:pos_v1/core/viewmodels/staff_dashboard_viewmodel.dart';

class StaffDashboardPage extends ConsumerWidget {
  const StaffDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffAsync = ref.watch(staffListProvider(AppConstants.shopId));

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const SliverAppBar(
            title: Text('Staff dashboard'),
            pinned: true,
            floating: true,
          ),
          staffAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('$e')),
            ),
            data: (staffList) => SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (_, i) => _StaffListTile(staff: staffList[i]),
                  childCount: staffList.length,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StaffListTile extends ConsumerWidget {
  const _StaffListTile({required this.staff});
  final Map<String, dynamic> staff;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final statsAsync = ref.watch(staffStatsProvider(staff['id']));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          child: Text(
            (staff['name'] as String)[0].toUpperCase(),
            style: TextStyle(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        title: Text(staff['name'],
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: statsAsync.when(
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('—'),
          data: (s) => Text(
            '${s['totalShifts']} shifts · '
                '${s['totalOrders']} orders · '
                '${(s['totalRevenue'] as double).toStringAsFixed(2)} MAD',
            style: TextStyle(
                fontSize: 12, color: scheme.onSurface.withOpacity(0.5)),
          ),
        ),
        trailing: Icon(Icons.chevron_right,
            color: scheme.onSurface.withOpacity(0.3)),
        onTap: () => context.go(
          '/settings/staff-dashboard/${staff['id']}',
          extra: staff,
        ),
      ),
    );
  }
}