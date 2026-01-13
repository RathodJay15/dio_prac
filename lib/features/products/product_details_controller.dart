import 'package:dio/dio.dart';
import 'product_details_service.dart';

class ProductDetailsController {
  final ProductDetailsService _service = ProductDetailsService();

  Map<String, dynamic>? product;
  bool isLoading = false;

  Future<String?> loadProduct(int id) async {
    isLoading = true;

    try {
      final response = await _service.fetchProduct(id);
      product = response.data;
      isLoading = false;
      return null;
    } on DioException catch (e) {
      isLoading = false;

      if (e.type == DioExceptionType.receiveTimeout) {
        return 'Request timed out. Retry?';
      }

      return 'Failed to load product';
    }
  }
}
