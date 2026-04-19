// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Staff _$StaffFromJson(Map<String, dynamic> json) => _Staff(
      id: json['id'] as String,
      shopId: json['shop_id'] as String,
      name: json['name'] as String,
      role: $enumDecode(_$StaffRoleEnumMap, json['role']),
      pin: json['pin'] as String?,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$StaffToJson(_Staff instance) => <String, dynamic>{
      'id': instance.id,
      'shop_id': instance.shopId,
      'name': instance.name,
      'role': _$StaffRoleEnumMap[instance.role]!,
      'pin': instance.pin,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$StaffRoleEnumMap = {
  StaffRole.manager: 'manager',
  StaffRole.cashier: 'cashier',
};
