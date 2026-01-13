import 'package:flutter/material.dart';
import 'add_product_controller.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _controller = AddProductController();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();

  String? _error;

  Future<void> _submit() async {
    setState(() => _error = null);

    // 🔴 Fake image path for practice
    const fakeImagePath = '/storage/emulated/0/Download/feather.png';

    final error = await _controller.addProduct(
      title: _titleController.text,
      price: int.tryParse(_priceController.text) ?? 0,
      imagePath: fakeImagePath,
    );

    if (!mounted) return;

    setState(() => _error = error);

    if (error == null) {
      setState(() {
        _error = 'product added successfully!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price'),
            ),
            const SizedBox(height: 20),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _controller.isLoading ? null : _submit,
              child: _controller.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
