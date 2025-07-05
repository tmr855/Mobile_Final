import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart.dart' as cart_model; // ✅ Use only this
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final String token;

  const ProductDetailScreen({
    Key? key,
    required this.product,
    required this.token,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;

  void addToCart() {
    final existingItemIndex = cart_model.Cart.items.indexWhere(
      (item) => item.product.id == widget.product.id,
    );

    if (existingItemIndex >= 0) {
      setState(() {
        cart_model.Cart.items[existingItemIndex].quantity += quantity;
      });
    } else {
      setState(() {
        cart_model.Cart.items.add(
          cart_model.CartItem(product: widget.product, quantity: quantity),
        );
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.product.name} (x$quantity) added to cart. Total items: ${cart_model.Cart.items.length}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                tooltip: 'View Cart',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CartScreen(token: widget.token),
                    ),
                  ).then((_) {
                    setState(() {}); // Refresh cart count
                  });
                },
              ),
              if (cart_model.Cart.items.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${cart_model.Cart.items.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (widget.product.image != null &&
                widget.product.image!.isNotEmpty)
              SizedBox(
                height: 250,
                child: Image.network(
                  widget.product.image!,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder:
                      (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 100),
                ),
              ),
            const SizedBox(height: 20),
            Text(widget.product.name, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 10),
            Text(
              '\$${widget.product.price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed:
                      quantity > 1 ? () => setState(() => quantity--) : null,
                ),
                Text('$quantity', style: const TextStyle(fontSize: 20)),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => setState(() => quantity++),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              child: const Text('Add to Cart'),
              onPressed: addToCart,
            ),
          ],
        ),
      ),
    );
  }
}
