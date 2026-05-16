import 'package:freezed_annotation/freezed_annotation.dart';

part 'inventory_item.freezed.dart';
part 'inventory_item.g.dart';

@freezed
abstract class InventoryItem with _$InventoryItem {
  const factory InventoryItem({
    required String id,
    @JsonKey(name: 'shop_id') required String shopId,
    required String label,
    @JsonKey(name: 'unit_type') required String unitType,
    @JsonKey(name: 'current_stock') required double currentStock,
    @JsonKey(name: 'stop_orders_on_empty') required bool stopOrdersOnEmpty,
    @JsonKey(name: 'low_stock_threshold') double? lowStockThreshold,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _InventoryItem;

  factory InventoryItem.fromJson(Map<String, dynamic> json) =>
      _$InventoryItemFromJson(json);
}
