import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/order.dart';
import '../../core/models/order_item.dart';
import '../../core/models/shift.dart';
import '../../core/repositories/order_repository.dart';
import '../../core/viewmodels/inventory_viewmodel.dart';
import '../../i10n/app_localizations.dart';

class ShiftSummaryPage extends ConsumerWidget {
  const ShiftSummaryPage({super.key, required this.shift});
  final Shift shift;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: ref.read(orderRepositoryProvider).getShiftSummary(shift.id),
        builder: (context, snapshot) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                title: Text(AppLocalizations.of(context)!.shiftSummary),
                pinned: true,
                automaticallyImplyLeading: false,
                actions: [
                  TextButton.icon(
                    icon: const Icon(Icons.home_rounded),
                    label: Text(AppLocalizations.of(context)!.dashboard),
                    onPressed: () => context.go('/home'),
                  ),
                ],
              ),
              if (snapshot.connectionState == ConnectionState.waiting)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (snapshot.hasError)
                SliverFillRemaining(
                  child: Center(child: Text('${snapshot.error}')),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _ShiftHeaderCard(shift: shift),
                      const SizedBox(height: 20),
                      _ShiftStatsBody(
                        shift: shift,
                        data: snapshot.data!,
                      ),
                      const SizedBox(height: 32),
                    ]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ── Shift header card (status + times) ───────────────────────────────────────

