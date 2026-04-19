import 'package:freezed_annotation/freezed_annotation.dart';

part 'shift.freezed.dart';
part 'shift.g.dart';

@freezed
abstract class Shift with _$Shift {
  const factory Shift({
    required String id,
    @JsonKey(name: 'shop_id') required String shopId,
    @JsonKey(name: 'staff_id') required String staffId,
    @JsonKey(name: 'opened_at') required DateTime openedAt,
    @JsonKey(name: 'closed_at') DateTime? closedAt,
    @JsonKey(name: 'passation_amount') @Default(0.0) double passationAmount,
    @JsonKey(name: 'opening_note') String? openingNote,
    @JsonKey(name: 'closing_note') String? closingNote,
  }) = _Shift;

  factory Shift.fromJson(Map<String, dynamic> json) => _$ShiftFromJson(json);
}

extension ShiftX on Shift {
  bool get isActive => closedAt == null;
  Duration get duration => (closedAt ?? DateTime.now()).difference(openedAt);
}