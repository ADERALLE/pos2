import 'package:freezed_annotation/freezed_annotation.dart';
import 'menu_item.dart';

part 'combo_menu_item.freezed.dart';
part 'combo_menu_item.g.dart';

@freezed
abstract class ComboMenuItem with _$ComboMenuItem {
  const factory ComboMenuItem({
    required String id,
    @JsonKey(name: 'combo_menu_id') required String comboMenuId,
    @JsonKey(name: 'menu_item_id') required String menuItemId,
    @Default(1) int quantity,
    @JsonKey(name: 'menu_items') MenuItem? menuItem,
  }) = _ComboMenuItem;

  factory ComboMenuItem.fromJson(Map<String, dynamic> json) =>
      _$ComboMenuItemFromJson(json);
}
