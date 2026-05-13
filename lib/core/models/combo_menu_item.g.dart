// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'combo_menu_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ComboMenuItem _$ComboMenuItemFromJson(Map<String, dynamic> json) =>
    _ComboMenuItem(
      id: json['id'] as String,
      comboMenuId: json['combo_menu_id'] as String,
      menuItemId: json['menu_item_id'] as String,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      choiceGroup: json['choice_group'] as String?,
      menuItem: json['menu_items'] == null
          ? null
          : MenuItem.fromJson(json['menu_items'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ComboMenuItemToJson(_ComboMenuItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'combo_menu_id': instance.comboMenuId,
      'menu_item_id': instance.menuItemId,
      'quantity': instance.quantity,
      'choice_group': instance.choiceGroup,
      'menu_items': instance.menuItem,
    };
