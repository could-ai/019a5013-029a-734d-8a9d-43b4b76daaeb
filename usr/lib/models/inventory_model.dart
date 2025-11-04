import 'package:flutter/material.dart';
import '../models/product.dart';

class InventoryModel extends ChangeNotifier {
  final List<Product> _products = [
    Product(
      id: '1',
      name: 'Sample Product 1',
      barcode: '123456789',
      price: 10.99,
      quantity: 50,
    ),
    Product(
      id: '2',
      name: 'Sample Product 2',
      barcode: '987654321',
      price: 25.50,
      quantity: 30,
    ),
  ];

  List<Product> get products => _products;

  void addProduct(Product product) {
    _products.add(product);
    notifyListeners();
  }

  void updateProduct(String id, Product updatedProduct) {
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      _products[index] = updatedProduct;
      notifyListeners();
    }
  }

  void removeProduct(String id) {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  Product? getProductByBarcode(String barcode) {
    return _products.firstWhere(
      (p) => p.barcode == barcode,
      orElse: () => null as Product,
    );
  }

  void updateQuantity(String id, int newQuantity) {
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      _products[index] = _products[index].copyWith(quantity: newQuantity);
      notifyListeners();
    }
  }
}