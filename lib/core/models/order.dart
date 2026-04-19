import 'package:freezed_annotation/freezed_annotation.dart';
import 'order_item.dart';

part 'order.freezed.dart';
part 'order.g.dart';

enum OrderStatus { pending, inprogress, done, cancelled }

@freezed
abstract class Order with _$Order {
  const factory Order({
    required String id,
    @JsonKey(name: 'shop_id') required String shopId,
    @JsonKey(name: 'shift_id') String? shiftId,
    @JsonKey(name: 'cashier_id') required String cashierId,
    @JsonKey(name: 'cashier_name') String? cashierName,
    required OrderStatus status,
    @JsonKey(name: 'table_label') String? tableLabel,
    required double total,
    String? note,
    /// 'cash' | 'card' | 'split'  – kept for legacy reads; prefer cashAmount/cardAmount.
    @JsonKey(name: 'payment_method') @Default('cash') String paymentMethod,
    @Default(0.0) double tip,
    /// Amount paid in cash (may be partial for split payments).
    @JsonKey(name: 'cash_amount') @Default(0.0) double cashAmount,
    /// Amount paid by card (may be partial for split payments).
    @JsonKey(name: 'card_amount') @Default(0.0) double cardAmount,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'order_items') @Default([]) List<OrderItem> orderItems,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  static Order fromSupabase(Map<String, dynamic> json) {
    final staff = json['staff'];
    return _$OrderFromJson({
      ...json,
      if (staff is Map) 'cashier_name': staff['name'],
    });
  }
}

/// Derives a display-friendly payment label from an order.
extension OrderPaymentLabel on Order {
  String get paymentLabel {
    if (cashAmount > 0 && cardAmount > 0) return 'Split';
    if (cardAmount > 0) return 'Card';
    return 'Cash';
  }
}