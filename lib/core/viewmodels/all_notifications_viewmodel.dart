// lib/core/viewmodels/all_notifications_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/notification.dart';
import '../repositories/all_notifications_repository.dart';
import '../services/supabase_provider.dart';

part 'all_notifications_viewmodel.g.dart';

@Riverpod(keepAlive: true)
class AllNotifications extends _$AllNotifications {
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
          final notifs =
          data.map((e) => AppNotification.fromJson(e)).toList();
          // merge stream update with any extra pages already loaded
          final current = state.value ?? [];
          final streamIds = notifs.map((n) => n.id).toSet();
          final extra =
          current.where((n) => !streamIds.contains(n.id)).toList();
          state = AsyncData([...notifs, ...extra]);
        },
        onError: (e) => debugPrint('AllNotif stream error: $e'),
      );
      ref.onDispose(sub.cancel);
    } catch (e) {
      debugPrint('AllNotif stream setup error: $e');
    }

    return ref
        .read(allNotificationsRepositoryProvider)
        .getAllNotifications(shopId, page: 0);
  }

  Future<void> loadMore(String shopId) async {
    if (!_hasMore) return;
    _page++;
    final more = await ref
        .read(allNotificationsRepositoryProvider)
        .getAllNotifications(shopId, page: _page);
    if (!ref.mounted) return;
    if (more.isEmpty) {
      _hasMore = false;
      return;
    }
    state = AsyncData([...?state.value, ...more]);
  }

  Future<void> markRead(String id) async {
    await ref.read(allNotificationsRepositoryProvider).markRead(id);
    if (!ref.mounted) return;
    state = AsyncData(
      state.value
          ?.map((n) => n.id == id ? n.copyWith(isRead: true) : n)
          .toList() ??
          [],
    );
  }

  Future<void> markAllRead(String shopId) async {
    await ref.read(allNotificationsRepositoryProvider).markAllRead(shopId);
    if (!ref.mounted) return;
    state = AsyncData(
      state.value?.map((n) => n.copyWith(isRead: true)).toList() ?? [],
    );
  }

  bool get hasMore => _hasMore;
}