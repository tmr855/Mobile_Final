import 'package:flutter/material.dart';
import '../models/Order.dart';

class OrderDetailScreen extends StatelessWidget {
  final Order order;

  const OrderDetailScreen({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              'Customer Name: ${order.customerName}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Customer Email: ${order.customerEmail}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              'Total: \$${order.total.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 20),
            const Text(
              'Items:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...order.items.map(
              (item) => ListTile(
                title: Text(item.productName),
                subtitle: Text(
                  'Qty: ${item.quantity} × \$${item.price.toStringAsFixed(2)}',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
