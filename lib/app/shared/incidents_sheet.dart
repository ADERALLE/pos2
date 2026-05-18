import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_v1/core/appconstants.dart';
import 'package:pos_v1/core/models/order.dart';
import 'package:pos_v1/core/models/order_item.dart';
import 'package:pos_v1/core/models/staff.dart';
import 'package:pos_v1/core/viewmodels/auth_viewmodel.dart';
import 'package:pos_v1/core/viewmodels/order_viewmodel.dart';
import 'package:pos_v1/i10n/app_localizations.dart';

/// Bottom sheet listing order items, grouped by combo unit or standalone.
///
/// • Combo unit        : header (name + price) + sub-items (Remake only)
///                       + [Cancel Combo] [Remake Combo] buttons at unit level.
/// • Standalone items  : [Remake] [Cancel] (existing behaviour).
///
/// Rules:
///   Cancel Combo  → stock already consumed; combo price removed from bill.
///   Remake Combo  → stock deducted again for each sub-item; price unchanged.
///   Remake item   → stock deducted again for that sub-item; combo price unchanged.
class IncidentsSheet extends ConsumerStatefulWidget {
  const IncidentsSheet({super.key, required this.order});
  final Order order;

  @override
  ConsumerState<IncidentsSheet> createState() => _IncidentsSheetState();
}

class _IncidentsSheetState extends ConsumerState<IncidentsSheet> {
  /// Key → which action is loading.
  /// Keys: orderItemId for per-item, 'cr_$groupKey' / 'cc_$groupKey' for combo.
  final Map<String, String> _loading = {};

  static const _sep = ' \u2013 '; // ' – ' separator used in _buildItemsPayload

  // ── helpers ──────────────────────────────────────────────────────────────

  String _itemName(OrderItem item) {
    final idx = item.name.indexOf(_sep);
    return idx >= 0 ? item.name.substring(idx + _sep.length) : item.name;
  }

  // ── individual item redo (standalone OR combo sub-item) ──────────────────

