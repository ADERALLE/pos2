// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => _OrderItem(
  id: json['id'] as String,
  orderId: json['order_id'] as String,
  menuItemId: json['menu_item_id'] as String,
  name: json['name'] as String,
  unitPrice: (json['unit_price'] as num).toDouble(),
  quantity: (json['quantity'] as num).toInt(),
  subtotal: (json['subtotal'] as num).toDouble(),
  orderNotes:
      (json['order_notes'] as List<dynamic>?)
          ?.map((e) => OrderNote.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$OrderItemToJson(_OrderItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_id': instance.orderId,
      'menu_item_id': instance.menuItemId,
      'name': instance.name,
      'unit_price': instance.unitPrice,
      'quantity': instance.quantity,
      'subtotal': instance.subtotal,
      'order_notes': instance.orderNotes,
    };