class _ShiftHeaderCard extends StatelessWidget {
  const _ShiftHeaderCard({required this.shift});
  final Shift shift;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final openedAt = shift.openedAt;
    final closedAt = shift.closedAt ?? DateTime.now();
    final isClosed = shift.closedAt != null;
    final duration = closedAt.difference(openedAt);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status + duration
          Row(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isClosed ? scheme.onSurface : Colors.green)
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
                        color: isClosed
                            ? scheme.onSurface.withOpacity(0.4)
                            : Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      isClosed
                          ? AppLocalizations.of(context)!.shiftClosed
                          : 'Active shift',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isClosed
                            ? scheme.onSurface.withOpacity(0.6)
                            : Colors.green,
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
          // Start / End times
          Row(
            children: [
              Expanded(
                child: _ShiftTime(
                  label: AppLocalizations.of(context)!.started,
                  value: _fmt(openedAt),
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ShiftTime(
                  label: AppLocalizations.of(context)!.closed,
                  value: shift.closedAt != null ? _fmt(closedAt) : '--:--',
                  color: scheme.error,
                ),
              ),
            ],
          ),
          // Notes
          if (shift.openingNote != null || shift.closingNote != null) ...[
            const Divider(height: 24),
            if (shift.openingNote != null)
              _NoteRow(
                icon: Icons.play_arrow_rounded,
                color: Colors.green,
                note: shift.openingNote!,
              ),
            if (shift.closingNote != null)
              _NoteRow(
                icon: Icons.stop_rounded,
                color: scheme.error,
                note: shift.closingNote!,
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

// ── Stats body (hero banner + mini cards + orders) ────────────────────────────

class _ShiftStatsBody extends ConsumerWidget {
  const _ShiftStatsBody({required this.shift, required this.data});
  final Shift shift;
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final orders = data['orders'] as List<Order>;
    final done = orders.where((o) => o.status == OrderStatus.done).toList();
    final cancelled =
        orders.where((o) => o.status == OrderStatus.cancelled).length;
    final pending =
        orders.where((o) => o.status == OrderStatus.pending).length;

    final cashRevenue = (data['cashRevenue'] as num).toDouble();
    final cardRevenue = (data['cardRevenue'] as num).toDouble();
    final totalRevenue = (data['totalRevenue'] as num).toDouble();
    final totalTips = (data['totalTips'] as num? ?? 0).toDouble();
    final passationAmount = shift.passationAmount;
    final cashToHandOver =
    (cashRevenue + passationAmount - totalTips).clamp(0.0, double.infinity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Hero: cash to hand over ────────────────────────────────────
        _CashHandoverBanner(cashToHandOver: cashToHandOver),
        const SizedBox(height: 20),

        // ── Orders summary ─────────────────────────────────────────────
        _SectionLabel(l10n.orders, scheme: scheme),
        const SizedBox(height: 10),
        Row(
          children: [
            _MiniStatCard(
              label: l10n.ordersCount,
              value: '${orders.length}',
              icon: Icons.receipt_long_rounded,
              color: scheme.primary,
            ),
            const SizedBox(width: 8),
            _MiniStatCard(
              label: l10n.done,
              value: '${done.length}',
              icon: Icons.check_circle_outline_rounded,
              color: Colors.green,
            ),
            const SizedBox(width: 8),
            _MiniStatCard(
              label: l10n.cancelled,
              value: '$cancelled',
              icon: Icons.cancel_outlined,
              color: Colors.red,
            ),
            if (pending > 0) ...[
              const SizedBox(width: 8),
              _MiniStatCard(
                label: l10n.pending,
                value: '$pending',
                icon: Icons.hourglass_empty_rounded,
                color: Colors.orange,
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),

        // ── Revenue breakdown ──────────────────────────────────────────
        _SectionLabel(l10n.totalRevenue, scheme: scheme),
        const SizedBox(height: 10),
        Row(
          children: [
            _RevenueStatCard(
              label: l10n.cash,
              value: cashRevenue,
              icon: Icons.payments_rounded,
              color: Colors.green,
            ),
            const SizedBox(width: 8),
            _RevenueStatCard(
              label: l10n.card,
              value: cardRevenue,
              icon: Icons.credit_card_rounded,
              color: Colors.blue,
            ),
            const SizedBox(width: 8),
            _RevenueStatCard(
              label: l10n.totalRevenue,
              value: totalRevenue,
              icon: Icons.account_balance_wallet_rounded,
              color: Colors.orange,
              bold: true,
            ),
          ],
        ),

        // Tips & passation (conditional)
        if (totalTips > 0 || passationAmount > 0) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              if (totalTips > 0) ...[
                _RevenueStatCard(
                  label: l10n.tipsCard,
                  value: totalTips,
                  icon: Icons.volunteer_activism_rounded,
                  color: Colors.purple,
                ),
                const SizedBox(width: 8),
              ],
              if (passationAmount > 0)
                _RevenueStatCard(
                  label: l10n.passation,
                  value: passationAmount,
                  icon: Icons.rotate_right_rounded,
                  color: Colors.deepOrange,
                ),
            ],
          ),
        ],

        // ── Order list ─────────────────────────────────────────────────
        if (orders.isNotEmpty) ...[          const SizedBox(height: 24),
          _SectionLabel(
              '${l10n.ordersCount} (${orders.length})',
              scheme: scheme),
          const SizedBox(height: 8),
          ...orders.map((o) => _OrderTile(order: o)),
        ],

        // ── Stock usage ──────────────────────────────────────────────────────────
        const SizedBox(height: 24),
        _StockUsageSection(shiftId: shift.id, ref: ref),
      ],
    );
  }
}

// ── Stock Usage Section ───────────────────────────────────────────────────────

class _StockUsageSection extends StatelessWidget {
  const _StockUsageSection({required this.shiftId, required this.ref});
  final String shiftId;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final usageAsync = ref.watch(shiftStockUsageProvider(shiftId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(l10n.shiftStockUsage, scheme: scheme),
        const SizedBox(height: 10),
        usageAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('$e',
              style: TextStyle(color: scheme.error, fontSize: 12)),
          data: (rows) {
            if (rows.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  l10n.noStockDataForShift,
                  style: TextStyle(
                      color: scheme.onSurface.withOpacity(0.5),
                      fontSize: 13),
                ),
              );
            }
            return Column(
              children: rows.map((row) {
                final label = row['label'] as String;
                final unit = row['unit_type'] as String;
                final usage = (row['expected_usage'] as double);
                final refills = (row['manual_refills'] as double);
                final adjustments = (row['adjustments'] as double);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: scheme.outlineVariant.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(label,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(
                              '${l10n.stockExpectedUsage}: ${usage.toStringAsFixed(1)} $unit',
                              style: TextStyle(
                                  fontSize: 11,
                                  color:
                                      scheme.onSurface.withOpacity(0.6)),
                            ),
                          ],
                        ),
                      ),
                      if (refills > 0)
                        _StockBadge(
                          value: '+${refills.toStringAsFixed(1)}',
                          label: l10n.stockManualRefills,
                          color: Colors.green,
                        ),
                      if (adjustments != 0) ...[
                        const SizedBox(width: 6),
                        _StockBadge(
                          value: adjustments > 0
                              ? '+${adjustments.toStringAsFixed(1)}'
                              : adjustments.toStringAsFixed(1),
                          label: l10n.stockAdjustments,
                          color: Colors.orange,
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _StockBadge extends StatelessWidget {
  const _StockBadge(
      {required this.value, required this.label, required this.color});
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: color)),
          Text(label,
              style: TextStyle(
                  fontSize: 9, color: color.withOpacity(0.8))),
        ],
      ),
    );
  }
}

// ── Shared small widgets ──────────────────────────────────────────────────────


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
            child:
            const Icon(Icons.savings_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.cashToHandOver,
                  style: const TextStyle(
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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

class _NoteRow extends StatelessWidget {
  const _NoteRow({required this.icon, required this.color, required this.note});
  final IconData icon;
  final Color color;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              note,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Order tile (expandable) ───────────────────────────────────────────────────

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final statusColor = switch (order.status) {
      OrderStatus.pending => Colors.orange,
      OrderStatus.inprogress => Colors.blue,
      OrderStatus.done => Colors.green,
      OrderStatus.cancelled => Colors.red,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.3)),
      ),
      child: ExpansionTile(
        tilePadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child:
          Icon(Icons.receipt_long_rounded, color: statusColor, size: 18),
        ),
        title: Text(
          order.tableLabel ?? AppLocalizations.of(context)!.takeaway,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        subtitle: Text(
          '${order.orderItems.length} items · ${order.total.toStringAsFixed(2)} MAD',
          style: TextStyle(
              fontSize: 12, color: scheme.onSurface.withOpacity(0.5)),
        ),
        trailing: Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            order.status.name,
            style: TextStyle(
              fontSize: 11,
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        children: <Widget>[
          ...order.orderItems
              .where((item) => !item.name.contains(' – '))
              .map((item) => ListTile(
            dense: true,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16),
            title: Text(item.name,
                style: const TextStyle(fontSize: 13)),
            trailing: Text(
              '${item.quantity} × ${item.unitPrice.toStringAsFixed(2)} MAD',
              style: const TextStyle(fontSize: 12),
            ),
          )),
          ..._buildComboGroupTiles(order),
        ],
      ),
    );
  }

  static const _sep = ' \u2013 ';

  List<Widget> _buildComboGroupTiles(Order order) {
    final Map<String, List<OrderItem>> groups = {};
    for (final item in order.orderItems) {
      final idx = item.name.indexOf(_sep);
      if (idx > 0) {
        final comboName = item.name.substring(0, idx);
        groups.putIfAbsent(comboName, () => []).add(item);
      }
    }
    if (groups.isEmpty) return [];
    return groups.entries.map((e) {
      final comboPrice =
      e.value.fold<double>(0, (s, i) => s + i.unitPrice * i.quantity);
      final subItems = e.value.map((i) {
        final sub = i.name.substring(i.name.indexOf(_sep) + _sep.length);
        return '${i.quantity}x $sub';
      }).join(', ');
      return ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: const Icon(Icons.restaurant_menu, size: 16),
        title: Text(e.key,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600)),
        subtitle:
        Text(subItems, style: const TextStyle(fontSize: 11)),
        trailing: Text(
          '${comboPrice.toStringAsFixed(2)} MAD',
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600),
        ),
      );
    }).toList();
  }
}
