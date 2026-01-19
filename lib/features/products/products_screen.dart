import 'package:flutter/material.dart';
import 'products_controller.dart';
import 'product_details_screen.dart';
import 'package:shimmer/shimmer.dart';

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
      setState(() {});
    });
  }

  Future<void> _loadInitial() async {
    final error = await _controller.fetchProducts();
    setState(() => _error = error);
  }

  void _onScroll() {
    if (_controller.isLoading) return;
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
          // THIS IS THE MISSING PIECE
          setState(() {});
        }
      });
    }
  }

  void _startSearch() {
    setState(() => _isSearching = true);
    _searchFocusNode.requestFocus();
  }

  void _onSearchPressed() {
    FocusScope.of(context).unfocus();
    final query = _searchController.text.trim();

    _controller.fetchProducts(refresh: true, search: query).then((error) {
      setState(() => _error = error);
    });
  }

  void _closeOrClearSearch() {
    if (_searchController.text.isNotEmpty) {
      _searchController.clear();
      _controller.fetchProducts(refresh: true, search: '').then((error) {
        setState(() => _error = error);
      });
    } else {
      _searchFocusNode.unfocus();
      setState(() => _isSearching = false);
    }
  }

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
    Widget buildProductCard(
      BuildContext context,
      Map<String, dynamic> product,
    ) {
      return Container(
        margin: EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              InkWell(
                splashColor: Colors.orange.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ProductDetailsScreen(productId: product['id']),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /// IMAGE (ALWAYS CENTERED)
                      Expanded(
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.orangeAccent.withValues(
                                  alpha: 0.20,
                                ),
                              ),
                              Image.network(
                                product['thumbnail'] ?? product['image'] ?? '',
                                height: 120,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.image_not_supported),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      /// TITLE
                      Text(
                        product['title'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      /// CATEGORY
                      Text(
                        product['category'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.orange,
                        ),
                      ),

                      /// PRICE
                      Text(
                        '\$ ${product['price']}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                top: 6,
                left: 6,
                child: IconButton(
                  icon: const Icon(
                    Icons.favorite_border_outlined,
                    color: Colors.orange,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      );
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(10),
          sliver: SliverToBoxAdapter(
            child: TextSelectionTheme(
              data: TextSelectionThemeData(
                cursorColor: Colors.orange,
                selectionColor: Colors.orange.withValues(alpha: 0.25),
                selectionHandleColor: Colors.orange,
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onTap: _startSearch,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search, color: Colors.orange),
                  filled: true,
                  fillColor: Colors.orangeAccent.withValues(alpha: 0.20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isSearching)
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: _closeOrClearSearch,
                        ),
                      TextButton(
                        onPressed: _onSearchPressed,
                        child: const Text(
                          'Search',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_controller.isLoading && _controller.products.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) => const ProductCardShimmer(),
                childCount: 6,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.70,
              ),
            ),
          )
        ///  ERROR STATE
        else if (_error != null && _controller.products.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _error!,
                    style: TextStyle(fontSize: 20, color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loadInitial,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      elevation: 5,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          )
        /// 🟡 EMPTY STATE
        else if (_controller.products.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                'No products found',
                style: TextStyle(fontSize: 20, color: Colors.blueGrey),
              ),
            ),
          )
        ///  PRODUCT GRID
        else ...[
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                final product = _controller.products[index];
                return buildProductCard(context, product);
              }, childCount: _controller.products.length),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisSpacing: 10,
                crossAxisSpacing: 20,
                childAspectRatio: 0.70,
              ),
            ),
          ),
        ],

        /// FULL WIDTH LOADER
        // if (_controller.hasMore)
        //   SliverToBoxAdapter(
        //     child: Padding(
        //       padding: const EdgeInsets.symmetric(vertical: 24),
        //       child: Center(
        //         child: CircularProgressIndicator(color: Colors.orangeAccent),
        //       ),
        //     ),
        //   ),
        if (_controller.hasMore)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (_, __) => const ProductCardShimmer(),
                childCount: 4,
              ),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisSpacing: 10,
                crossAxisSpacing: 20,
                childAspectRatio: 0.70,
              ),
            ),
          )
        else
          SliverToBoxAdapter(child: SizedBox(height: 10)),
      ],
    );
  }
}

class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        clipBehavior: Clip.antiAlias,
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// IMAGE SHIMMER
                    Expanded(
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 120,
                              width: 120,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// TITLE (2 LINES)
                    _line(width: double.infinity, height: 16),
                    const SizedBox(height: 6),
                    _line(width: 120, height: 16),

                    const SizedBox(height: 6),

                    /// CATEGORY
                    _line(width: 80, height: 14),

                    const SizedBox(height: 8),

                    /// PRICE
                    _line(width: 70, height: 22),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _line({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
