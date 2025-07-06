import 'package:flutter/material.dart';
import 'package:product_app/models/order_item.dart';
import 'package:product_app/screens/order_screen.dart';
import '../models/cart.dart' as cart_model;

class CartScreen extends StatefulWidget {
  final String token;
  const CartScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  void _updateQuantity(int index, int newQty) {
    if (newQty < 1) return;
    setState(() {
      cart_model.Cart.items[index].quantity = newQty;
    });
  }

  void _removeItem(int index) {
    setState(() {
      cart_model.Cart.items.removeAt(index);
    });
  }

  double get totalPrice {
    return cart_model.Cart.items.fold(
      0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );
  }

  void _goToOrderScreen() {
    if (cart_model.Cart.items.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cart is empty')));
      return;
    }

    final orderItems =
        cart_model.Cart.items
            .map(
              (cartItem) => OrderItem(
                productId: cartItem.product.id,
                quantity: cartItem.quantity,
                price: cartItem.product.price,
                product: cartItem.product, // ✅ Include full product
              ),
            )
            .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => OrderScreen(token: widget.token, orderItems: orderItems),
      ),
    ).then((value) {
      // ✅ Clear cart only if order was placed successfully
      if (value == true) {
        setState(() {
          cart_model.Cart.items.clear();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body:
          cart_model.Cart.items.isEmpty
              ? const Center(child: Text('Your cart is empty'))
              : ListView.builder(
                itemCount: cart_model.Cart.items.length,
                itemBuilder: (context, index) {
                  final cartItem = cart_model.Cart.items[index];
                  return ListTile(
                    leading:
                        cartItem.product.image != null
                            ? Image.network(
                              cartItem.product.image!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                            : const Icon(Icons.image_not_supported),
                    title: Text(cartItem.product.name),
                    subtitle: Text(
                      '\$${cartItem.product.price.toStringAsFixed(2)}',
                    ),
                    trailing: SizedBox(
                      width: 140,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed:
                                () => _updateQuantity(
                                  index,
                                  cartItem.quantity - 1,
                                ),
                          ),
                          Text('${cartItem.quantity}'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed:
                                () => _updateQuantity(
                                  index,
                                  cartItem.quantity + 1,
                                ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _removeItem(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total: \$${totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: _goToOrderScreen,
              child: const Text('Checkout'),
            ),
          ],
        ),
      ),
    );
  }
}
