class Product {
  final String id;
  final String name;
  final String barcode;
  final double price;
  final int quantity;

  Product({
    required this.id,
    required this.name,
    required this.barcode,
    required this.price,
    required this.quantity,
  });

  Product copyWith({
    String? id,
    String? name,
    String? barcode,
    double? price,
    int? quantity,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'barcode': barcode,
      'price': price,
      'quantity': quantity,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      barcode: json['barcode'],
      price: json['price'],
      quantity: json['quantity'],
    );
  }
}