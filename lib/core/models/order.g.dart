// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Order _$OrderFromJson(Map<String, dynamic> json) => _Order(
  id: json['id'] as String,
  shopId: json['shop_id'] as String,
  shiftId: json['shift_id'] as String?,
  cashierId: json['cashier_id'] as String,
  cashierName: json['cashier_name'] as String?,
  status: $enumDecode(_$OrderStatusEnumMap, json['status']),
  tableLabel: json['table_label'] as String?,
  total: (json['total'] as num).toDouble(),
  note: json['note'] as String?,
  paymentMethod: json['payment_method'] as String? ?? 'cash',
  tip: (json['tip'] as num?)?.toDouble() ?? 0.0,
  cashAmount: (json['cash_amount'] as num?)?.toDouble() ?? 0.0,
  cardAmount: (json['card_amount'] as num?)?.toDouble() ?? 0.0,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  orderItems:
      (json['order_items'] as List<dynamic>?)
          ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$OrderToJson(_Order instance) => <String, dynamic>{
  'id': instance.id,
  'shop_id': instance.shopId,
  'shift_id': instance.shiftId,
  'cashier_id': instance.cashierId,
  'cashier_name': instance.cashierName,
  'status': _$OrderStatusEnumMap[instance.status]!,
  'table_label': instance.tableLabel,
  'total': instance.total,
  'note': instance.note,
  'payment_method': instance.paymentMethod,
  'tip': instance.tip,
  'cash_amount': instance.cashAmount,
  'card_amount': instance.cardAmount,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'order_items': instance.orderItems,
};

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'pending',
  OrderStatus.inprogress: 'inprogress',
  OrderStatus.done: 'done',
  OrderStatus.cancelled: 'cancelled',
};
