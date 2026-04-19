import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_note.freezed.dart';
part 'order_note.g.dart';

@freezed
abstract class OrderNote with _$OrderNote {
  const factory OrderNote({
    required String id,
    @JsonKey(name: 'order_item_id') required String orderItemId,
    required String note,
  }) = _OrderNote;

  factory OrderNote.fromJson(Map<String, dynamic> json) =>
      _$OrderNoteFromJson(json);
}