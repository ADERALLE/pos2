import 'menu_item.dart';

class CartItem {
  CartItem({required this.menuItem, this.quantity = 1, this.note});
  final MenuItem menuItem;
  int quantity;
  String? note;

  double get subtotal => menuItem.price * quantity;
}