import 'package:freezed_annotation/freezed_annotation.dart';
import 'order_note.dart';

part 'order_item.freezed.dart';
part 'order_item.g.dart';

@freezed
abstract class OrderItem with _$OrderItem {
  const factory OrderItem({
    required String id,
    @JsonKey(name: 'order_id') required String orderId,
    @JsonKey(name: 'menu_item_id') required String menuItemId,
    required String name,
    @JsonKey(name: 'unit_price') required double unitPrice,
    required int quantity,
    required double subtotal,
    @JsonKey(name: 'order_notes') @Default([]) List<OrderNote> orderNotes,
  }) = _OrderItem;

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);
}