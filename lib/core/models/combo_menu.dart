import 'package:freezed_annotation/freezed_annotation.dart';
import 'combo_menu_item.dart';

part 'combo_menu.freezed.dart';
part 'combo_menu.g.dart';

@freezed
abstract class ComboMenu with _$ComboMenu {
  const factory ComboMenu({
    required String id,
    @JsonKey(name: 'shop_id') required String shopId,
    required String name,
    String? description,
    required double price,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'category_id') String? categoryId,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'combo_menu_items') @Default([]) List<ComboMenuItem> comboMenuItems,
  }) = _ComboMenu;

  factory ComboMenu.fromJson(Map<String, dynamic> json) =>
      _$ComboMenuFromJson(json);
}
