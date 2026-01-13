import 'package:flutter/material.dart';
import 'products_controller.dart';
import 'product_details_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ProductsController _controller = ProductsController();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String? _error;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _scrollController.addListener(_onScroll);

    _searchController.addListener(() {
      setState(() {}); // updates suffixIcon visibility
    });
  }

  void _onSearchPressed() {
    FocusScope.of(context).unfocus();

    final query = _searchController.text.trim();

    _controller.fetchProducts(refresh: true, search: query).then((error) {
      setState(() => _error = error);
    });
  }

  void _startSearch() {
    setState(() => _isSearching = true);
    _searchFocusNode.requestFocus();
  }

  void _closeOrClearSearch() {
    if (_searchController.text.isNotEmpty) {
      // 🔹 Clear text
      _searchController.clear();

      _controller.fetchProducts(refresh: true, search: '').then((error) {
        setState(() => _error = error);
      });
    } else {
      // 🔹 Close search mode
      _searchFocusNode.unfocus();
      setState(() => _isSearching = false);
    }
  }

  Future<void> _loadInitial() async {
    final error = await _controller.fetchProducts();
    setState(() => _error = error);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _controller.fetchProducts(search: _searchController.text).then((error) {
        if (error != null) {
          if (_controller.products.isEmpty) {
            setState(() => _error = error);
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(error)));
          }
        } else {
          setState(() => _error = null);
        }
      });
    }
  }

  // void _onSearchChanged(String value) {
  //   _controller.fetchProducts(refresh: true, search: value).then((error) {
  //     if (error != null) {
  //       if (_controller.products.isEmpty) {
  //         setState(() => _error = error);
  //       } else {
  //         ScaffoldMessenger.of(
  //           context,
  //         ).showSnackBar(SnackBar(content: Text(error)));
  //       }
  //     } else {
  //       setState(() => _error = null);
  //     }
  //   });
  // }

  @override
  void dispose() {
    _controller.cancelRequest();
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchController,
            // onChanged: _onSearchChanged,
            focusNode: _searchFocusNode,
            onTap: _startSearch,
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: Icon(Icons.search),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isSearching)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _closeOrClearSearch,
                    ),
                  TextButton(
                    onPressed: () => _onSearchPressed(),
                    child: Text('Search'),
                  ),
                ],
              ),
            ),
          ),
        ),

        Expanded(
          child: _controller.products.isEmpty
              ? _controller.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_error!),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _loadInitial,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : const Center(child: Text('No products found'))
              : ListView.builder(
                  controller: _scrollController,
                  itemCount:
                      _controller.products.length +
                      (_controller.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _controller.products.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final product = _controller.products[index];

                    return ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailsScreen(productId: product['id']),
                          ),
                        );
                      },
                      leading: Text(
                        product['id'].toString(),
                        style: TextStyle(fontSize: 25),
                      ),
                      title: Text(product['title']),
                      subtitle: Text('${product['category']}'),
                      trailing: Text(
                        '\$${product['price']}',
                        style: TextStyle(fontSize: 20),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
