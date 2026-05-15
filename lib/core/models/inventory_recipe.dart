import 'package:freezed_annotation/freezed_annotation.dart';

part 'inventory_recipe.freezed.dart';
part 'inventory_recipe.g.dart';

@freezed
abstract class InventoryRecipe with _$InventoryRecipe {
  const factory InventoryRecipe({
    required String id,
    @JsonKey(name: 'shop_id') required String shopId,
    @JsonKey(name: 'menu_item_id') required String menuItemId,
    @JsonKey(name: 'inventory_item_id') required String inventoryItemId,
    @JsonKey(name: 'usage_value') required double usageValue,
  }) = _InventoryRecipe;

  factory InventoryRecipe.fromJson(Map<String, dynamic> json) =>
      _$InventoryRecipeFromJson(json);
}
