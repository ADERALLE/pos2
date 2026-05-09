import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_v1/core/viewmodels/staff_dashboard_viewmodel.dart';

class StaffDetailPage extends ConsumerStatefulWidget {
  const StaffDetailPage({super.key, required this.staff});
  final Map<String, dynamic> staff;

  @override
  ConsumerState<StaffDetailPage> createState() => _StaffDetailPageState();
}

class _StaffDetailPageState extends ConsumerState<StaffDetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final staffId = widget.staff['id'] as String;
    final name = widget.staff['name'] as String;
    final latestShiftAsync = ref.watch(staffLatestShiftProvider(staffId));
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: NestedScrollView(
        physics: const BouncingScrollPhysics(),
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            title: Text(name),
            pinned: true,
            floating: true,
            expandedHeight: 160,
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Last Shift'),
                Tab(text: 'All Shifts'),
              ],
            ),
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
                        (widget.staff['role'] ?? '') as String,
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
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            // ── Tab 1: Last Shift ────────────────────────────────────────
            latestShiftAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (shift) {
                if (shift == null) {
                  return const Center(child: Text('No shifts yet'));
                }
                return _LastShiftTab(shift: shift);
              },
            ),

            // ── Tab 2: All Shifts — lazy, only loads when tab is opened ──
            _AllShiftsTab(staffId: staffId),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 2 — All shifts (lazy: providers only subscribe when this tab is rendered)
// ─────────────────────────────────────────────────────────────────────────────
class _AllShiftsTab extends ConsumerStatefulWidget {
  const _AllShiftsTab({required this.staffId});
  final String staffId;

  @override
  ConsumerState<_AllShiftsTab> createState() => _AllShiftsTabState();
}

class _AllShiftsTabState extends ConsumerState<_AllShiftsTab> {
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
          .read(staffShiftsProvider(widget.staffId).notifier)
          .loadMore(widget.staffId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final statsAsync = ref.watch(staffStatsProvider(widget.staffId));
    final shiftsAsync = ref.watch(staffShiftsProvider(widget.staffId));

    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: statsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => const SizedBox(),
            data: (s) => _AllTimeStats(stats: s),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: _SectionLabel('Shift history', scheme: scheme),
          ),
        ),
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 1 — Last shift full detail
// ─────────────────────────────────────────────────────────────────────────────
class _LastShiftTab extends StatelessWidget {
  const _LastShiftTab({required this.shift});
  final Map<String, dynamic> shift;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final openedAt = DateTime.parse(shift['opened_at']);
    final closedAt =
    shift['closed_at'] != null ? DateTime.parse(shift['closed_at']) : null;
    final isActive = closedAt == null;
    final duration = (closedAt ?? DateTime.now()).difference(openedAt);
    final orders = shift['orders'] as List? ?? [];
    final done = orders.where((o) => o['status'] == 'done').toList();
    final cancelled = orders.where((o) => o['status'] == 'cancelled').length;
    final pending = orders.where((o) => o['status'] == 'pending').length;

