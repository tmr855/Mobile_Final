class Product {
  final int id;
  final String name;
  final double price;
  final String? image;
  final String? categoryName; // NEW

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.image,
    this.categoryName, // NEW
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price:
          (json['price'] is String)
              ? double.tryParse(json['price']) ?? 0
              : (json['price']?.toDouble() ?? 0),
      image: json['image'],
      categoryName: json['category']?['name'], // NEW
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image': image,
      'categoryName': categoryName, // NEW
    };
  }
}
