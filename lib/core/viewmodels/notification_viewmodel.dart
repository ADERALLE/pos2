import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/notification.dart';
import '../repositories/notification_repository.dart';
import '../services/supabase_provider.dart';

part 'notification_viewmodel.g.dart';

@Riverpod(keepAlive: true)
class Notifications extends _$Notifications {
  int _page = 0;
  bool _hasMore = true;

  @override
  Future<List<AppNotification>> build(String shopId) async {
    _page = 0;
    _hasMore = true;
    try {
      final sub = ref
          .read(supabaseClientProvider)
          .from('notifications')
          .stream(primaryKey: ['id'])
          .eq('shop_id', shopId)
          .order('created_at', ascending: false)
          .limit(20)
          .listen(
            (data) {
          if (!ref.mounted) return;
          final notifs = data
              .where((e) => e['is_read'] == false)
              .map((e) => AppNotification.fromJson(e))
              .toList();
          state = AsyncData(notifs);
        },
        onError: (e) => debugPrint('Notif stream error: $e'),
      );
      ref.onDispose(sub.cancel);
    } catch (e) {
      debugPrint('Notif stream setup error: $e');
    }
    return ref
        .read(notificationRepositoryProvider)
        .getNotifications(shopId, page: 0);
  }

  Future<void> loadMore(String shopId) async {
    if (!_hasMore) return;
    _page++;
    final more = await ref
        .read(notificationRepositoryProvider)
        .getNotifications(shopId, page: _page);
    if (!ref.mounted) return;
    if (more.isEmpty) {
      _hasMore = false;
      return;
    }
    state = AsyncData([...?state.value, ...more]);
  }

  Future<void> markRead(String id, String shopId) async {
    await ref.read(notificationRepositoryProvider).markRead(id);
    if (!ref.mounted) return;
    state = AsyncData(state.value?.where((n) => n.id != id).toList() ?? []);
  }

  Future<void> markAllRead(String shopId) async {
    await ref.read(notificationRepositoryProvider).markAllRead(shopId);
    if (!ref.mounted) return;
    state = const AsyncData([]);
  }

  int get unreadCount => state.value?.length ?? 0;
}