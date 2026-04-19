// lib/core/repositories/notification_repository.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification.dart';
import '../services/supabase_provider.dart';

part 'notification_repository.g.dart';

@riverpod
NotificationRepository notificationRepository(Ref ref) {
  return NotificationRepository(ref.watch(supabaseClientProvider));
}

class NotificationRepository {
  NotificationRepository(this._client);
  final SupabaseClient _client;

  Future<List<AppNotification>> getNotifications(String shopId, {int page = 0}) async {
    final data = await _client
        .from('notifications')
        .select()
        .eq('shop_id', shopId)
        .eq('is_read', false)
        .order('created_at', ascending: false)
        .range(page * 20, (page + 1) * 20 - 1); // 20 per page
    return data.map((e) => AppNotification.fromJson(e)).toList();
  }

  Future<AppNotification> markRead(String id) async {
    final data = await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', id)
        .select()
        .single();
    return AppNotification.fromJson(data);
  }

  Future<void> markAllRead(String shopId) async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('shop_id', shopId)
        .eq('is_read', false);
  }
}