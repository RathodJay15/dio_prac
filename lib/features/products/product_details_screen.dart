import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'product_details_controller.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final ProductDetailsController _controller = ProductDetailsController();
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  int _currentIndex = 0;
  double _rating = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final error = await _controller.loadProduct(widget.productId);
    if (error == null) {
      _rating = (_controller.product!['rating'] ?? 0).toDouble();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    if (_controller.product == null) {
      return Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: _load,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 6,
            ),
            child: const Text('Retry'),
          ),
        ),
      );
    }

    final product = _controller.product!;
    final List images = product['images'] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,

      body: Stack(
        children: [
          ///  TOP IMAGE SECTION
          SafeArea(
            child: Column(
              children: [
                _topBar(context),
                const SizedBox(height: 16),

                ///  IMAGE CAROUSEL
                CarouselSlider(
                  carouselController: _carouselController,
                  options: CarouselOptions(
                    height: 350,
                    aspectRatio: 16 / 9,
                    viewportFraction: 0.8,
                    initialPage: 0,
                    enlargeCenterPage: true,
                    enlargeFactor: 0.3,
                    onPageChanged: (index, _) =>
                        setState(() => _currentIndex = index),
                  ),
                  items: images.map<Widget>((img) {
                    return GestureDetector(
                      onTap: () => _openImagePreview(img),
                      child: Container(
                        width: 350,
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(color: Colors.orange, width: 2),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Image.network(img, fit: BoxFit.contain),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 12),

                ///  THUMBNAILS
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (index) {
                    final isSelected = _currentIndex == index;
                    return GestureDetector(
                      onTap: () => _carouselController.animateToPage(index),
                      child: Container(
                        height: 50,
                        width: 70,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.orange : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? Colors.orange : Colors.grey,
                            width: 1.5,
                          ),
                        ),
                        child: Image.network(
                          images[index],
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          /// ⬆️ BOTTOM DETAILS
          _bottomSheet(product),
        ],
      ),

      ///  ADD TO CART
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_shopping_cart_outlined),
      ),
    );
  }

  // -------------------------------------------

  Widget _topBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _iconBox(icon: Icons.arrow_back, onTap: () => Navigator.pop(context)),
          _iconBox(icon: Icons.favorite, color: Colors.orange, onTap: () {}),
        ],
      ),
    );
  }

  Widget _iconBox({
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.black,
  }) {
    return Container(
      height: 55,
      width: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: color, size: 28),
      ),
    );
  }

  // --------------------------------------------------------

  Widget _bottomSheet(Map<String, dynamic> product) {
    return DraggableScrollableSheet(
      initialChildSize: 0.38,
      minChildSize: 0.38,
      maxChildSize: 0.55,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              _dragHandle(),

              /// TITLE + PRICE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      product['title'],
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '\$${product['price']}',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              /// RATING
              Row(
                children: [
                  RatingBarIndicator(
                    rating: _rating,
                    itemBuilder: (_, __) =>
                        const Icon(Icons.star_rounded, color: Colors.orange),
                    itemCount: 5,
                    itemSize: 28,
                  ),
                  const SizedBox(width: 10),
                  Text(_rating.toStringAsFixed(1)),
                ],
              ),

              const SizedBox(height: 20),

              _sectionTitle("Description"),
              Text(
                product['description'],
                style: const TextStyle(color: Colors.grey, height: 1.5),
              ),

              const SizedBox(height: 16),

              _sectionTitle("Brand"),
              Text(
                product['brand'] ?? "N/A",
                style: const TextStyle(color: Colors.grey, height: 1.5),
              ),

              const SizedBox(height: 16),

              _sectionTitle("Category"),
              Text(
                product['category'],
                style: const TextStyle(color: Colors.grey, height: 1.5),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dragHandle() => Center(
    child: Container(
      height: 5,
      width: 40,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    ),
  );

  // ------------------------------------------------

  void _openImagePreview(String imageUrl) {
    showDialog(
      context: context,

      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.85, // 👈 dialog width
            height: MediaQuery.of(context).size.height * 0.6,
            child: PinchZoom(
              maxScale: 5,
              child: Image.network(imageUrl, fit: BoxFit.contain),
            ),
          ),
        );
      },
    );
  }
}
