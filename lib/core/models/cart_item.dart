import 'combo_menu.dart';
import 'menu_item.dart';

class CartItem {
  CartItem({
    this.menuItem,
    this.comboMenu,
    this.quantity = 1,
    this.note,
    this.selectedChoices = const {},
  }) : assert(menuItem != null || comboMenu != null,
            'Either menuItem or comboMenu must be provided');

  final MenuItem? menuItem;
  final ComboMenu? comboMenu;
  int quantity;
  String? note;

  /// For combos with choice groups: maps choiceGroup → selected menuItemId.
  final Map<String, String> selectedChoices;

  bool get isCombo => comboMenu != null;

  /// Unique key: for combos with choices, include the sorted choice values
  /// so that different selections produce different cart entries.
  String get cartKey {
    if (!isCombo) return menuItem!.id;
    if (selectedChoices.isEmpty) return 'combo_${comboMenu!.id}';
    final choicesSuffix = (selectedChoices.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key)))
        .map((e) => '${e.key}:${e.value}')
        .join('|');
    return 'combo_${comboMenu!.id}_$choicesSuffix';
  }

  String get displayName => isCombo ? comboMenu!.name : menuItem!.name;

  double get unitPrice => isCombo ? comboMenu!.price : menuItem!.price;

  double get subtotal => unitPrice * quantity;
}