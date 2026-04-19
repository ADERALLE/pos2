import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_v1/core/viewmodels/staff_dashboard_viewmodel.dart';

class StaffDetailPage extends ConsumerStatefulWidget {
  const StaffDetailPage({super.key, required this.staff});
  final Map<String, dynamic> staff;

  @override
  ConsumerState<StaffDetailPage> createState() => _StaffDetailPageState();
}

class _StaffDetailPageState extends ConsumerState<StaffDetailPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      ref
          .read(staffShiftsProvider(widget.staff['id']).notifier)
          .loadMore(widget.staff['id']);
    }
  }

  @override
  Widget build(BuildContext context) {
    final staffId = widget.staff['id'] as String;
    final name = widget.staff['name'] as String;
    final statsAsync = ref.watch(staffStatsProvider(staffId));
    final shiftsAsync = ref.watch(staffShiftsProvider(staffId));
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            title: Text(name),
            pinned: true,
            floating: true,
            expandedHeight: 160,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      scheme.primaryContainer,
                      scheme.primaryContainer.withOpacity(0.5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 40),
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: scheme.primary,
                        child: Text(
                          name[0].toUpperCase(),
                          style: TextStyle(
                            color: scheme.onPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        (widget.staff['role'] ?? '') as String ,
                        style: TextStyle(
                          color: scheme.onPrimaryContainer.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // stats
          SliverToBoxAdapter(
            child: statsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => const SizedBox(),
              data: (s) => Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // row 1: shifts + orders
                    Row(
                      children: [
                        _StatCard(
                          label: 'Total shifts',
                          value: '${s['totalShifts']}',
                          icon: Icons.work_history_rounded,
                          color: scheme.primary,
                        ),
                        const SizedBox(width: 10),
                        _StatCard(
                          label: 'Total orders',
                          value: '${s['totalOrders']}',
                          icon: Icons.receipt_long_rounded,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 10),
                        _StatCard(
                          label: 'Avg shift',
                          value: '${s['avgShiftDuration']}m',
                          icon: Icons.timer_rounded,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // row 2: cash + card + total
                    Row(
                      children: [
                        _StatCard(
                          label: 'Cash',
                          value: '${(s['cashRevenue'] as num).toDouble().toStringAsFixed(2)} MAD',
                          icon: Icons.payments_rounded,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 10),
                        _StatCard(
                          label: 'Card',
                          value: '${(s['cardRevenue'] as num).toDouble().toStringAsFixed(2)} MAD',
                          icon: Icons.credit_card_rounded,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 10),
                        _StatCard(
                          label: 'Total revenue',
                          value: '${(s['totalRevenue'] as num).toDouble().toStringAsFixed(2)} MAD',
                          icon: Icons.account_balance_wallet_rounded,
                          color: Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // row 3: tips (conditional) + rotation (conditional) + cash to hand over (always)
                    Row(
                      children: [
                        if ((s['totalTips'] as num).toDouble() > 0) ...[
                          _StatCard(
                            label: 'Total tips',
                            value: '${(s['totalTips'] as num).toDouble().toStringAsFixed(2)} MAD',
                            icon: Icons.volunteer_activism_rounded,
                            color: Colors.purple,
                          ),
                          const SizedBox(width: 10),
                        ],
                        if ((s['rotationAmount'] as num).toDouble() > 0) ...[
                          _StatCard(
                            label: 'Rotation taken',
                            value: '${(s['rotationAmount'] as num).toDouble().toStringAsFixed(2)} MAD',
                            icon: Icons.rotate_right_rounded,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 10),
                        ],
                        _StatCard(
                          label: 'Cash to hand over',
                          value: '${(s['cashToHandOver'] as num).toDouble().toStringAsFixed(2)} MAD',
                          icon: Icons.savings_rounded,
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // shifts header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'Shift history',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface.withOpacity(0.6),
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),

          // shifts list
          shiftsAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) =>
                SliverFillRemaining(child: Center(child: Text('$e'))),
            data: (shifts) => shifts.isEmpty
                ? const SliverFillRemaining(
              child: Center(child: Text('No shifts yet')),
            )
                : SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (_, i) => _ShiftCard(shift: shifts[i]),
                  childCount: shifts.length,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: scheme.onSurface,
                    )),
                Text(label,
                    style: TextStyle(
                      fontSize: 10,
                      color: scheme.onSurface.withOpacity(0.5),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShiftCard extends StatelessWidget {
  const _ShiftCard({required this.shift});
  final Map<String, dynamic> shift;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final openedAt = DateTime.parse(shift['opened_at']);
    final closedAt = shift['closed_at'] != null
        ? DateTime.parse(shift['closed_at'])
        : null;
    final isActive = closedAt == null;
    final duration = (closedAt ?? DateTime.now()).difference(openedAt);
    final orders = shift['orders'] as List? ?? [];
    final done = orders.where((o) => o['status'] == 'done').toList();
    final cancelled = orders.where((o) => o['status'] == 'cancelled').length;

    // Use cash_amount / card_amount so split payments are accounted correctly.
    final cashRevenue = done
        .fold(0.0, (sum, o) => sum + (o['cash_amount'] as num? ?? 0).toDouble());
    final cardRevenue = done
        .fold(0.0, (sum, o) => sum + (o['card_amount'] as num? ?? 0).toDouble());
    final totalTips = done
        .fold(0.0, (sum, o) => sum + (o['tip'] as num? ?? 0).toDouble());
    final rotationAmount = (shift['rotation_amount'] as num? ?? 0).toDouble();
    final totalRevenue = cashRevenue + cardRevenue;
    final cashToHandOver = (cashRevenue + rotationAmount - totalTips).clamp(0.0, double.infinity);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8, height: 8,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.green : scheme.onSurface.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(
                    isActive ? 'Active' : 'Closed',
                    style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: isActive ? Colors.green : scheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
              Text('${duration.inHours}h ${duration.inMinutes % 60}m',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                      color: scheme.onSurface.withOpacity(0.6))),
            ],
          ),
          const SizedBox(height: 10),

          // times
          Row(
            children: [
              Expanded(child: _ShiftTime(label: 'Start', value: _fmt(openedAt), color: Colors.green)),
              const SizedBox(width: 8),
              Expanded(child: _ShiftTime(
                  label: 'End',
                  value: closedAt != null ? _fmt(closedAt) : '--:--',
                  color: scheme.error)),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // order badges
          Row(
            children: [
              _OrderBadge(label: '${orders.length} orders', color: scheme.primary),
              const SizedBox(width: 6),
              _OrderBadge(label: '${done.length} done', color: Colors.green),
              if (cancelled > 0) ...[
                const SizedBox(width: 6),
                _OrderBadge(label: '$cancelled cancelled', color: Colors.red),
              ],
            ],
          ),
          const SizedBox(height: 10),

          // row 1: cash + card + total
          Row(
            children: [
              Expanded(child: _RevenueTile(
                icon: Icons.payments_rounded,
                label: 'Cash',
                value: '${cashRevenue.toStringAsFixed(2)} MAD',
                color: Colors.green,
              )),
              const SizedBox(width: 8),
              Expanded(child: _RevenueTile(
                icon: Icons.credit_card_rounded,
                label: 'Card',
                value: '${cardRevenue.toStringAsFixed(2)} MAD',
                color: Colors.blue,
              )),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: _RevenueTile(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Total',
                  value: '${totalRevenue.toStringAsFixed(2)} MAD',
                  color: Colors.orange,
                  bold: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // row 2: tips (conditional) + rotation (conditional) + cash to hand over (always)
          Row(
            children: [
              if (totalTips > 0) ...[
                Expanded(child: _RevenueTile(
                  icon: Icons.volunteer_activism_rounded,
                  label: 'Tips',
                  value: '${totalTips.toStringAsFixed(2)} MAD',
                  color: Colors.purple,
                )),
                const SizedBox(width: 8),
              ],
              if (rotationAmount > 0) ...[
                Expanded(child: _RevenueTile(
                  icon: Icons.rotate_right_rounded,
                  label: 'Rotation',
                  value: '${rotationAmount.toStringAsFixed(2)} MAD',
                  color: Colors.orange,
                )),
                const SizedBox(width: 8),
              ],
              Expanded(
                flex: 2,
                child: _RevenueTile(
                  icon: Icons.savings_rounded,
                  label: 'Cash to hand over',
                  value: '${cashToHandOver.toStringAsFixed(2)} MAD',
                  color: Colors.green,
                  bold: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.day}/${dt.month} '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
}

class _RevenueTile extends StatelessWidget {
  const _RevenueTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.bold = false,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
                color: bold ? color : scheme.onSurface,
              )),
          Text(label,
              style: TextStyle(
                  fontSize: 10, color: scheme.onSurface.withOpacity(0.5))),
        ],
      ),
    );
  }
}

class _ShiftTime extends StatelessWidget {
  const _ShiftTime({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      color: scheme.onSurface.withOpacity(0.5))),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderBadge extends StatelessWidget {
  const _OrderBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}