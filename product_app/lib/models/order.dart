import 'order_item.dart';

class Order {
  final String customerName;
  final String customerEmail;
  final double total;
  final List<OrderItem> items;
  final String paymentMethod; // ✅ New field

  Order({
    required this.customerName,
    required this.customerEmail,
    required this.total,
    required this.items,
    required this.paymentMethod, // ✅ Add to constructor
  });

  Map<String, dynamic> toJson() {
    return {
      'customer_name': customerName,
      'customer_email': customerEmail,
      'total': total,
      'payment_method': paymentMethod, // ✅ Include in JSON
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    final totalRaw = json['total'];
    double parsedTotal = 0;

    if (totalRaw is String) {
      parsedTotal = double.tryParse(totalRaw) ?? 0;
    } else if (totalRaw is num) {
      parsedTotal = totalRaw.toDouble();
    } else {
      print(
        "Unexpected 'total' type: ${totalRaw.runtimeType}, value: $totalRaw",
      );
    }

    return Order(
      customerName: json['customer_name'] ?? '',
      customerEmail: json['customer_email'] ?? '',
      total: parsedTotal,
      paymentMethod: json['payment_method'] ?? '', // ✅ Parse from JSON
      items:
          (json['items'] as List?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  get id => null;
}
