import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_v1/core/appconstants.dart';
import 'package:pos_v1/core/models/notification.dart';
import 'package:pos_v1/core/viewmodels/notification_viewmodel.dart';
import 'package:pos_v1/core/repositories/order_repository.dart';

class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key, required this.shopId});
  final String shopId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifAsync = ref.watch(notificationsProvider(shopId));
    final unread = notifAsync.value?.length ?? 0;

    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => _showSheet(context, ref),
        ),
        if (unread > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                unread > 99 ? '99+' : '$unread',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  void _showSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _NotificationsSheet(shopId: shopId, ref: ref),
    );
  }
}

class _NotificationsSheet extends ConsumerStatefulWidget {
  const _NotificationsSheet({required this.shopId, required this.ref});
  final String shopId;
  final WidgetRef ref;

  @override
  ConsumerState<_NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends ConsumerState<_NotificationsSheet> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      ref.read(notificationsProvider(widget.shopId).notifier)
          .loadMore(widget.shopId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifAsync = ref.watch(notificationsProvider(widget.shopId));
    final scheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          // handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Notifications',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                notifAsync.maybeWhen(
                  data: (notifs) => notifs.isNotEmpty
                      ? TextButton(
                    onPressed: () => ref
                        .read(notificationsProvider(widget.shopId).notifier)
                        .markAllRead(widget.shopId),
                    child: const Text('Mark all read'),
                  )
                      : const SizedBox(),
                  orElse: () => const SizedBox(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: notifAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (notifs) => notifs.isEmpty
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.notifications_none_rounded,
                        size: 48,
                        color: scheme.onSurface.withOpacity(0.3)),
                    const SizedBox(height: 8),
                    Text('No unread notifications',
                        style: TextStyle(
                            color: scheme.onSurface.withOpacity(0.4))),
                  ],
                ),
              )
                  : ListView.separated(
                controller: _scrollController,
                itemCount: notifs.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) => _NotifTile(
                  notif: notifs[i],
                  shopId: widget.shopId,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifTile extends ConsumerWidget {
  const _NotifTile({required this.notif, required this.shopId});
  final AppNotification notif;
  final String shopId;

  // Detect notification type exactly as in notifications_page.dart
  bool get _isShiftNotif => notif.staffId != null;
  bool get _isDailySummary => notif.title.contains('Daily summary');

  String _extractStaffName() {
    final body = notif.body;
    final suffix =
    body.contains('started') ? ' started a shift' : ' closed their shift';
    return body.replaceAll(suffix, '').trim();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isClickable = _isShiftNotif || _isDailySummary;

    final icon = notif.title.contains('started')
        ? Icons.play_arrow_rounded
        : notif.title.contains('closed')
        ? Icons.stop_rounded
        : Icons.bar_chart_rounded;

    final color = notif.title.contains('started')
        ? Colors.green
        : notif.title.contains('closed')
        ? scheme.error
        : Colors.orange;

    return ListTile(
      tileColor: notif.isRead ? null : scheme.primary.withOpacity(0.04),
      onTap: isClickable
          ? () async {
        // 1. Mark as read
        if (!notif.isRead) {
          await ref
              .read(notificationsProvider(shopId).notifier)
              .markRead(notif.id, shopId);
        }

        if (!context.mounted) return;

        // 2. Close the Notification Sheet
        Navigator.pop(context);

        // 3. Handle GoRouter Navigation
        if (_isShiftNotif && notif.staffId != null) {
          context.push(
            '/settings/staff-dashboard/${notif.staffId}',
            extra: {'id': notif.staffId, 'name': _extractStaffName()},
          );
          return;
        }

        if (_isDailySummary) {
          context.push(
            '/settings/shop-dashboard',
            extra: notif.createdAt,
          );
        }
      }
          : null,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(notif.isRead ? 0.06 : 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color.withOpacity(notif.isRead ? 0.5 : 1.0), size: 20),
      ),
      title: Text(notif.title,
          style: TextStyle(
              fontWeight: notif.isRead ? FontWeight.w400 : FontWeight.w600,
              fontSize: 14)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(notif.body, style: TextStyle(
              fontSize: 12,
              color: scheme.onSurface.withOpacity(notif.isRead ? 0.5 : 0.8))),
          Text(
            _timeAgo(notif.createdAt),
            style: TextStyle(
                fontSize: 11, color: scheme.onSurface.withOpacity(0.4)),
          ),
        ],
      ),
      trailing: !notif.isRead
          ? Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: scheme.primary,
          shape: BoxShape.circle,
        ),
      )
          : null,
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}



