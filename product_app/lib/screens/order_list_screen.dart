import 'package:flutter/material.dart';
import '../models/Order.dart';
import '../services/api_service.dart';
import 'order_detail_screen.dart';

class OrderListScreen extends StatefulWidget {
  final String token;

  const OrderListScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  List<Order> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      orders =
          (await ApiService(token: widget.token).getOrders()).cast<Order>();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load orders: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : orders.isEmpty
              ? const Center(child: Text('No orders found'))
              : ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return ListTile(
                    title: Text(order.customerName),
                    subtitle: Text(
                      'Total: \$${order.total.toStringAsFixed(2)}',
                    ),
                    trailing: Text('${order.items.length} items'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderDetailScreen(order: order),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
