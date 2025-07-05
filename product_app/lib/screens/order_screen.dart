import 'package:flutter/material.dart';
import 'package:product_app/models/Order.dart';
import 'package:product_app/models/order_item.dart';
import 'package:product_app/screens/order_list_screen.dart';
import 'package:product_app/screens/product_list_screen.dart';
import 'package:product_app/services/api_service.dart';
import '../models/cart.dart' as cart_model;

class OrderScreen extends StatefulWidget {
  final String token;
  final List<OrderItem> orderItems;

  const OrderScreen({Key? key, required this.token, required this.orderItems})
    : super(key: key);

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerEmailController = TextEditingController();
  String _selectedPaymentMethod = 'Cash'; // Default selected method
  bool isLoading = false;

  double get total {
    return widget.orderItems.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  Future<void> submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    final order = Order(
      customerName: _customerNameController.text,
      customerEmail: _customerEmailController.text,
      total: total,
      items: widget.orderItems,
      paymentMethod: _selectedPaymentMethod, // ✅ Include selected method
    );

    try {
      await ApiService(token: widget.token).createOrder(order);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );

      cart_model.Cart.items.clear(); // ✅ Clear cart after success

      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Success'),
              content: const Text('Order completed. Continue shopping?'),
              actions: [
                TextButton(
                  onPressed:
                      () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ProductListScreen(token: widget.token),
                        ),
                        (route) => false,
                      ),
                  child: const Text('Continue Shopping'),
                ),
              ],
            ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Order failed: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Summary')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Items:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...widget.orderItems.map(
                (item) => ListTile(
                  title: Text(
                    item.product?.name ?? 'Product ID: ${item.productId}',
                  ),
                  subtitle: Text(
                    'Qty: ${item.quantity} × \$${item.price.toStringAsFixed(2)}',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Total: \$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _customerNameController,
                decoration: const InputDecoration(labelText: 'Customer Name'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Enter customer name'
                            : null,
              ),
              TextFormField(
                controller: _customerEmailController,
                decoration: const InputDecoration(labelText: 'Customer Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter email';
                  final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  return regex.hasMatch(value) ? null : 'Invalid email';
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedPaymentMethod,
                decoration: const InputDecoration(labelText: 'Payment Method'),
                items: const [
                  DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                  DropdownMenuItem(
                    value: 'Credit Card',
                    child: Text('Credit Card'),
                  ),
                  DropdownMenuItem(
                    value: 'Mobile Payment',
                    child: Text('Mobile Payment'),
                  ),
                ],
                onChanged:
                    (value) => setState(() => _selectedPaymentMethod = value!),
              ),
              const SizedBox(height: 30),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: submitOrder,
                        child: const Text('Place Order'),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => OrderListScreen(token: widget.token),
                            ),
                          );
                        },
                        child: const Text('Order List'),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Continue Shopping'),
                      ),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
