import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../models/inventory_model.dart';
import '../models/product.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final List<Map<String, dynamic>> _cart = [];
  bool _isScanning = false;
  MobileScannerController cameraController = MobileScannerController();

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
    });
  }

  void _stopScanning() {
    setState(() {
      _isScanning = false;
    });
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    final barcode = capture.barcodes.first;
    if (barcode.rawValue != null) {
      _addProductToCart(barcode.rawValue!);
      setState(() {
        _isScanning = false;
      });
    }
  }

  void _addProductToCart(String barcode) {
    final inventory = Provider.of<InventoryModel>(context, listen: false);
    final product = inventory.getProductByBarcode(barcode);
    if (product != null && product.quantity > 0) {
      final existingItem = _cart.firstWhere(
        (item) => item['product'].id == product.id,
        orElse: () => null,
      );
      if (existingItem != null) {
        existingItem['quantity'] += 1;
      } else {
        _cart.add({'product': product, 'quantity': 1});
      }
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product not found or out of stock')),
      );
    }
  }

  void _removeFromCart(int index) {
    setState(() {
      _cart.removeAt(index);
    });
  }

  void _updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      _removeFromCart(index);
    } else {
      setState(() {
        _cart[index]['quantity'] = newQuantity;
      });
    }
  }

  double _getTotal() {
    return _cart.fold(0.0, (total, item) {
      final product = item['product'] as Product;
      final quantity = item['quantity'] as int;
      return total + (product.price * quantity);
    });
  }

  void _processSale() {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty')),
      );
      return;
    }

    final inventory = Provider.of<InventoryModel>(context, listen: false);
    for (final item in _cart) {
      final product = item['product'] as Product;
      final quantity = item['quantity'] as int;
      final newQuantity = product.quantity - quantity;
      inventory.updateQuantity(product.id, newQuantity);
    }

    setState(() {
      _cart.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sale processed successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Entry'),
        actions: [
          IconButton(
            onPressed: _startScanning,
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan Product',
          ),
        ],
      ),
      body: _isScanning ? _buildScannerView() : _buildCartView(),
      bottomNavigationBar: _cart.isNotEmpty ? _buildCheckoutBar() : null,
    );
  }

  Widget _buildScannerView() {
    return Stack(
      children: [
        MobileScanner(
          controller: cameraController,
          onDetect: _onBarcodeDetected,
        ),
        Positioned(
          top: 20,
          right: 20,
          child: IconButton(
            onPressed: _stopScanning,
            icon: const Icon(Icons.close, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black54,
            ),
          ),
        ),
        const Positioned(
          bottom: 100,
          left: 20,
          right: 20,
          child: Text(
            'Scan product barcode',
            style: TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildCartView() {
    if (_cart.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Cart is empty',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Tap the scanner icon to add products',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _cart.length,
      itemBuilder: (context, index) {
        final item = _cart[index];
        final product = item['product'] as Product;
        final quantity = item['quantity'] as int;
        final subtotal = product.price * quantity;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('Barcode: ${product.barcode}'),
                      Text('$${product.price.toStringAsFixed(2)} each'),
                      Text('Subtotal: $${subtotal.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _updateQuantity(index, quantity - 1),
                      icon: const Icon(Icons.remove),
                    ),
                    Text(
                      quantity.toString(),
                      style: const TextStyle(fontSize: 18),
                    ),
                    IconButton(
                      onPressed: () => _updateQuantity(index, quantity + 1),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => _removeFromCart(index),
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCheckoutBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Total: $${_getTotal().toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: _processSale,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Process Sale'),
          ),
        ],
      ),
    );
  }
}