// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppNotification _$AppNotificationFromJson(Map<String, dynamic> json) =>
    _AppNotification(
      id: json['id'] as String,
      shopId: json['shop_id'] as String,
      staffId: json['staff_id'] as String?,
      title: json['title'] as String,
      body: json['body'] as String,
      isRead: json['is_read'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$AppNotificationToJson(_AppNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shop_id': instance.shopId,
      'staff_id': instance.staffId,
      'title': instance.title,
      'body': instance.body,
      'is_read': instance.isRead,
      'created_at': instance.createdAt.toIso8601String(),
    };
