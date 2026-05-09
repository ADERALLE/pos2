// lib/app/dashboard/shop_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_v1/core/viewmodels/auth_viewmodel.dart';
import 'package:pos_v1/core/viewmodels/shop_dashboard_viewmodel.dart';

// ── Page ──────────────────────────────────────────────────────────────────────

class ShopDashboardPage extends ConsumerStatefulWidget {
  const ShopDashboardPage({super.key});

  @override
  ConsumerState<ShopDashboardPage> createState() => _ShopDashboardPageState();
}

class _ShopDashboardPageState extends ConsumerState<ShopDashboardPage> {
  DateRange _range = DateRange.today();

  void _setMode(RangeMode mode) {
    setState(() {
      switch (mode) {
        case RangeMode.day:
          _range = DateRange.today();
        case RangeMode.nDays:
          _range = DateRange.lastNDays(7);
        case RangeMode.week:
          _range = DateRange.thisWeek();
        case RangeMode.month:
          _range = DateRange.thisMonth();
        case RangeMode.year:
          _range = DateRange.thisYear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final shopId = ref.watch(currentStaffProvider)?.shopId;
    final scheme = Theme.of(context).colorScheme;

    if (shopId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final summaryAsync = ref.watch(dailySummaryProvider(shopId, _range));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard'),
            Text(
              _range.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.onSurface.withOpacity(0.55),
              ),
            ),
          ],
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _RangePicker(
            selected: _range.mode,
            onModeChanged: _setMode,
            onPrevious: () => setState(() => _range = _range.previous()),
            onNext: () => setState(() => _range = _range.next()),
            canGoNext: !_range.isLatest,
          ),
        ),
      ),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          onRetry: () => ref.invalidate(dailySummaryProvider(shopId, _range)),
        ),
        data: (summary) => RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(dailySummaryProvider(shopId, _range)),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              // ── KPI grid ──────────────────────────────────────────────────
              _KpiGrid(summary: summary),

              const SizedBox(height: 28),

              // ── hourly chart ──────────────────────────────────────────────
              _SectionHeader(
                label: 'Orders by hour',
                trailing: summary.totalOrders == 0
                    ? null
                    : Text(
                  '${summary.totalOrders} total',
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurface.withOpacity(0.45),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _HourlyChart(
                buckets: summary.ordersByHour,
                color: scheme.primary,
              ),

              const SizedBox(height: 28),

              // ── top items ─────────────────────────────────────────────────
              if (summary.topItems.isNotEmpty) ...[
                const _SectionHeader(label: 'Top items'),
                const SizedBox(height: 10),
                ...summary.topItems.asMap().entries.map(
                      (e) => _TopItemTile(
                    rank: e.key + 1,
                    item: e.value,
                    maxQty: summary.topItems.first.quantity,
                  ),
                ),
              ] else
                _EmptyState(range: _range),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Range picker ──────────────────────────────────────────────────────────────

class _RangePicker extends StatelessWidget {
  const _RangePicker({
    required this.selected,
    required this.onModeChanged,
    required this.onPrevious,
    required this.onNext,
    required this.canGoNext,
  });

  final RangeMode selected;
  final ValueChanged<RangeMode> onModeChanged;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool canGoNext;

  static const _modes = [
    (RangeMode.day, '1D'),
    (RangeMode.nDays, '7D'),
    (RangeMode.week, 'W'),
    (RangeMode.month, 'M'),
    (RangeMode.year, 'Y'),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: Row(
        children: [
          // ← Prev
          _NavButton(
            icon: Icons.chevron_left_rounded,
            onTap: onPrevious,
          ),

          const SizedBox(width: 6),

          // Segmented tabs
          Expanded(
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: _modes.map((entry) {
                  final (mode, label) = entry;
                  final isSelected = selected == mode;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onModeChanged(mode),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? scheme.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(7),
                          boxShadow: isSelected
                              ? [
                            BoxShadow(
                              color: scheme.primary.withOpacity(0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            )
                          ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? scheme.onPrimary
                                : scheme.onSurface.withOpacity(0.55),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(width: 6),

          // → Next
          _NavButton(
            icon: Icons.chevron_right_rounded,
            onTap: canGoNext ? onNext : null,
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled
              ? scheme.onSurface.withOpacity(0.75)
              : scheme.onSurface.withOpacity(0.2),
        ),
      ),
    );
  }
}

// ── KPI grid ──────────────────────────────────────────────────────────────────

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.summary});
  final DailySummary summary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                icon: Icons.receipt_long_rounded,
                label: 'Orders',
                value: '${summary.totalOrders}',
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiCard(
                icon: Icons.payments_rounded,
                label: 'Revenue',
                value: '${summary.totalRevenue.toStringAsFixed(2)} MAD',
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                icon: Icons.money_rounded,
                label: 'Cash',
                value: '${summary.cashRevenue.toStringAsFixed(2)} MAD',
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiCard(
                icon: Icons.credit_card_rounded,
                label: 'Card',
                value: '${summary.cardRevenue.toStringAsFixed(2)} MAD',
                color: scheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                icon: Icons.insights_rounded,
                label: 'Avg order',
                value: '${summary.avgOrderValue.toStringAsFixed(2)} MAD',
                color: Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiCard(
                icon: Icons.volunteer_activism_rounded,
                label: 'Tips',
                value: '${summary.totalTips.toStringAsFixed(2)} MAD',
                color: Colors.pink,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── KPI card ──────────────────────────────────────────────────────────────────

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          Text(
            label,
            style: TextStyle(
                fontSize: 12, color: scheme.onSurface.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, this.trailing});
  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ── Hourly chart ──────────────────────────────────────────────────────────────

class _HourlyChart extends StatelessWidget {
  const _HourlyChart({required this.buckets, required this.color});
  final List<HourlyBucket> buckets;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxCount =
    buckets.map((b) => b.count).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: buckets.map((b) {
          final ratio = maxCount == 0 ? 0.0 : b.count / maxCount;
          final showLabel = b.hour % 6 == 0;
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: double.infinity,
                      height: ratio == 0 ? 2 : 80 * ratio,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: b.count > 0
                            ? color.withOpacity(0.75)
                            : scheme.outlineVariant.withOpacity(0.3),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  showLabel ? '${b.hour}h' : '',
                  style: TextStyle(
                    fontSize: 9,
                    color: scheme.onSurface.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Top item tile ─────────────────────────────────────────────────────────────

class _TopItemTile extends StatelessWidget {
  const _TopItemTile({
    required this.rank,
    required this.item,
    required this.maxQty,
  });
  final int rank;
  final TopItem item;
  final int maxQty;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ratio = maxQty == 0 ? 0.0 : item.quantity / maxQty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface.withOpacity(0.4),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 13),
                    ),
                    Text(
                      '×${item.quantity}',
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 4,
                    backgroundColor: scheme.outlineVariant.withOpacity(0.3),
                    valueColor:
                    AlwaysStoppedAnimation(scheme.primary.withOpacity(0.7)),
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

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.range});
  final DateRange range;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded,
              size: 48, color: scheme.onSurface.withOpacity(0.2)),
          const SizedBox(height: 12),
          Text(
            'No orders for ${range.label}',
            style: TextStyle(color: scheme.onSurface.withOpacity(0.4)),
          ),
        ],
      ),
    );
  }
}

// ── Error view ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded,
              size: 48, color: scheme.error.withOpacity(0.6)),
          const SizedBox(height: 12),
          Text(
            'Failed to load summary',
            style: TextStyle(color: scheme.onSurface.withOpacity(0.6)),
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}