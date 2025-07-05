// models/cart.dart
import 'product.dart';

class Cart {
  static final List<CartItem> items = [];
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}
