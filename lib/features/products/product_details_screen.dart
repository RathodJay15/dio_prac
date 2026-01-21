import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'product_details_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (_controller.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    if (_controller.product == null) {
      return Scaffold(
        body: Center(
          child: ElevatedButton(onPressed: _load, child: const Text('Retry')),
        ),
      );
    }

    final product = _controller.product!;
    final images = product['images'] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLandscape
            ? _landscapeLayout(product, images)
            : _portraitLayout(product, images),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_shopping_cart_outlined),
      ),
    );
  }

  // ----------------------------------------------------
  // PORTRAIT LAYOUT
  // ----------------------------------------------------

  Widget _portraitLayout(Map<String, dynamic> product, List images) {
    return Stack(
      children: [
        Column(
          children: [
            _topBar(),
            const SizedBox(height: 16),
            _carousel(images, height: 350),
            const SizedBox(height: 12),
            _thumbnails(images),
          ],
        ),
        _bottomSheet(product),
      ],
    );
  }

  // ----------------------------------------------------
  // LANDSCAPE LAYOUT
  // ----------------------------------------------------

  Widget _landscapeLayout(Map<String, dynamic> product, List images) {
    return Row(
      children: [
        /// LEFT — CAROUSEL
        Expanded(
          flex: 5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _topBar(),
              Expanded(child: _carousel(images)),
              const SizedBox(height: 12),
              _thumbnails(images),
              const SizedBox(height: 5),
            ],
          ),
        ),

        /// RIGHT — DETAILS
        Expanded(
          flex: 4,
          child: Container(
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 20),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _detailsContent(product),
            ),
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------
  // TOP BAR
  // ----------------------------------------------------

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _iconBox(Icons.arrow_back, () => Navigator.pop(context)),
          _iconBox(Icons.favorite, () {}, color: Colors.orange),
        ],
      ),
    );
  }

  Widget _iconBox(
    IconData icon,
    VoidCallback onTap, {
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
        icon: Icon(icon, color: color, size: 28),
        onPressed: onTap,
      ),
    );
  }

  // ----------------------------------------------------
  // CAROUSEL
  // ----------------------------------------------------

  Widget _carousel(List images, {double? height}) {
    return CarouselSlider(
      carouselController: _carouselController,
      options: CarouselOptions(
        height: height,
        enlargeCenterPage: true,
        viewportFraction: 0.85,
        onPageChanged: (index, _) {
          setState(() => _currentIndex = index);
        },
      ),
      items: images.map<Widget>((img) {
        return GestureDetector(
          onTap: () => _openImagePreview(img),
          child: Container(
            width: 350,
            decoration: BoxDecoration(
              color: Colors.orangeAccent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Colors.orange, width: 2),
            ),
            padding: const EdgeInsets.all(16),
            child: CachedNetworkImage(
              imageUrl: img,
              height: 120,
              fit: BoxFit.contain,
              errorWidget: (context, url, error) => Container(
                color: Colors.grey.shade200,
                child: Icon(Icons.image_not_supported),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ----------------------------------------------------
  // THUMBNAILS
  // ----------------------------------------------------

  Widget _thumbnails(List images) {
    return Row(
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
              ),
            ),
            child: CachedNetworkImage(
              imageUrl: images[index],
              height: 120,
              fit: BoxFit.contain,
              errorWidget: (context, url, error) => Container(
                color: Colors.grey.shade200,
                child: Icon(Icons.image_not_supported),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ----------------------------------------------------
  // DETAILS CONTENT
  // ----------------------------------------------------

  Widget _detailsContent(Map<String, dynamic> product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                product['title'],
                maxLines: 2,
                style: const TextStyle(
                  overflow: TextOverflow.ellipsis,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              '\$${product['price']}',
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
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
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${product['discountPercentage']}% off',
                  style: const TextStyle(color: Colors.grey, fontSize: 18),
                ),
              ),
            ),
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
    );
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    ),
  );

  // ----------------------------------------------------
  // PORTRAIT BOTTOM SHEET
  // ----------------------------------------------------

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
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${product['discountPercentage']}% off',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
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
  // ----------------------------------------------------
  // IMAGE PREVIEW
  // ----------------------------------------------------

  void _openImagePreview(String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SizedBox(
          width: 500,
          height: MediaQuery.of(context).size.height * 0.6,
          child: PinchZoom(
            maxScale: 5,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              height: 120,
              fit: BoxFit.contain,
              errorWidget: (context, url, error) => Container(
                color: Colors.grey.shade200,
                child: Icon(Icons.image_not_supported),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
