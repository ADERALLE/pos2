// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrderNote _$OrderNoteFromJson(Map<String, dynamic> json) => _OrderNote(
      id: json['id'] as String,
      orderItemId: json['order_item_id'] as String,
      note: json['note'] as String,
    );

Map<String, dynamic> _$OrderNoteToJson(_OrderNote instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_item_id': instance.orderItemId,
      'note': instance.note,
    };
