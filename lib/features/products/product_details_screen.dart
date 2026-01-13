import 'package:flutter/material.dart';
import 'product_details_controller.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final _controller = ProductDetailsController();
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final error = await _controller.loadProduct(widget.productId);
    setState(() => _error = error);
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final product = _controller.product!;
    final category = product['category']?.toString() ?? 'No category';
    final description = product['description']?.toString() ?? 'No description';
    final price = '\$${product['price']}';
    final brand = product['brand']?.toString() ?? 'No brand';
    final tags = product['tags']?.toString() ?? 'No tags';

    return Scaffold(
      appBar: AppBar(title: Text(product['title'])),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category : $category'),
            Text('Description : $description'),
            Text('Price : $price'),
            Text('Brand : $brand'),
            Text('Tags : $tags'),
          ],
        ),
      ),
    );
  }
}