    final cashRevenue = done.fold(
        0.0, (s, o) => s + (o['cash_amount'] as num? ?? 0).toDouble());
    final cardRevenue = done.fold(
        0.0, (s, o) => s + (o['card_amount'] as num? ?? 0).toDouble());
    final totalTips =
    done.fold(0.0, (s, o) => s + (o['tip'] as num? ?? 0).toDouble());
    final passationAmount =
    (shift['passation_amount'] as num? ?? 0).toDouble();
    final totalRevenue = cashRevenue + cardRevenue;
    final cashToHandOver =
    (cashRevenue + passationAmount - totalTips).clamp(0.0, double.infinity);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Status chip + duration ─────────────────────────────────
          Row(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isActive ? Colors.green : scheme.onSurface)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.green
                            : scheme.onSurface.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      isActive ? 'Active shift' : 'Closed shift',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? Colors.green
                            : scheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '${duration.inHours}h ${duration.inMinutes % 60}m',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Start / End times ──────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _ShiftTime(
                  label: 'Start',
                  value: _fmt(openedAt),
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ShiftTime(
                  label: 'End',
                  value: closedAt != null ? _fmt(closedAt) : '--:--',
                  color: scheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Cash to hand over — HERO ───────────────────────────────
          _CashHandoverBanner(cashToHandOver: cashToHandOver),
          const SizedBox(height: 20),

          // ── Orders summary ─────────────────────────────────────────
          _SectionLabel('Orders', scheme: scheme),
          const SizedBox(height: 10),
          Row(
            children: [
              _MiniStatCard(
                label: 'Total',
                value: '${orders.length}',
                icon: Icons.receipt_long_rounded,
                color: scheme.primary,
              ),
              const SizedBox(width: 8),
              _MiniStatCard(
                label: 'Done',
                value: '${done.length}',
                icon: Icons.check_circle_outline_rounded,
                color: Colors.green,
              ),
              const SizedBox(width: 8),
              _MiniStatCard(
                label: 'Cancelled',
                value: '$cancelled',
                icon: Icons.cancel_outlined,
                color: Colors.red,
              ),
              if (pending > 0) ...[
                const SizedBox(width: 8),
                _MiniStatCard(
                  label: 'Pending',
                  value: '$pending',
                  icon: Icons.hourglass_empty_rounded,
                  color: Colors.orange,
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),

          // ── Revenue breakdown ──────────────────────────────────────
          _SectionLabel('Revenue', scheme: scheme),
          const SizedBox(height: 10),
          Row(
            children: [
              _RevenueStatCard(
                label: 'Cash',
                value: cashRevenue,
                icon: Icons.payments_rounded,
                color: Colors.green,
              ),
              const SizedBox(width: 8),
              _RevenueStatCard(
                label: 'Card',
                value: cardRevenue,
                icon: Icons.credit_card_rounded,
                color: Colors.blue,
              ),
              const SizedBox(width: 8),
              _RevenueStatCard(
                label: 'Total',
                value: totalRevenue,
                icon: Icons.account_balance_wallet_rounded,
                color: Colors.orange,
                bold: true,
              ),
            ],
          ),

          // ── Tips & passation (conditional) ─────────────────────────
          if (totalTips > 0 || passationAmount > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (totalTips > 0) ...[
                  _RevenueStatCard(
                    label: 'Tips',
                    value: totalTips,
                    icon: Icons.volunteer_activism_rounded,
                    color: Colors.purple,
                  ),
                  const SizedBox(width: 8),
                ],
                if (passationAmount > 0)
                  _RevenueStatCard(
                    label: 'Passation',
                    value: passationAmount,
                    icon: Icons.rotate_right_rounded,
                    color: Colors.deepOrange,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.day}/${dt.month} '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 2 — All-time stats block
// ─────────────────────────────────────────────────────────────────────────────
class _AllTimeStats extends StatelessWidget {
  const _AllTimeStats({required this.stats});
  final Map<String, dynamic> stats;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final cashRevenue = (stats['cashRevenue'] as num).toDouble();
    final cardRevenue = (stats['cardRevenue'] as num).toDouble();
    final totalRevenue = (stats['totalRevenue'] as num).toDouble();
    final totalTips = (stats['totalTips'] as num).toDouble();
    final passationAmount = (stats['passationAmount'] as num).toDouble();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel('Overview', scheme: scheme),
          const SizedBox(height: 10),
          Row(
            children: [
              _MiniStatCard(
                label: 'Shifts',
                value: '${stats['totalShifts']}',
                icon: Icons.work_history_rounded,
                color: scheme.primary,
              ),
              const SizedBox(width: 8),
              _MiniStatCard(
                label: 'Orders',
                value: '${stats['totalOrders']}',
                icon: Icons.receipt_long_rounded,
                color: Colors.orange,
              ),
              const SizedBox(width: 8),
              _MiniStatCard(
                label: 'Avg shift',
                value: '${stats['avgShiftDuration']}m',
                icon: Icons.timer_rounded,
                color: Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SectionLabel('Revenue breakdown', scheme: scheme),
          const SizedBox(height: 10),
          Row(
            children: [
              _RevenueStatCard(
                label: 'Cash',
                value: cashRevenue,
                icon: Icons.payments_rounded,
                color: Colors.green,
              ),
              const SizedBox(width: 8),
              _RevenueStatCard(
                label: 'Card',
                value: cardRevenue,
                icon: Icons.credit_card_rounded,
                color: Colors.blue,
              ),
              const SizedBox(width: 8),
              _RevenueStatCard(
                label: 'Total',
                value: totalRevenue,
                icon: Icons.account_balance_wallet_rounded,
                color: Colors.orange,
                bold: true,
              ),
            ],
          ),
          if (totalTips > 0 || passationAmount > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (totalTips > 0) ...[
                  _RevenueStatCard(
                    label: 'Tips',
                    value: totalTips,
                    icon: Icons.volunteer_activism_rounded,
                    color: Colors.purple,
                  ),
                  const SizedBox(width: 8),
                ],
                if (passationAmount > 0)
                  _RevenueStatCard(
                    label: 'Passation',
                    value: passationAmount,
                    icon: Icons.rotate_right_rounded,
                    color: Colors.deepOrange,
                  ),
              ],
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cash to hand over — hero banner (Last Shift tab only)
// ─────────────────────────────────────────────────────────────────────────────
class _CashHandoverBanner extends StatelessWidget {
  const _CashHandoverBanner({required this.cashToHandOver});
  final double cashToHandOver;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.green.shade600,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.savings_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cash to hand over',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${cashToHandOver.toStringAsFixed(2)} MAD',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shift card — used in All Shifts list
// ─────────────────────────────────────────────────────────────────────────────
class _ShiftCard extends StatelessWidget {
  const _ShiftCard({required this.shift});
  final Map<String, dynamic> shift;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final openedAt = DateTime.parse(shift['opened_at']);
    final closedAt =
    shift['closed_at'] != null ? DateTime.parse(shift['closed_at']) : null;
    final isActive = closedAt == null;
    final duration = (closedAt ?? DateTime.now()).difference(openedAt);
    final orders = shift['orders'] as List? ?? [];
    final done = orders.where((o) => o['status'] == 'done').toList();
    final cancelled = orders.where((o) => o['status'] == 'cancelled').length;

    final cashRevenue = done.fold(
        0.0, (s, o) => s + (o['cash_amount'] as num? ?? 0).toDouble());
    final cardRevenue = done.fold(
        0.0, (s, o) => s + (o['card_amount'] as num? ?? 0).toDouble());
    final totalTips =
    done.fold(0.0, (s, o) => s + (o['tip'] as num? ?? 0).toDouble());
    final passationAmount =
    (shift['passation_amount'] as num? ?? 0).toDouble();
    final totalRevenue = cashRevenue + cardRevenue;
    final cashToHandOver =
    (cashRevenue + passationAmount - totalTips).clamp(0.0, double.infinity);

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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.green
                          : scheme.onSurface.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(
                    isActive ? 'Active' : 'Closed',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? Colors.green
                          : scheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
              Text(
                '${duration.inHours}h ${duration.inMinutes % 60}m',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Times
          Row(
            children: [
              Expanded(
                child: _ShiftTime(
                  label: 'Start',
                  value: _fmt(openedAt),
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ShiftTime(
                  label: 'End',
                  value: closedAt != null ? _fmt(closedAt) : '--:--',
                  color: scheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Order badges
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

          // Revenue
          Row(
            children: [
              Expanded(
                child: _RevenueTile(
                  icon: Icons.payments_rounded,
                  label: 'Cash',
                  value: cashRevenue,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _RevenueTile(
                  icon: Icons.credit_card_rounded,
                  label: 'Card',
                  value: cardRevenue,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: _RevenueTile(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Total',
                  value: totalRevenue,
                  color: Colors.orange,
                  bold: true,
                ),
              ),
            ],
          ),

          if (totalTips > 0 || passationAmount > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (totalTips > 0) ...[
                  Expanded(
                    child: _RevenueTile(
                      icon: Icons.volunteer_activism_rounded,
                      label: 'Tips',
                      value: totalTips,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (passationAmount > 0)
                  Expanded(
                    child: _RevenueTile(
                      icon: Icons.rotate_right_rounded,
                      label: 'Passation',
                      value: passationAmount,
                      color: Colors.deepOrange,
                    ),
                  ),
              ],
            ),
          ],

          // Cash to hand over — always last, always visible
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.withOpacity(0.35)),
            ),
            child: Row(
              children: [
                const Icon(Icons.savings_rounded, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Cash to hand over',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${cashToHandOver.toStringAsFixed(2)} MAD',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Shared small widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, {required this.scheme});
  final String text;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: scheme.onSurface.withOpacity(0.45),
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: scheme.onSurface,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: scheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RevenueStatCard extends StatelessWidget {
  const _RevenueStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.bold = false,
  });
  final String label;
  final double value;
  final IconData icon;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: bold ? color.withOpacity(0.4) : color.withOpacity(0.15),
            width: bold ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                  color: bold ? color : scheme.onSurface,
                ),
              ),
            ),
            Text(
              'MAD',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: color.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: scheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
  final double value;
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
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '${value.toStringAsFixed(2)} MAD',
              style: TextStyle(
                fontSize: 11,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
                color: bold ? color : scheme.onSurface,
              ),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: scheme.onSurface.withOpacity(0.5),
            ),
          ),
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
      child: Text(
        label,
        style: TextStyle(
            fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}