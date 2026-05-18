// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InventoryItem _$InventoryItemFromJson(Map<String, dynamic> json) =>
    _InventoryItem(
      id: json['id'] as String,
      shopId: json['shop_id'] as String,
      label: json['label'] as String,
      unitType: json['unit_type'] as String,
      currentStock: (json['current_stock'] as num).toDouble(),
      stopOrdersOnEmpty: json['stop_orders_on_empty'] as bool,
      lowStockThreshold: (json['low_stock_threshold'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$InventoryItemToJson(_InventoryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shop_id': instance.shopId,
      'label': instance.label,
      'unit_type': instance.unitType,
      'current_stock': instance.currentStock,
      'stop_orders_on_empty': instance.stopOrdersOnEmpty,
      'low_stock_threshold': instance.lowStockThreshold,
      'created_at': instance.createdAt.toIso8601String(),
    };
