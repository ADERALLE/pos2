import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pos_v1/app/home/notification_bell.dart';
import 'package:pos_v1/app/shared/payment_dialog.dart';
import 'package:pos_v1/app/shared/incidents_sheet.dart';
import 'package:pos_v1/core/appconstants.dart';
import 'package:pos_v1/core/models/staff.dart';
import 'package:pos_v1/core/repositories/order_repository.dart';
import 'package:pos_v1/core/viewmodels/auth_viewmodel.dart';
import 'package:pos_v1/core/viewmodels/order_viewmodel.dart';
import 'package:pos_v1/core/viewmodels/shift_viewmodel.dart';
import 'package:pos_v1/core/models/order.dart';
import 'package:pos_v1/core/models/cart_item.dart';
import 'package:pos_v1/i10n/app_localizations.dart';

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
    final cartOpen = cart.isNotEmpty && isWide;

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
                            : [
                          _ActiveShiftContent(
                            shiftId: shift.id,
                            staff: staff,
                            cartOpen: cartOpen,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (cartOpen) _CartSidePanel(cart: cart),
        ],
      ),
    );
  }
}

// ── app bar (live clock) ──────────────────────────────────────────────────────

class _HomeAppBar extends StatefulWidget {
  const _HomeAppBar({required this.staff});
  final staff;

