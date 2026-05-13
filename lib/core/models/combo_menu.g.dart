// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'combo_menu.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ComboMenu _$ComboMenuFromJson(Map<String, dynamic> json) => _ComboMenu(
  id: json['id'] as String,
  shopId: json['shop_id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  price: (json['price'] as num).toDouble(),
  imageUrl: json['image_url'] as String?,
  categoryId: json['category_id'] as String?,
  isActive: json['is_active'] as bool? ?? true,
  sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  comboMenuItems:
      (json['combo_menu_items'] as List<dynamic>?)
          ?.map((e) => ComboMenuItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$ComboMenuToJson(_ComboMenu instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shop_id': instance.shopId,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'image_url': instance.imageUrl,
      'category_id': instance.categoryId,
      'is_active': instance.isActive,
      'sort_order': instance.sortOrder,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'combo_menu_items': instance.comboMenuItems,
    };
