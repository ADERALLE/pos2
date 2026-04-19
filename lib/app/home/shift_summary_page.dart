import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/order.dart';
import '../../core/models/order_item.dart';
import '../../core/models/shift.dart';
import '../../core/repositories/order_repository.dart';
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
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _ShiftInfoCard(shift: shift),
                      const SizedBox(height: 12),
                      _StatsRow(data: snapshot.data!),
                      const SizedBox(height: 24),
                      if ((snapshot.data!['orders'] as List<Order>).isNotEmpty) ...[
                        _SectionLabel(label: '${AppLocalizations.of(context)!.ordersCount} (${(snapshot.data!['orders'] as List<Order>).length})'),
                        const SizedBox(height: 8),
                        ...(snapshot.data!['orders'] as List<Order>)
                            .map((o) => _OrderTile(order: o)),
                      ],
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

// ── shift info card ───────────────────────────────────────────────────────────

class _ShiftInfoCard extends StatelessWidget {
  const _ShiftInfoCard({required this.shift});
  final Shift shift;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final openedAt = shift.openedAt;
    final closedAt = shift.closedAt ?? DateTime.now();
    final duration = closedAt.difference(openedAt);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.4)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.green, size: 14),
                    const SizedBox(width: 4),
                    Text(AppLocalizations.of(context)!.shiftClosed,
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        )),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '${hours}h ${minutes}m',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _TimeBlock(
                  label: AppLocalizations.of(context)!.started,
                  time: _fmt(openedAt),
                  icon: Icons.play_arrow_rounded,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TimeBlock(
                  label: AppLocalizations.of(context)!.closed,
                  time: shift.closedAt != null ? _fmt(closedAt) : '--:--',
                  icon: Icons.stop_rounded,
                  color: scheme.error,
                ),
              ),
            ],
          ),
          if (shift.passationAmount > 0) ...[
            const SizedBox(height: 4),
            _NoteRow(
              icon: Icons.rotate_right_rounded,
              color: Colors.orange,
              note: '${AppLocalizations.of(context)!.passation}: ${shift.passationAmount.toStringAsFixed(2)} MAD',
            ),
          ],
          if (shift.openingNote != null || shift.closingNote != null) ...[
            const Divider(height: 24),
            if (shift.openingNote != null)
              _NoteRow(icon: Icons.play_arrow_rounded, color: Colors.green, note: shift.openingNote!),
            if (shift.closingNote != null)
              _NoteRow(icon: Icons.stop_rounded, color: scheme.error, note: shift.closingNote!),
          ],
        ],
      ),
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

class _TimeBlock extends StatelessWidget {
  const _TimeBlock({
    required this.label,
    required this.time,
    required this.icon,
    required this.color,
  });
  final String label;
  final String time;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                    fontSize: 11,
                    color: scheme.onSurface.withOpacity(0.5),
                  )),
              Text(time,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  )),
            ],
          ),
        ],
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
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(note,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
          ),
        ],
      ),
    );
  }
}

// ── stats row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _StatCard(label: l10n.total, value: '${data['totalOrders']}',
                icon: Icons.receipt_long_rounded, color: Colors.grey)),
            const SizedBox(width: 8),
            Expanded(child: _StatCard(label: l10n.done, value: '${data['doneOrders']}',
                icon: Icons.check_circle_rounded, color: Colors.green)),
            const SizedBox(width: 8),
            Expanded(child: _StatCard(label: l10n.cancelled, value: '${data['cancelledOrders']}',
                icon: Icons.cancel_rounded, color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _StatCard(
              label: l10n.cash,
              value: '${(data['cashRevenue'] as num).toDouble().toStringAsFixed(2)} MAD',
              icon: Icons.payments_rounded,
              color: Colors.green,
            )),
            const SizedBox(width: 8),
            Expanded(child: _StatCard(
              label: l10n.card,
              value: '${(data['cardRevenue'] as num).toDouble().toStringAsFixed(2)} MAD',
              icon: Icons.credit_card_rounded,
              color: Colors.blue,
            )),
            const SizedBox(width: 8),
            Expanded(child: _StatCard(
              label: l10n.totalRevenue,
              value: '${(data['totalRevenue'] as num).toDouble().toStringAsFixed(2)} MAD',
              icon: Icons.account_balance_wallet_rounded,
              color: Colors.orange,
            )),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if ((data['passationAmount'] as num).toDouble() > 0) ...[
              Expanded(child: _StatCard(
                label: l10n.passation,
                value: '${(data['passationAmount'] as num).toDouble().toStringAsFixed(2)} MAD',
                icon: Icons.rotate_right_rounded,
                color: Colors.orange,
              )),
              const SizedBox(width: 8),
            ],
            if ((data['totalTips'] as num).toDouble() > 0) ...[
              Expanded(child: _StatCard(
                label: l10n.tipsCard,
                value: '${(data['totalTips'] as num).toDouble().toStringAsFixed(2)} MAD',
                icon: Icons.volunteer_activism_rounded,
                color: Colors.purple,
              )),
              const SizedBox(width: 8),
            ],
            Expanded(
              flex: 2,
              child: _StatCard(
                label: l10n.cashToHandOver,
                value: '${(data['cashToHandOver'] as num).toDouble().toStringAsFixed(2)} MAD',
                icon: Icons.savings_rounded,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: scheme.onSurface,
              )),
          Text(label,
              style: TextStyle(
                fontSize: 11,
                color: scheme.onSurface.withOpacity(0.5),
              )),
        ],
      ),
    );
  }
}

// ── section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        letterSpacing: 0.3,
      ),
    );
  }
}

// ── order tile ────────────────────────────────────────────────────────────────

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final statusColor = switch (order.status) {
      OrderStatus.pending    => Colors.orange,
      OrderStatus.inprogress => Colors.blue,
      OrderStatus.done       => Colors.green,
      OrderStatus.cancelled  => Colors.red,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.3)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.receipt_long_rounded, color: statusColor, size: 18),
        ),
        title: Text(
          order.tableLabel ?? AppLocalizations.of(context)!.takeaway,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        subtitle: Text(
          '${order.orderItems.length} items · ${order.total.toStringAsFixed(2)} MAD',
          style: TextStyle(fontSize: 12, color: scheme.onSurface.withOpacity(0.5)),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
          ...order.orderItems.where((item) => !item.name.contains(' – ')).map((item) => ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(item.name, style: const TextStyle(fontSize: 13)),
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
      final comboPrice = e.value.fold<double>(0, (s, i) => s + i.unitPrice * i.quantity);
      final subItems = e.value.map((i) {
        final sub = i.name.substring(i.name.indexOf(_sep) + _sep.length);
        return '${i.quantity}x $sub';
      }).join(', ');
      return ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: const Icon(Icons.restaurant_menu, size: 16),
        title: Text(e.key, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        subtitle: Text(subItems, style: const TextStyle(fontSize: 11)),
        trailing: Text(
          '${comboPrice.toStringAsFixed(2)} MAD',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      );
    }).toList();
  }
}