import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_v1/core/appconstants.dart';
import 'package:pos_v1/core/models/order.dart';
import 'package:pos_v1/core/models/order_item.dart';
import 'package:pos_v1/core/models/staff.dart';
import 'package:pos_v1/core/viewmodels/auth_viewmodel.dart';
import 'package:pos_v1/core/viewmodels/order_viewmodel.dart';
import 'package:pos_v1/i10n/app_localizations.dart';

/// Bottom sheet listing all order items with a "Remake" button per item.
/// Deducts extra stock without changing the order price.
class RedoSheet extends ConsumerStatefulWidget {
  const RedoSheet({super.key, required this.order});
  final Order order;

  @override
  ConsumerState<RedoSheet> createState() => _RedoSheetState();
}

class _RedoSheetState extends ConsumerState<RedoSheet> {
  final Set<String> _loading = {};

  Future<void> _redo(BuildContext context, OrderItem item) async {
    final l10n = AppLocalizations.of(context)!;
    final staff = ref.read(currentStaffProvider)!;
    final isManager = staff.role == StaffRole.manager;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.redoItemConfirm(item.name.contains(' \u2013 ')
            ? item.name.substring(item.name.indexOf(' \u2013 ') + 3)
            : item.name)),
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

    setState(() => _loading.add(item.id));
    try {
      if (isManager) {
        await ref
            .read(activeOrdersProvider(AppConstants.shopId).notifier)
            .redoOrderItem(
              orderItemId: item.id,
              prevRedoCount: item.redoCount,
              shopId: AppConstants.shopId,
            );
      } else {
        await ref
            .read(myActiveOrdersProvider(staff.id).notifier)
            .redoOrderItem(
              orderItemId: item.id,
              prevRedoCount: item.redoCount,
              cashierId: staff.id,
            );
      }
    } finally {
      if (mounted) setState(() => _loading.remove(item.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.replay_rounded, color: scheme.primary, size: 22),
              const SizedBox(width: 10),
              Text(
                l10n.redoItem,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.redoItemConfirmBody,
            style: TextStyle(
                fontSize: 13, color: scheme.onSurface.withOpacity(0.55)),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          ...widget.order.orderItems.map((item) {
            final isLoading = _loading.contains(item.id);
            final subName = item.name.contains(' \u2013 ')
                ? item.name.substring(item.name.indexOf(' \u2013 ') + 3)
                : item.name;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '${item.quantity}x',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: scheme.primary,
                    ),
                  ),
                ),
              ),
              title: Text(subName,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              subtitle: item.redoCount > 0
                  ? Text(
                      l10n.redoCount(item.redoCount),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : null,
              trailing: SizedBox(
                width: 90,
                child: isLoading
                    ? const Center(
                        child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2)))
                    : FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          backgroundColor: Colors.orange.withOpacity(0.12),
                          foregroundColor: Colors.orange.shade800,
                        ),
                        onPressed: () => _redo(context, item),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.replay_rounded, size: 14),
                            const SizedBox(width: 4),
                            Text(l10n.redoItem,
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
              ),
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
