import 'package:pos_v1/core/models/order.dart';
import 'package:pos_v1/core/repositories/order_repository.dart';
import 'package:pos_v1/core/services/offline_queue_service.dart';
import 'package:pos_v1/core/viewmodels/order_viewmodel.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'connectivity_service.dart';

part 'sync_service.g.dart';

/// Watches connectivity and auto-syncs the offline queue when back online.
/// Instantiate once at app startup via ref.watch(syncServiceProvider).
@Riverpod(keepAlive: true)
class SyncService extends _$SyncService {
  @override
  Future<void> build() async {
    // React every time connectivity state flips to online
    final isOnline = ref.watch(isOnlineProvider);
    if (isOnline) {
      await _drainQueue();
    }
  }

  Future<void> _drainQueue() async {
    final queue  = OfflineQueueService();
    final repo   = ref.read(orderRepositoryProvider);

    bool hasChanged = false;

    // 1. Flush pending order creates
    final creates = await queue.getPendingCreates();
    for (final payload in creates) {
      try {
        await repo.createOrder(
          shopId:     payload['shop_id']    as String,
          cashierId:  payload['cashier_id'] as String,
          items:      (payload['items'] as List).cast<Map<String, dynamic>>(),
          shiftId:    payload['shift_id']   as String?,
          tableLabel: payload['table_label'] as String?,
          note:       payload['note']       as String?,
        );
        await queue.removePendingCreate(payload['local_id'] as String);
      hasChanged = true;
      } catch (_) {
        // leave in queue; will retry on next reconnection
      }
    }

    // 2. Flush pending mark-done
    final dones = await queue.getPendingMarkDone();
    for (final payload in dones) {
      try {
        await repo.updateStatus(
          orderId:       payload['order_id']      as String,
          status:        OrderStatus.done,
          paymentMethod: payload['payment_method'] as String? ?? 'cash',
          tip:           (payload['tip'] as num?)?.toDouble() ?? 0,
        );
        await queue.removePendingMarkDone(payload['order_id'] as String);
        hasChanged = true;
      } catch (_) {}
    }

    // 3. Flush pending cancels
    final cancels = await queue.getPendingCancels();
    for (final payload in cancels) {
      try {
        await repo.cancelOrder(payload['order_id'] as String);
        await queue.removePendingCancel(payload['order_id'] as String);
        hasChanged = true;
      } catch (_) {}
    }

    // Refresh active-orders view for every cashier id that had queued ops
    // The viewmodel invalidation is handled by the caller (order_viewmodel).
    if (hasChanged) {
      // 1. Update the banner count
      ref.invalidate(pendingOpsCountProvider);

      // 2. Refresh the active order lists in the ViewModel
      // Note: Since these are Notifiers, you can call their internal refresh methods
      // or simply invalidate them to trigger build() again.
      ref.invalidate(activeOrdersProvider);
      ref.invalidate(myActiveOrdersProvider);
      ref.invalidate(shiftOrdersProvider);

      ref.invalidate(orderHistoryProvider);
      ref.invalidate(myOrderHistoryProvider);
      ref.invalidate(shopOrderHistoryProvider);
    }
  }

  /// Manually trigger a sync (e.g. after app foreground).
  Future<void> syncNow() => _drainQueue();
}

/// How many operations are waiting to sync (used by the banner badge).
@Riverpod(keepAlive: true)
Future<int> pendingOpsCount(Ref ref) async {
  // Recompute whenever connectivity changes (will decrease after sync)
  ref.watch(isOnlineProvider);
  return OfflineQueueService().pendingCount();
}