import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_v1/app/home/notification_bell.dart';
import 'package:pos_v1/app/shared/payment_dialog.dart';
import 'package:pos_v1/core/appconstants.dart';
import 'package:pos_v1/core/models/staff.dart';
import 'package:pos_v1/core/repositories/order_repository.dart';
import 'package:pos_v1/core/viewmodels/auth_viewmodel.dart';
import 'package:pos_v1/core/viewmodels/order_viewmodel.dart';
import 'package:pos_v1/core/viewmodels/shift_viewmodel.dart';
import 'package:pos_v1/core/models/order.dart';
import 'package:pos_v1/core/models/cart_item.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staff = ref.watch(currentStaffProvider);
    if (staff == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final shiftAsync = ref.watch(activeShiftProvider(staff.id));
    final cart = ref.watch(cartProvider);
    final isWide = MediaQuery.sizeOf(context).width >= 800;

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _HomeAppBar(staff: staff),
                shiftAsync.when(
                  loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => SliverFillRemaining(
                    child: _ErrorState(message: '$e'),
                  ),
                  data: (shift) => SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        shift == null
                            ? [_NoShiftCard(staff: staff)]
                            : [_ActiveShiftContent(shiftId: shift.id, staff: staff)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (cart.isNotEmpty && isWide)
            _CartSidePanel(cart: cart),
        ],
      ),
    );
  }
}

// ── app bar ───────────────────────────────────────────────────────────────────

class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar({required this.staff});
  final staff;

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'morning' : hour < 17 ? 'afternoon' : 'evening';
    final now = DateTime.now();
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    const days   = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    final dateStr = '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';

    return SliverAppBar(
      pinned: true,
      floating: true,
      toolbarHeight: 64,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good $greeting, ${staff.name.split(' ').first}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Text(
            dateStr,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      actions: [
        if (staff.role == StaffRole.manager)
          NotificationBell(shopId: AppConstants.shopId),
        const _LogoutButton(),
      ],
    );
  }
}

// ── no shift card ─────────────────────────────────────────────────────────────

