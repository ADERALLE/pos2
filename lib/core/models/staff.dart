import 'package:freezed_annotation/freezed_annotation.dart';

part 'staff.freezed.dart';
part 'staff.g.dart';

enum StaffRole { manager, cashier }

@freezed
abstract class Staff with _$Staff {
  const factory Staff({
    required String id,
    @JsonKey(name: 'shop_id') required String shopId,
    required String name,
    required StaffRole role,
    String? pin,
    @JsonKey(name: 'is_active') required bool isActive,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Staff;

  factory Staff.fromJson(Map<String, dynamic> json) => _$StaffFromJson(json);
}