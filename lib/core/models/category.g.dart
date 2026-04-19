// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Category _$CategoryFromJson(Map<String, dynamic> json) => _Category(
      id: json['id'] as String,
      shopId: json['shop_id'] as String,
      label: json['label'] as String,
      sortOrder: (json['sort_order'] as num).toInt(),
      isSupp: json['is_supp'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$CategoryToJson(_Category instance) => <String, dynamic>{
      'id': instance.id,
      'shop_id': instance.shopId,
      'label': instance.label,
      'sort_order': instance.sortOrder,
      'is_supp': instance.isSupp,
      'created_at': instance.createdAt.toIso8601String(),
    };
