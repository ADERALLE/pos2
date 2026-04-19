// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Shift _$ShiftFromJson(Map<String, dynamic> json) => _Shift(
      id: json['id'] as String,
      shopId: json['shop_id'] as String,
      staffId: json['staff_id'] as String,
      openedAt: DateTime.parse(json['opened_at'] as String),
      closedAt: json['closed_at'] == null
          ? null
          : DateTime.parse(json['closed_at'] as String),
      rotationAmount: (json['rotation_amount'] as num?)?.toDouble() ?? 0.0,
      openingNote: json['opening_note'] as String?,
      closingNote: json['closing_note'] as String?,
    );

Map<String, dynamic> _$ShiftToJson(_Shift instance) => <String, dynamic>{
      'id': instance.id,
      'shop_id': instance.shopId,
      'staff_id': instance.staffId,
      'opened_at': instance.openedAt.toIso8601String(),
      'closed_at': instance.closedAt?.toIso8601String(),
      'rotation_amount': instance.rotationAmount,
      'opening_note': instance.openingNote,
      'closing_note': instance.closingNote,
    };
