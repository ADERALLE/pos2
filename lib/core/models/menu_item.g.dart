// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MenuItem _$MenuItemFromJson(Map<String, dynamic> json) => _MenuItem(
  id: json['id'] as String,
  shopId: json['shop_id'] as String,
  categoryId: json['category_id'] as String?,
  name: json['name'] as String,
  price: (json['price'] as num).toDouble(),
  imageUrl: json['image_url'] as String?,
  isActive: json['is_active'] as bool,
  sortOrder: (json['sort_order'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$MenuItemToJson(_MenuItem instance) => <String, dynamic>{
  'id': instance.id,
  'shop_id': instance.shopId,
  'category_id': instance.categoryId,
  'name': instance.name,
  'price': instance.price,
  'image_url': instance.imageUrl,
  'is_active': instance.isActive,
  'sort_order': instance.sortOrder,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
