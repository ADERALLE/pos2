import 'combo_menu.dart';
import 'menu_item.dart';

class CartItem {
  CartItem({this.menuItem, this.comboMenu, this.quantity = 1, this.note})
      : assert(menuItem != null || comboMenu != null,
            'Either menuItem or comboMenu must be provided');

  final MenuItem? menuItem;
  final ComboMenu? comboMenu;
  int quantity;
  String? note;

  bool get isCombo => comboMenu != null;

  /// Unique key used to identify this cart entry.
  String get cartKey => isCombo ? 'combo_${comboMenu!.id}' : menuItem!.id;

  String get displayName =>
      isCombo ? comboMenu!.name : menuItem!.name;

  double get unitPrice =>
      isCombo ? comboMenu!.price : menuItem!.price;

  double get subtotal => unitPrice * quantity;
}