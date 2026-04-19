// lib/app/dashboard/shop_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_v1/core/viewmodels/auth_viewmodel.dart';
import 'package:pos_v1/core/viewmodels/shop_dashboard_viewmodel.dart';

class ShopDashboardPage extends ConsumerWidget {
  const ShopDashboardPage({super.key, required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopId = ref.watch(currentStaffProvider)?.shopId;
    final scheme = Theme.of(context).colorScheme;

    if (shopId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final summaryAsync = ref.watch(dailySummaryProvider(shopId, date));

    return Scaffold(
      appBar: AppBar(
        title: Text(_formatDate(date)),
        centerTitle: false,
      ),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 48, color: scheme.error.withOpacity(0.6)),
              const SizedBox(height: 12),
              Text('Failed to load summary',
                  style: TextStyle(color: scheme.onSurface.withOpacity(0.6))),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () =>
                    ref.invalidate(dailySummaryProvider(shopId, date)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (summary) => RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(dailySummaryProvider(shopId, date)),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── KPI row 1 ──
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

              // ── KPI row 2 ──
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

              // ── KPI row 3 ──
              Row(
                children: [
                  Expanded(
                    child: _KpiCard(
                      icon: Icons.insights,
                      label: 'Avg order',
                      value:
                      '${summary.avgOrderValue.toStringAsFixed(2)} MAD',
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

              const SizedBox(height: 24),

              // ── hourly chart ──
              Text('Orders by hour',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              _HourlyChart(buckets: summary.ordersByHour, color: scheme.primary),

              const SizedBox(height: 24),

              // ── top items ──
              if (summary.topItems.isNotEmpty) ...[
                Text('Top items',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...summary.topItems.asMap().entries.map(
                      (e) => _TopItemTile(
                    rank: e.key + 1,
                    item: e.value,
                    maxQty: summary.topItems.first.quantity,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month]} ${date.day}, ${date.year}';
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
          Text(value,
              style:
              const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: scheme.onSurface.withOpacity(0.5))),
        ],
      ),
    );
  }
}

// ── hourly bar chart ──────────────────────────────────────────────────────────

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
                      color: scheme.onSurface.withOpacity(0.4)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── top item tile ─────────────────────────────────────────────────────────────

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
            child: Text('$rank',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface.withOpacity(0.4))),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 13)),
                    Text('×${item.quantity}',
                        style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurface.withOpacity(0.5))),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 4,
                    backgroundColor: scheme.outlineVariant.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation(
                        scheme.primary.withOpacity(0.7)),
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