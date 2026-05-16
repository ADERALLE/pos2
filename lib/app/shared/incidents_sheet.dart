import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_v1/core/appconstants.dart';
import 'package:pos_v1/core/models/order.dart';
import 'package:pos_v1/core/models/order_item.dart';
import 'package:pos_v1/core/models/staff.dart';
import 'package:pos_v1/core/viewmodels/auth_viewmodel.dart';
import 'package:pos_v1/core/viewmodels/order_viewmodel.dart';
import 'package:pos_v1/i10n/app_localizations.dart';

/// Bottom sheet listing all order items with per-item "Remake" and "Cancel" actions.
///
/// • Redo   : stock deducted again, price unchanged.
/// • Cancel : stock already consumed (not refunded), price removed from bill.
class IncidentsSheet extends ConsumerStatefulWidget {
  const IncidentsSheet({super.key, required this.order});
  final Order order;

  @override
  ConsumerState<IncidentsSheet> createState() => _IncidentsSheetState();
}

class _IncidentsSheetState extends ConsumerState<IncidentsSheet> {
  /// orderItemId → which action is loading ('redo' | 'cancel')
  final Map<String, String> _loading = {};

  // ── helpers ──────────────────────────────────────────────────────────────

  String _displayName(OrderItem item) {
    const sep = ' \u2013 ';
    if (item.name.contains(sep)) {
      return item.name.substring(item.name.indexOf(sep) + sep.length);
    }
    return item.name;
  }

  // ── actions ───────────────────────────────────────────────────────────────

  Future<void> _redo(BuildContext context, OrderItem item) async {
    if (_loading.containsKey(item.id)) return;
    final l10n = AppLocalizations.of(context)!;
    final staff = ref.read(currentStaffProvider)!;
    final isManager = staff.role == StaffRole.manager;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.redoItemConfirm(_displayName(item))),
        content: Text(l10n.redoItemConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.redoItem),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _loading[item.id] = 'redo');
    bool available = true;
    try {
      if (isManager) {
        available = await ref
            .read(activeOrdersProvider(AppConstants.shopId).notifier)
            .redoOrderItem(
              orderItemId: item.id,
              menuItemId: item.menuItemId,
              prevRedoCount: item.redoCount,
              shopId: AppConstants.shopId,
            );
      } else {
        available = await ref
            .read(myActiveOrdersProvider(staff.id).notifier)
            .redoOrderItem(
              orderItemId: item.id,
              menuItemId: item.menuItemId,
              prevRedoCount: item.redoCount,
              cashierId: staff.id,
            );
      }
    } finally {
      if (mounted) setState(() => _loading.remove(item.id));
    }

    if (!available && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.outOfStock),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _cancel(BuildContext context, OrderItem item) async {
    if (_loading.containsKey(item.id)) return;
    final l10n = AppLocalizations.of(context)!;
    final staff = ref.read(currentStaffProvider)!;
    final isManager = staff.role == StaffRole.manager;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.cancelItemConfirm(_displayName(item))),
        content: Text(l10n.cancelItemConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.cancelItem),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _loading[item.id] = 'cancel');
    try {
      if (isManager) {
        await ref
            .read(activeOrdersProvider(AppConstants.shopId).notifier)
            .cancelOrderItem(
              orderItemId: item.id,
              prevCancelCount: item.cancelCount,
              shopId: AppConstants.shopId,
            );
      } else {
        await ref
            .read(myActiveOrdersProvider(staff.id).notifier)
            .cancelOrderItem(
              orderItemId: item.id,
              prevCancelCount: item.cancelCount,
              cashierId: staff.id,
            );
      }
    } finally {
      if (mounted) setState(() => _loading.remove(item.id));
    }
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    // Always read the LIVE order from the provider so redoCount/cancelCount
    // are up-to-date for every action — even consecutive ones in the same sheet.
    final staff = ref.watch(currentStaffProvider)!;
    final isManager = staff.role == StaffRole.manager;
    final liveOrders = isManager
        ? ref.watch(activeOrdersProvider(AppConstants.shopId)).value ?? []
        : ref.watch(myActiveOrdersProvider(staff.id)).value ?? [];
    final liveOrder = liveOrders.firstWhere(
      (o) => o.id == widget.order.id,
      orElse: () => widget.order,
    );
    final items = liveOrder.orderItems;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: scheme.primary, size: 22),
              const SizedBox(width: 10),
              Text(
                l10n.incidents,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.incidentsTooltip,
            style: TextStyle(
                fontSize: 13,
                color: scheme.onSurface.withOpacity(0.55)),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),

          // ── Item list ────────────────────────────────────────────────────
          ...items.map((item) {
            final loadingAction = _loading[item.id];
            final allCancelled = item.cancelCount >= item.quantity;
            final name = _displayName(item);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item name + quantity
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: allCancelled
                              ? Colors.red.shade100
                              : scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${item.quantity}x',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: allCancelled
                                ? Colors.red.shade700
                                : scheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            decoration: allCancelled
                                ? TextDecoration.lineThrough
                                : null,
                            color: allCancelled
                                ? scheme.onSurface.withOpacity(0.4)
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Redo / Cancel badges
                  if (item.redoCount > 0 || item.cancelCount > 0) ...[
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 6,
                      children: [
                        if (item.redoCount > 0)
                          _Badge(
                            label: l10n.redoCount(item.redoCount),
                            color: Colors.orange,
                          ),
                        if (item.cancelCount > 0)
                          _Badge(
                            label: l10n.cancelCount(item.cancelCount),
                            color: Colors.red,
                          ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 8),

                  // Action buttons
                  Row(
                    children: [
                      // ── Redo button ──────────────────────────────────
                      Expanded(
                        child: loadingAction == 'redo'
                            ? const Center(
                                child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2)))
                            : OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.orange.shade800,
                                  side: BorderSide(
                                      color: Colors.orange.shade300),
                                  visualDensity: VisualDensity.compact,
                                ),
                                icon: const Icon(Icons.replay_rounded,
                                    size: 16),
                                label: Text(l10n.redoItem,
                                    style:
                                        const TextStyle(fontSize: 13)),
                                onPressed: loadingAction != null || allCancelled
                                    ? null
                                    : () => _redo(context, item),
                              ),
                      ),
                      const SizedBox(width: 10),
                      // ── Cancel button ────────────────────────────────
                      Expanded(
                        child: loadingAction == 'cancel'
                            ? const Center(
                                child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2)))
                            : OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red.shade700,
                                  side: BorderSide(
                                      color: Colors.red.shade300),
                                  visualDensity: VisualDensity.compact,
                                ),
                                icon: const Icon(
                                    Icons.block_rounded,
                                    size: 16),
                                label: Text(l10n.cancelItem,
                                    style:
                                        const TextStyle(fontSize: 13)),
                                onPressed: loadingAction != null ||
                                        allCancelled
                                    ? null
                                    : () => _cancel(context, item),
                              ),
                      ),
                    ],
                  ),

                  const Divider(height: 1),
                ],
              ),
            );
          }),

          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ── small badge chip ──────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final MaterialColor color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color.shade800,
        ),
      ),
    );
  }
}
