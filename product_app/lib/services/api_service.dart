import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:product_app/models/Order.dart' as order_lower;
import 'package:product_app/models/order_item.dart';
import 'package:product_app/models/product.dart';

class ApiService {
  final String baseUrl = 'http://127.0.0.1:8000/api';
  final String token;

  ApiService({required this.token});

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  Future<List<Product>> getProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/products'),
      headers: _headers,
    );

    print('getProducts response status: ${response.statusCode}');
    print('getProducts response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> list = json.decode(response.body);
      return list.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<Product> createProduct(Product product) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: _headers,
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode == 201) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create product');
    }
  }

  Future<Product> updateProduct(Product product) async {
    final response = await http.put(
      Uri.parse('$baseUrl/products/${product.id}'),
      headers: _headers,
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update product');
    }
  }

  Future<void> deleteProduct(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/products/$id'),
      headers: _headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete product');
    }
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/categories'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<void> createOrder(order_lower.Order order) async {
    final url = Uri.parse('$baseUrl/orders');

    final Map<String, dynamic> orderData = {
      'customer_name': order.customerName,
      'customer_email': order.customerEmail,
      'total': order.total,
      'payment_method': order.paymentMethod, // ✅ Add this line
      'items':
          order.items
              .map(
                (item) => {
                  'product_id': item.productId,
                  'quantity': item.quantity,
                  'price': item.price,
                },
              )
              .toList(),
    };

    print('Sending order data: ${jsonEncode(orderData)}');

    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode(orderData),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode != 201) {
      throw Exception('Failed to create order: ${response.body}');
    }
  }

  Future<List<order_lower.Order>> getOrders() async {
    final url = Uri.parse('$baseUrl/orders');
    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      return data.map((orderJson) {
        // Safely extract total
        final rawTotal = orderJson['total'];
        double parsedTotal;

        if (rawTotal is String) {
          parsedTotal = double.tryParse(rawTotal) ?? 0;
        } else if (rawTotal is num) {
          parsedTotal = rawTotal.toDouble();
        } else {
          parsedTotal = 0;
        }

        // Parse items
        final itemsJson = orderJson['items'] as List? ?? [];
        final items =
            itemsJson.map((itemJson) => OrderItem.fromJson(itemJson)).toList();

        return order_lower.Order(
          customerName: orderJson['customer_name'] ?? '',
          customerEmail: orderJson['customer_email'] ?? '',
          total: parsedTotal,
          items: items,
          paymentMethod: '',
        );
      }).toList();
    } else {
      throw Exception('Failed to load orders');
    }
  }
}
