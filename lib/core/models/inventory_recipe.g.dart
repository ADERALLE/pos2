// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_recipe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InventoryRecipe _$InventoryRecipeFromJson(Map<String, dynamic> json) =>
    _InventoryRecipe(
      id: json['id'] as String,
      shopId: json['shop_id'] as String,
      menuItemId: json['menu_item_id'] as String,
      inventoryItemId: json['inventory_item_id'] as String,
      usageValue: (json['usage_value'] as num).toDouble(),
    );

Map<String, dynamic> _$InventoryRecipeToJson(_InventoryRecipe instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shop_id': instance.shopId,
      'menu_item_id': instance.menuItemId,
      'inventory_item_id': instance.inventoryItemId,
      'usage_value': instance.usageValue,
    };
