// lib/app/notifications/notifications_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_v1/core/models/notification.dart';
import 'package:pos_v1/core/viewmodels/auth_viewmodel.dart';
import 'package:pos_v1/core/viewmodels/all_notifications_viewmodel.dart';
import 'package:pos_v1/i10n/app_localizations.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  final _scrollController = ScrollController();
  bool _loadingMore = false;

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
    if (_loadingMore) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 150) {
      final shopId = ref.read(currentStaffProvider)?.shopId;
      if (shopId == null) return;
      setState(() => _loadingMore = true);
      ref
          .read(allNotificationsProvider(shopId).notifier)
          .loadMore(shopId)
          .whenComplete(() {
        if (mounted) setState(() => _loadingMore = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final shopId = ref.watch(currentStaffProvider)?.shopId;
    final scheme = Theme.of(context).colorScheme;

    if (shopId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final notifAsync = ref.watch(allNotificationsProvider(shopId));
    final unreadCount = notifAsync.value?.where((n) => !n.isRead).length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.notifications),
        centerTitle: false,
        actions: [
          if (unreadCount > 0)
            TextButton.icon(
              onPressed: () => ref
                  .read(allNotificationsProvider(shopId).notifier)
                  .markAllRead(shopId),
              icon: const Icon(Icons.done_all_rounded, size: 18),
              label: Text(AppLocalizations.of(context)!.markAllRead),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: notifAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 48, color: scheme.error.withOpacity(0.6)),
              const SizedBox(height: 12),
              Text(AppLocalizations.of(context)!.failedToLoadNotifications,
                  style: TextStyle(color: scheme.onSurface.withOpacity(0.6))),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () =>
                    ref.invalidate(allNotificationsProvider(shopId)),
                child: Text(AppLocalizations.of(context)!.retry),
              ),
            ],
          ),
        ),
        data: (notifs) {
          if (notifs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none_rounded,
                      size: 64, color: scheme.onSurface.withOpacity(0.2)),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context)!.noNotificationsYet,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: scheme.onSurface.withOpacity(0.5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(allNotificationsProvider(shopId)),
            child: ListView.separated(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: notifs.length + (_loadingMore ? 1 : 0),
              separatorBuilder: (_, __) =>
              const Divider(height: 1, indent: 72),
              itemBuilder: (context, i) {
                if (i == notifs.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                }
                return _NotifTile(notif: notifs[i], shopId: shopId);
              },
            ),
          );
        },
      ),
    );
  }
}

// ── tile ─────────────────────────────────────────────────────────────────────

class _NotifTile extends ConsumerWidget {
  const _NotifTile({required this.notif, required this.shopId});
  final AppNotification notif;
  final String shopId;

  // Detect notification type from the trigger's title strings
  bool get _isShiftNotif => notif.staffId != null;
  bool get _isDailySummary => notif.title.contains('Daily summary');
  bool get _isLowStock => notif.title == 'low_stock';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final (icon, color) = _resolveIconAndColor(scheme);
    final isClickable = _isShiftNotif || _isDailySummary || _isLowStock;

    // For low_stock notifications, build a human-readable title/body from the
    // pipe-separated body: "label|itemId|stock|unitType"
    final String displayTitle;
    final String displayBody;
    if (_isLowStock) {
      final parts = notif.body.split('|');
      final itemLabel = parts.isNotEmpty ? parts[0] : '?';
      final stock = parts.length >= 3 ? parts[2] : '?';
      final unit = parts.length >= 4 ? parts[3] : '';
      displayTitle = l10n.lowStockAlertTitle;
      displayBody = l10n.lowStockAlertBody(itemLabel, stock, unit);
    } else {
      displayTitle = notif.title;
      displayBody = notif.body;
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      tileColor: notif.isRead ? null : scheme.primary.withOpacity(0.04),
      onTap: isClickable
          ? () async {
        // Mark read first
        if (!notif.isRead) {
          await ref
              .read(allNotificationsProvider(shopId).notifier)
              .markRead(notif.id);
        }
        if (!context.mounted) return;
        _handleNavigation(context);
      }
          : null,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(notif.isRead ? 0.06 : 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon,
            color: color.withOpacity(notif.isRead ? 0.5 : 1.0), size: 22),
      ),
      title: Text(
        displayTitle,
        style: TextStyle(
          fontWeight: notif.isRead ? FontWeight.w400 : FontWeight.w600,
          fontSize: 14,
          color: notif.isRead
              ? scheme.onSurface.withOpacity(0.6)
              : scheme.onSurface,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Text(
            displayBody,
            style: TextStyle(
              fontSize: 13,
              color: notif.isRead
                  ? scheme.onSurface.withOpacity(0.45)
                  : scheme.onSurface.withOpacity(0.75),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _timeAgo(context, notif.createdAt),
            style: TextStyle(
                fontSize: 11, color: scheme.onSurface.withOpacity(0.35)),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!notif.isRead)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          if (isClickable)
            Icon(Icons.chevron_right_rounded,
                size: 18, color: scheme.onSurface.withOpacity(0.3)),
        ],
      ),
    );
  }

  (IconData, Color) _resolveIconAndColor(ColorScheme scheme) {
    if (_isDailySummary) {
      return (Icons.bar_chart_rounded, Colors.blue);
    }
    if (_isLowStock) {
      return (Icons.inventory_2_rounded, Colors.orange);
    }
    if (notif.title.contains('started')) {
      return (Icons.play_arrow_rounded, Colors.green);
    }
    if (notif.title.contains('closed')) {
      return (Icons.stop_rounded, scheme.error);
    }
    return (Icons.notifications_rounded, Colors.orange);
  }

  void _handleNavigation(BuildContext context) {
    if (_isLowStock) {
      // body format: "label|itemId|stock|unitType"
      final parts = notif.body.split('|');
      if (parts.length >= 2) {
        context.push('/settings/inventory/${parts[1]}');
      }
      return;
    }

    if (_isShiftNotif && notif.staffId != null) {
      // → settings/staff-dashboard/:staffId
      context.push(
        '/settings/staff-dashboard/${notif.staffId}',
        extra: {'id': notif.staffId, 'name': _extractStaffName()},
      );
      return;
    }

    if (_isDailySummary) {
      // → shop dashboard with the notification's date
      context.push(
        '/settings/shop-dashboard',
        extra: notif.createdAt,
      );
    }
  }

  /// Pulls the staff name out of the body e.g. "Ahmed started a shift"
  String _extractStaffName() {
    final body = notif.body;
    final suffix =
    body.contains('started') ? ' started a shift' : ' closed their shift';
    return body.replaceAll(suffix, '').trim();
  }

  String _timeAgo(BuildContext context, DateTime dt) {
    final l10n = AppLocalizations.of(context)!;
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return l10n.justNow;
    if (diff.inHours < 1) return '${diff.inMinutes}${l10n.minutesAgoSuffix}';
    if (diff.inDays < 1) return '${diff.inHours}${l10n.hoursAgoSuffix}';
    return '${diff.inDays}${l10n.daysAgoSuffix}';
  }
}