  Future<void> _redo(BuildContext context, OrderItem item) async {
    if (_loading.containsKey(item.id)) return;
    final l10n = AppLocalizations.of(context)!;
    final staff = ref.read(currentStaffProvider)!;
    final isManager = staff.role == StaffRole.manager;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.redoItemConfirm(_itemName(item))),
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.outOfStock),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  // ── standalone item cancel ────────────────────────────────────────────────

  Future<void> _cancel(BuildContext context, OrderItem item) async {
    if (_loading.containsKey(item.id)) return;
    final l10n = AppLocalizations.of(context)!;
    final staff = ref.read(currentStaffProvider)!;
    final isManager = staff.role == StaffRole.manager;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.cancelItemConfirm(_itemName(item))),
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

  // ── combo-level redo (all sub-items) ─────────────────────────────────────

  Future<void> _redoCombo(
      BuildContext context, String groupKey, List<OrderItem> comboItems) async {
    final loadingKey = 'cr_$groupKey';
    if (_loading.containsKey(loadingKey)) return;
    final l10n = AppLocalizations.of(context)!;
    final staff = ref.read(currentStaffProvider)!;
    final isManager = staff.role == StaffRole.manager;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.redoItemConfirm(groupKey)),
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

    setState(() => _loading[loadingKey] = 'redo');
    bool available = true;
    try {
      if (isManager) {
        available = await ref
            .read(activeOrdersProvider(AppConstants.shopId).notifier)
            .redoComboItems(
              comboItems: comboItems,
              shopId: AppConstants.shopId,
            );
      } else {
        available = await ref
            .read(myActiveOrdersProvider(staff.id).notifier)
            .redoComboItems(
              comboItems: comboItems,
              cashierId: staff.id,
            );
      }
    } finally {
      if (mounted) setState(() => _loading.remove(loadingKey));
    }
    if (!available && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.outOfStock),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  // ── combo-level cancel ────────────────────────────────────────────────────

  Future<void> _cancelCombo(
      BuildContext context, String groupKey, List<OrderItem> comboItems) async {
    final loadingKey = 'cc_$groupKey';
    if (_loading.containsKey(loadingKey)) return;
    final l10n = AppLocalizations.of(context)!;
    final staff = ref.read(currentStaffProvider)!;
    final isManager = staff.role == StaffRole.manager;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.cancelItemConfirm(groupKey)),
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

    setState(() => _loading[loadingKey] = 'cancel');
    try {
      if (isManager) {
        await ref
            .read(activeOrdersProvider(AppConstants.shopId).notifier)
            .cancelComboItems(
              itemIds: comboItems.map((i) => i.id).toList(),
              shopId: AppConstants.shopId,
            );
      } else {
        await ref
            .read(myActiveOrdersProvider(staff.id).notifier)
            .cancelComboItems(
              itemIds: comboItems.map((i) => i.id).toList(),
              cashierId: staff.id,
            );
      }
    } finally {
      if (mounted) setState(() => _loading.remove(loadingKey));
    }
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    // Always read the LIVE order so counts are up-to-date between actions.
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

    // Group: combo items (prefix before ' – ') vs standalone.
    final comboGroups = <String, List<OrderItem>>{};
    final standaloneItems = <OrderItem>[];
    for (final item in items) {
      final idx = item.name.indexOf(_sep);
      if (idx >= 0) {
        comboGroups
            .putIfAbsent(item.name.substring(0, idx), () => [])
            .add(item);
      } else {
        standaloneItems.add(item);
      }
    }

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
              Text(l10n.incidents,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text(l10n.incidentsTooltip,
              style: TextStyle(
                  fontSize: 13,
                  color: scheme.onSurface.withOpacity(0.55))),
          const SizedBox(height: 16),
          const Divider(height: 1),

          // ── Combo groups ─────────────────────────────────────────────────
          ...comboGroups.entries.map((e) => _ComboGroupSection(
                groupKey: e.key,
                comboItems: e.value,
                loading: _loading,
                l10n: l10n,
                scheme: scheme,
                itemName: _itemName,
                onRedoItem: (item) => _redo(context, item),
                onRedoCombo: () => _redoCombo(context, e.key, e.value),
                onCancelCombo: () => _cancelCombo(context, e.key, e.value),
              )),

          // ── Standalone items ─────────────────────────────────────────────
          ...standaloneItems.map((item) {
            final loadingAction = _loading[item.id];
            final allCancelled = item.cancelCount >= item.quantity;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          item.name,
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
                      Text(
                        '${(item.unitPrice * (item.quantity - item.cancelCount).clamp(0, item.quantity)).toStringAsFixed(2)} MAD',
                        style: TextStyle(
                          fontSize: 12,
                          color: allCancelled
                              ? scheme.onSurface.withOpacity(0.35)
                              : scheme.onSurface.withOpacity(0.65),
                          decoration: allCancelled
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ],
                  ),
                  if (item.redoCount > 0 || item.cancelCount > 0) ...[
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 6,
                      children: [
                        if (item.redoCount > 0)
                          _Badge(
                              label: l10n.redoCount(item.redoCount),
                              color: Colors.orange),
                        if (item.cancelCount > 0)
                          _Badge(
                              label: l10n.cancelCount(item.cancelCount),
                              color: Colors.red),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: loadingAction == 'redo'
                            ? const _Spinner()
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
                                onPressed: loadingAction != null ||
                                        allCancelled
                                    ? null
                                    : () => _redo(context, item),
                              ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: loadingAction == 'cancel'
                            ? const _Spinner()
                            : OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red.shade700,
                                  side: BorderSide(
                                      color: Colors.red.shade300),
                                  visualDensity: VisualDensity.compact,
                                ),
                                icon: const Icon(Icons.block_rounded,
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

// ── Combo group section ───────────────────────────────────────────────────────

class _ComboGroupSection extends StatelessWidget {
  const _ComboGroupSection({
    required this.groupKey,
    required this.comboItems,
    required this.loading,
    required this.l10n,
    required this.scheme,
    required this.itemName,
    required this.onRedoItem,
    required this.onRedoCombo,
    required this.onCancelCombo,
  });

  final String groupKey;
  final List<OrderItem> comboItems;
  final Map<String, String> loading;
  final AppLocalizations l10n;
  final ColorScheme scheme;
  final String Function(OrderItem) itemName;
  final void Function(OrderItem) onRedoItem;
  final VoidCallback onRedoCombo;
  final VoidCallback onCancelCombo;

  @override
  Widget build(BuildContext context) {
    final comboAllCancelled =
        comboItems.every((i) => i.cancelCount >= i.quantity);

    // Nominal price: sum of unit_price × quantity across all sub-items.
    // Only the price-bearer item has unit_price > 0; result = combo price.
    final comboNominalPrice = comboItems.fold<double>(
        0.0, (sum, i) => sum + i.unitPrice * i.quantity);

    final redoKey = 'cr_$groupKey';
    final cancelKey = 'cc_$groupKey';
    final isComboRedoing = loading.containsKey(redoKey);
    final isExpCanceling = loading.containsKey(cancelKey);
    final isAnyLoading = isComboRedoing ||
        isExpCanceling ||
        comboItems.any((i) => loading.containsKey(i.id));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Combo header ───────────────────────────────────────────────
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: comboAllCancelled
                  ? Colors.red.shade50
                  : scheme.primaryContainer.withOpacity(0.35),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.layers_rounded,
                    size: 15,
                    color: comboAllCancelled
                        ? Colors.red.shade300
                        : scheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    groupKey,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: comboAllCancelled
                          ? scheme.onSurface.withOpacity(0.4)
                          : scheme.primary,
                      decoration: comboAllCancelled
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),
                Text(
                  comboAllCancelled
                      ? '0.00 MAD'
                      : '${comboNominalPrice.toStringAsFixed(2)} MAD',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: comboAllCancelled
                        ? Colors.red.shade300
                        : scheme.onSurface.withOpacity(0.7),
                    decoration: comboAllCancelled
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                if (comboAllCancelled) ...[
                  const SizedBox(width: 6),
                  _Badge(label: l10n.cancelCount(1), color: Colors.red),
                ],
              ],
            ),
          ),

          const SizedBox(height: 6),

          // ── Sub-items — Remake only ────────────────────────────────────
          ...comboItems.map((item) {
            final itemLoadingAction = loading[item.id];
            return Padding(
              padding: const EdgeInsets.only(left: 14, bottom: 6),
              child: Row(
                children: [
                  Container(
                      width: 2,
                      height: 22,
                      color: scheme.primary.withOpacity(0.25)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          '${item.quantity}x ',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: comboAllCancelled
                                ? scheme.onSurface.withOpacity(0.35)
                                : scheme.primary,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            itemName(item),
                            style: TextStyle(
                              fontSize: 13,
                              color: comboAllCancelled
                                  ? scheme.onSurface.withOpacity(0.35)
                                  : null,
                              decoration: comboAllCancelled
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        if (item.redoCount > 0)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: _Badge(
                                label: l10n.redoCount(item.redoCount),
                                color: Colors.orange),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Only Remake for combo sub-items, never Cancel.
                  SizedBox(
                    width: 90,
                    child: itemLoadingAction == 'redo'
                        ? const _Spinner()
                        : OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange.shade800,
                              side: BorderSide(
                                  color: Colors.orange.shade300),
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6),
                            ),
                            icon: const Icon(Icons.replay_rounded,
                                size: 14),
                            label: Text(l10n.redoItem,
                                style: const TextStyle(fontSize: 11)),
                            onPressed: isAnyLoading || comboAllCancelled
                                ? null
                                : () => onRedoItem(item),
                          ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 4),

          // ── Combo-level buttons: [Cancel Combo]  [Remake Combo] ────────
          Row(
            children: [
              Expanded(
                child: isExpCanceling
                    ? const _Spinner()
                    : OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade700,
                          side:
                              BorderSide(color: Colors.red.shade300),
                          visualDensity: VisualDensity.compact,
                        ),
                        icon:
                            const Icon(Icons.block_rounded, size: 15),
                        label: Text(l10n.cancelItem,
                            style: const TextStyle(fontSize: 13)),
                        onPressed:
                            isAnyLoading || comboAllCancelled
                                ? null
                                : onCancelCombo,
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: isComboRedoing
                    ? const _Spinner()
                    : OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange.shade800,
                          side: BorderSide(
                              color: Colors.orange.shade300),
                          visualDensity: VisualDensity.compact,
                        ),
                        icon: const Icon(Icons.replay_rounded,
                            size: 15),
                        label: Text(l10n.redoItem,
                            style: const TextStyle(fontSize: 13)),
                        onPressed:
                            isAnyLoading || comboAllCancelled
                                ? null
                                : onRedoCombo,
                      ),
              ),
            ],
          ),

          const Divider(height: 16),
        ],
      ),
    );
  }
}

// ── helpers ───────────────────────────────────────────────────────────────────

class _Spinner extends StatelessWidget {
  const _Spinner();
  @override
  Widget build(BuildContext context) => const Center(
      child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2)));
}

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
