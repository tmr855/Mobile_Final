import 'product.dart';

class OrderItem {
  final int productId;
  final int quantity;
  final double price;
  final Product? product;

  OrderItem({
    required this.productId,
    required this.quantity,
    required this.price,
    this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id'],
      quantity: json['quantity'],
      price:
          (json['price'] is String)
              ? double.tryParse(json['price']) ?? 0
              : (json['price']?.toDouble() ?? 0),
      product:
          json['product'] != null ? Product.fromJson(json['product']) : null,
    );
  }

  String get productName {
    return product?.name ?? 'Unknown Product';
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'price': price,
      if (product != null) 'product': product!.toJson(),
    };
  }
}