class _NoShiftCard extends ConsumerWidget {
  const _NoShiftCard({required this.staff});
  final staff;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 60),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.coffee_outlined, size: 36, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          Text('No active shift',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            'Start a shift to begin taking orders',
            style: TextStyle(color: scheme.onSurface.withOpacity(0.5)),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Start shift'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => _ShiftDialog.show(
              context: context,
              ref: ref,
              title: 'Start shift',
              confirmLabel: 'Start',
              showRotation: true,
              onConfirm: (note, rotation) async {
                await ref
                    .read(activeShiftProvider(staff.id).notifier)
                    .openShift(
                  shopId: AppConstants.shopId,
                  staffId: staff.id,
                  note: note,
                  rotationAmount: rotation,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── active shift content ──────────────────────────────────────────────────────

class _ActiveShiftContent extends ConsumerWidget {
  const _ActiveShiftContent({required this.shiftId, required this.staff});
  final String shiftId;
  final staff;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shiftAsync = ref.watch(activeShiftProvider(staff.id));
    final ordersAsync = ref.watch(shiftOrdersProvider(shiftId));
    final scheme = Theme.of(context).colorScheme;

    final shift = shiftAsync.value!;
    final duration = DateTime.now().difference(shift.openedAt);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // shift card
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [scheme.primaryContainer, scheme.primaryContainer.withOpacity(0.6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8, height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text('Shift active',
                              style: TextStyle(
                                color: scheme.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              )),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('${hours}h ${minutes}m elapsed',
                          style: TextStyle(
                            color: scheme.onPrimaryContainer.withOpacity(0.7),
                            fontSize: 12,
                          )),
                    ],
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.stop_rounded, size: 16),
                    label: const Text('Close'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: scheme.error,
                      side: BorderSide(color: scheme.error.withOpacity(0.5)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _handleClose(context, ref),
                  ),
                ],
              ),
              if (shift.openingNote != null) ...[
                const SizedBox(height: 8),
                Text('📝 ${shift.openingNote}',
                    style: TextStyle(
                      color: scheme.onPrimaryContainer.withOpacity(0.7),
                      fontSize: 12,
                    )),
              ],
            ],
          ),
        ),

        const SizedBox(height: 12),

        // new order button
        FilledButton.icon(
          icon: const Icon(Icons.add_rounded),
          label: const Text('New order'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => context.go('/home/new-order'),
        ),

        const SizedBox(height: 28),

        // orders header
        Row(
          children: [
            Text("Today's orders",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                  color: scheme.onSurface.withOpacity(0.6),
                )),
            const SizedBox(width: 8),
            ordersAsync.maybeWhen(
              data: (orders) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('${orders.length}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurfaceVariant,
                    )),
              ),
              orElse: () => const SizedBox(),
            ),
          ],
        ),
        const SizedBox(height: 10),

        ordersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _ErrorState(message: '$e'),
          data: (orders) => orders.isEmpty
              ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text('No orders yet',
                  style: TextStyle(color: scheme.onSurface.withOpacity(0.4))),
            ),
          )
              : Column(
            children: orders.asMap().entries.map((entry) {
              final index = entry.key;
              final order = entry.value;
              return _ShiftOrderTile(
                order: order,
                shiftId: shiftId,
                shiftIndex: orders.length - index , // +1 so it starts at #1
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  void _handleClose(BuildContext context, WidgetRef ref) {
    final shiftOrders = ref.read(shiftOrdersProvider(shiftId)).value ?? [];
    final uncompleted = shiftOrders
        .where((o) => o.status == OrderStatus.pending || o.status == OrderStatus.inprogress)
        .toList();

    if (uncompleted.isNotEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Uncompleted orders', style: TextStyle(fontWeight: FontWeight.w600)),
          content: Text(
            '${uncompleted.length} order(s) are still pending or in progress.\n'
                'Mark them as done or cancel before closing.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    _ShiftDialog.show(
      context: context,
      ref: ref,
      title: 'Close shift',
      confirmLabel: 'Close',
      isDestructive: true,
      onConfirm: (note, _) async {
        final shiftNotifier = ref.read(activeShiftProvider(staff.id).notifier);
        final orderRepo = ref.read(orderRepositoryProvider);
        final router = GoRouter.of(context);

        await shiftNotifier.closeShift(shiftId: shiftId, note: note);
        await Future.delayed(const Duration(milliseconds: 300));
        final closedShift = await orderRepo.getShiftById(shiftId);
        router.go('/shift-summary', extra: closedShift);
      },
    );
  }
}

// ── shift order tile ──────────────────────────────────────────────────────────

class _ShiftOrderTile extends ConsumerWidget {
  const _ShiftOrderTile({required this.order, required this.shiftId, required this.shiftIndex});
  final Order order;
  final String shiftId;
  final int shiftIndex ;


  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
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
          order.tableLabel ?? 'Order #$shiftIndex',
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        subtitle: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${order.orderItems.length} items · ${order.total.toStringAsFixed(2)} MAD',
              style: TextStyle(fontSize: 12, color: scheme.onSurface.withOpacity(0.5)),
            ),
            const SizedBox(width: 8),
            Text(
              '#${order.id.substring(order.id.length - 6).toUpperCase()}',              style: TextStyle(
              fontSize: 10, // Smaller than the standard rank/index
              fontWeight: FontWeight.bold,
              color: scheme.onPrimaryContainer,
              letterSpacing: 0.5,
            ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(order.status.name,
                  style: TextStyle(
                    fontSize: 11,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  )),
            ),
            if (order.status != OrderStatus.done && order.status != OrderStatus.cancelled) ...[
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(Icons.check_circle_outline_rounded,
                    color: Colors.green.shade600, size: 22),
                onPressed: () => PaymentDialog.show(
                  context: context,
                  total: order.total,
                  onConfirm: (payment) async {
                    final staff = ref.read(currentStaffProvider)!;
                    final isManager = staff.role == StaffRole.manager;
                    if (isManager) {
                      await ref.read(activeOrdersProvider(AppConstants.shopId).notifier)
                          .markDone(order.id, AppConstants.shopId, payment: payment);
                    } else {
                      await ref.read(myActiveOrdersProvider(staff.id).notifier)
                          .markDone(order.id, staff.id, payment: payment);
                    }
                    ref.read(shiftOrdersProvider(shiftId).notifier).refresh(shiftId);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── cart side panel ───────────────────────────────────────────────────────────

class _CartSidePanel extends ConsumerWidget {
  const _CartSidePanel({required this.cart});
  final List<CartItem> cart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final total = ref.read(cartProvider.notifier).total;

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border(left: BorderSide(color: scheme.outlineVariant.withOpacity(0.4))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Current order',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    )),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${cart.length}',
                      style: TextStyle(
                        color: scheme.onPrimaryContainer,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: cart.length,
              itemBuilder: (_, i) {
                final item = cart[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text('${item.quantity}',
                              style: TextStyle(
                                color: scheme.onPrimaryContainer,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              )),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(item.displayName,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 8),
                      Text('${item.subtotal.toStringAsFixed(2)}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => ref.read(cartProvider.notifier).removeItem(item.cartKey),
                        child: Icon(Icons.close, size: 14,
                            color: scheme.onSurface.withOpacity(0.4)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    Text('${total.toStringAsFixed(2)} MAD',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scheme.primary,
                        )),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => context.go('/home/new-order'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Review order'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => ref.read(cartProvider.notifier).clear(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(36),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── shared shift dialog ───────────────────────────────────────────────────────

class _ShiftDialog extends StatefulWidget {
  const _ShiftDialog({
    required this.title,
    required this.confirmLabel,
    required this.onConfirm,
    this.isDestructive = false,
    this.showRotation = false,

  });
  final String title;
  final String confirmLabel;
  final Future<void> Function(String? note, double rotation) onConfirm;
  final bool isDestructive;
  final bool showRotation;


  static void show({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String confirmLabel,
    required Future<void> Function(String? note, double rotation) onConfirm,
    bool isDestructive = false,
    bool showRotation = false,

  }) {
    showDialog(
      context: context,
      builder: (_) => _ShiftDialog(
        title: title,
        confirmLabel: confirmLabel,
        onConfirm: onConfirm,
        isDestructive: isDestructive,
        showRotation: showRotation,

      ),
    );
  }

  @override
  State<_ShiftDialog> createState() => _ShiftDialogState();
}

class _ShiftDialogState extends State<_ShiftDialog> {
  final _controller = TextEditingController();
  final _rotationController = TextEditingController(text: '0');

  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    _rotationController.dispose();

    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final rotation = double.tryParse(_rotationController.text.trim()) ?? 0.0;
      await widget.onConfirm(
        _controller.text.trim().isEmpty ? null : _controller.text.trim(),
        rotation,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w600)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: !widget.showRotation,
            decoration: InputDecoration(
              hintText: 'Note (optional)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          if (widget.showRotation) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _rotationController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Rotation amount',
                hintText: '0.00',
                suffixText: 'MAD',
                helperText: 'Cash taken from register at shift start',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _loading ? null : _submit,
          style: widget.isDestructive
              ? FilledButton.styleFrom(backgroundColor: scheme.error)
              : null,
          child: _loading
              ? const SizedBox(width: 16, height: 16,
              child: CircularProgressIndicator(strokeWidth: 2))
              : Text(widget.confirmLabel),
        ),
      ],
    );
  }
}

// ── error state ───────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 40),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
        ],
      ),
    );
  }
}

// ── logout button ─────────────────────────────────────────────────────────────

class _LogoutButton extends ConsumerWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      icon: const Icon(Icons.logout_rounded),
      onPressed: () => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w600)),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
                ref.read(authProvider.notifier).logout();
              },
              child: Text('Logout', style: TextStyle(color: scheme.error)),
            ),
          ],
        ),
      ),
    );
  }
}