  @override
  State<_HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<_HomeAppBar> {
  late DateTime _now;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final greeting = _now.hour < 12
        ? l10n.goodMorning
        : _now.hour < 17
        ? l10n.goodAfternoon
        : l10n.goodEvening;

    final localeName = Localizations.localeOf(context).toLanguageTag();
    final dateStr = DateFormat.MMMEd(localeName).format(_now);
    final timeStr =
        '${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}:${_now.second.toString().padLeft(2, '0')}';

    final scheme = Theme.of(context).colorScheme;

    return SliverAppBar(
      pinned: true,
      floating: true,
      toolbarHeight: 64,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting, ${widget.staff.name.split(' ').first}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Row(
            children: [
              Text(
                dateStr,
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurface.withOpacity(0.5),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: scheme.onPrimaryContainer,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        if (widget.staff.role == StaffRole.manager)
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
    final l10n = AppLocalizations.of(context)!;
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
            child: Icon(Icons.coffee_outlined,
                size: 36, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          Text(l10n.noActiveShift,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            l10n.startShiftSubtitle,
            style: TextStyle(color: scheme.onSurface.withOpacity(0.5)),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(l10n.startShift),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => _ShiftDialog.show(
              context: context,
              ref: ref,
              title: l10n.startShift,
              confirmLabel: l10n.start,
              showPassation: true,
              onConfirm: (note, passation) async {
                await ref
                    .read(activeShiftProvider(staff.id).notifier)
                    .openShift(
                  shopId: AppConstants.shopId,
                  staffId: staff.id,
                  note: note,
                  passationAmount: passation,
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

class _ActiveShiftContent extends StatefulWidget {
  const _ActiveShiftContent({
    required this.shiftId,
    required this.staff,
    required this.cartOpen,
  });
  final String shiftId;
  final staff;
  final bool cartOpen;

  @override
  State<_ActiveShiftContent> createState() => _ActiveShiftContentState();
}

class _ActiveShiftContentState extends State<_ActiveShiftContent> {
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ActiveShiftContentBody(
      shiftId: widget.shiftId,
      staff: widget.staff,
      cartOpen: widget.cartOpen,
      now: _now,
    );
  }
}

class _ActiveShiftContentBody extends ConsumerWidget {
  const _ActiveShiftContentBody({
    required this.shiftId,
    required this.staff,
    required this.cartOpen,
    required this.now,
  });
  final String shiftId;
  final staff;
  final bool cartOpen;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shiftAsync = ref.watch(activeShiftProvider(staff.id));
    final ordersAsync = ref.watch(shiftOrdersProvider(shiftId));
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final shift = shiftAsync.value!;
    final duration = now.difference(shift.openedAt);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── shift card ───────────────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                scheme.primaryContainer,
                scheme.primaryContainer.withOpacity(0.6),
              ],
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
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.shiftActive,
                            style: TextStyle(
                              color: scheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 12,
                            color: scheme.onPrimaryContainer.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${hours}h ${minutes.toString().padLeft(2, '0')}m ${seconds.toString().padLeft(2, '0')}s ${l10n.elapsed}',
                            style: TextStyle(
                              color: scheme.onPrimaryContainer.withOpacity(0.7),
                              fontSize: 12,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.stop_rounded, size: 16),
                    label: Text(l10n.close),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: scheme.error,
                      side: BorderSide(color: scheme.error.withOpacity(0.5)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _handleClose(context, ref),
                  ),
                ],
              ),
              if (shift.openingNote != null) ...[
                const SizedBox(height: 8),
                Text(
                  '📝 ${shift.openingNote}',
                  style: TextStyle(
                    color: scheme.onPrimaryContainer.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ── new order button ─────────────────────────────────────────────────
        FilledButton.icon(
          icon: const Icon(Icons.add_rounded),
          label: Text(l10n.newOrder),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            ref.read(editingOrderProvider.notifier).state = null;
            ref.read(cartProvider.notifier).clear();
            context.go('/home/new-order');
          },
        ),

        const SizedBox(height: 28),

        // ── today's orders header ────────────────────────────────────────────
        Row(
          children: [
            Text(
              l10n.todaysOrders,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                color: scheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(width: 8),
            ordersAsync.maybeWhen(
              data: (orders) => Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${orders.length}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
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
              child: Text(
                l10n.noOrdersYet,
                style: TextStyle(
                    color: scheme.onSurface.withOpacity(0.4)),
              ),
            ),
          )
              : Column(
            children: orders.asMap().entries.map((entry) {
              final index = entry.key;
              final order = entry.value;
              return _ShiftOrderTile(
                order: order,
                shiftId: shiftId,
                shiftIndex: orders.length - index,
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
        .where((o) =>
    o.status == OrderStatus.pending ||
        o.status == OrderStatus.inprogress)
        .toList();
    final l10n = AppLocalizations.of(context)!;

    if (uncompleted.isNotEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(l10n.uncompletedOrdersTitle,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          content: Text(
            '${uncompleted.length} ${l10n.uncompletedOrdersMessage}',
          ),
          actions: [
            FilledButton(
              onPressed: () =>
                  Navigator.of(context, rootNavigator: true).pop(),
              child: Text(l10n.ok),
            ),
          ],
        ),
      );
      return;
    }

    _ShiftDialog.show(
      context: context,
      ref: ref,
      title: l10n.closeShift,
      confirmLabel: l10n.close,
      isDestructive: true,
      onConfirm: (note, _) async {
        final shiftNotifier =
        ref.read(activeShiftProvider(staff.id).notifier);
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
//
//  Fully responsive: the meta row (items · total · id) is wrapped in a
//  Flexible so it truncates gracefully on narrow screens. Action icons are
//  constrained to a fixed-width trailing zone so they never push content off
//  screen on small devices.

class _ShiftOrderTile extends ConsumerWidget {
  const _ShiftOrderTile({
    required this.order,
    required this.shiftId,
    required this.shiftIndex,
  });
  final Order order;
  final String shiftId;
  final int shiftIndex;

  void _openPayment(BuildContext context, WidgetRef ref) {
    PaymentDialog.show(
      context: context,
      total: order.effectiveTotal,
      onConfirm: (payment) async {
        final staff = ref.read(currentStaffProvider)!;
        final isManager = staff.role == StaffRole.manager;
        if (isManager) {
          await ref
              .read(activeOrdersProvider(AppConstants.shopId).notifier)
              .markDone(order.id, AppConstants.shopId, payment: payment);
        } else {
          await ref
              .read(myActiveOrdersProvider(staff.id).notifier)
              .markDone(order.id, staff.id, payment: payment);
        }
        ref.read(shiftOrdersProvider(shiftId).notifier).refresh(shiftId);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final statusColor = switch (order.status) {
      OrderStatus.pending    => Colors.orange,
      OrderStatus.inprogress => Colors.blue,
      OrderStatus.done       => Colors.green,
      OrderStatus.cancelled  => Colors.red,
    };

    final isActionable = order.status != OrderStatus.done &&
        order.status != OrderStatus.cancelled;
    final isPending = order.status == OrderStatus.pending;

    // Pre-compute the short id so it doesn't recompute in the build tree.
    final shortId =
        '#${order.id.substring(order.id.length - 6).toUpperCase()}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.3)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isActionable ? () => _openPayment(context, ref) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── status icon ────────────────────────────────────────────────
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.receipt_long_rounded,
                    color: statusColor, size: 18),
              ),
              const SizedBox(width: 10),

              // ── label + meta (fills available space, truncates) ────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      order.tableLabel ?? 'Order #$shiftIndex',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Wrap meta line so it never overflows.
                    Text(
                      '${order.orderItems.length} items · '
                          '${order.effectiveTotal.toStringAsFixed(2)} MAD  '
                          '$shortId',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: scheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),

              // ── status badge ───────────────────────────────────────────────
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.status.name,
                  style: TextStyle(
                    fontSize: 10,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // ── action icons (fixed 40 px each, only when needed) ──────────
              if (isActionable) ...[
                if (isPending)
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.edit_rounded,
                          color: Colors.orange.shade600, size: 18),
                      tooltip: l10n.editOrder,
                      onPressed: () {
                        ref.read(editingOrderProvider.notifier).state = order;
                        context.go('/home/new-order');
                      },
                    ),
                  ),
                SizedBox(
                  width: 36,
                  height: 36,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.warning_amber_rounded,
                        color: Colors.deepOrange.shade600, size: 18),
                    tooltip: l10n.incidentsTooltip,
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20))),
                      builder: (_) => IncidentsSheet(order: order),
                    ),
                  ),
                ),
                SizedBox(
                  width: 36,
                  height: 36,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.check_circle_outline_rounded,
                        color: Colors.green.shade600, size: 20),
                    tooltip: AppLocalizations.of(context)!.markAsPaid,
                    onPressed: () => _openPayment(context, ref),
                  ),
                ),
              ],
            ],
          ),
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
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border(
            left: BorderSide(color: scheme.outlineVariant.withOpacity(0.4))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.currentOrder,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${cart.length}',
                    style: TextStyle(
                      color: scheme.onPrimaryContainer,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
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
                          child: Text(
                            '${item.quantity}',
                            style: TextStyle(
                              color: scheme.onPrimaryContainer,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.displayName,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (item.choicesSummary.isNotEmpty)
                              Text(
                                item.choicesSummary,
                                style: TextStyle(
                                  fontSize: 11,
                                  color:
                                  Theme.of(context).colorScheme.tertiary,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${item.subtotal.toStringAsFixed(2)}',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => ref
                            .read(cartProvider.notifier)
                            .removeItem(item.cartKey),
                        child: Icon(
                          Icons.close,
                          size: 14,
                          color: scheme.onSurface.withOpacity(0.4),
                        ),
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
                    Text(
                      l10n.total,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${total.toStringAsFixed(2)} MAD',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => context.go('/home/new-order'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(l10n.reviewOrder),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => ref.read(cartProvider.notifier).clear(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(36),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(l10n.clear),
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
    this.showPassation = false,
  });
  final String title;
  final String confirmLabel;
  final Future<void> Function(String? note, double passation) onConfirm;
  final bool isDestructive;
  final bool showPassation;

  static void show({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String confirmLabel,
    required Future<void> Function(String? note, double passation) onConfirm,
    bool isDestructive = false,
    bool showPassation = false,
  }) {
    showDialog(
      context: context,
      builder: (_) => _ShiftDialog(
        title: title,
        confirmLabel: confirmLabel,
        onConfirm: onConfirm,
        isDestructive: isDestructive,
        showPassation: showPassation,
      ),
    );
  }

  @override
  State<_ShiftDialog> createState() => _ShiftDialogState();
}

class _ShiftDialogState extends State<_ShiftDialog> {
  final _controller = TextEditingController();
  final _passationController = TextEditingController(text: '0');
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    _passationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final passation =
          double.tryParse(_passationController.text.trim()) ?? 0.0;
      await widget.onConfirm(
        _controller.text.trim().isEmpty ? null : _controller.text.trim(),
        passation,
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
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(widget.title,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: !widget.showPassation,
            decoration: InputDecoration(
              hintText: l10n.noteOptional,
              border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
            ),
          ),
          if (widget.showPassation) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _passationController,
              autofocus: true,
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.passationAmount,
                hintText: '0.00',
                suffixText: 'MAD',
                helperText: l10n.cashTakenFromRegister,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _loading ? null : _submit,
          style: widget.isDestructive
              ? FilledButton.styleFrom(backgroundColor: scheme.error)
              : null,
          child: _loading
              ? const SizedBox(
              width: 16,
              height: 16,
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
          Icon(Icons.error_outline,
              color: Theme.of(context).colorScheme.error, size: 40),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
                color:
                Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
          ),
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
    final l10n = AppLocalizations.of(context)!;
    return IconButton(
      icon: const Icon(Icons.logout_rounded),
      onPressed: () => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(l10n.logout,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          content: Text(l10n.logoutQuestion),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(context, rootNavigator: true).pop(),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
                ref.read(authProvider.notifier).logout();
              },
              child: Text(l10n.logout, style: TextStyle(color: scheme.error)),
            ),
          ],
        ),
      ),
    );
  }
}
