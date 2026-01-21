import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';

class ProductsService {
  final Dio _dio = DioClient.instance.dio;

  Future<Response> fetchProducts({
    required int limit,
    required int skip,
    String? search,
    String? category,
    String? sortBy,
    String? order,
    CancelToken? cancelToken,
  }) {
    return _dio.get(
      search == null || search.isEmpty
          ? ApiConstants.products
          : ApiConstants.productSearch,
      queryParameters: {
        'limit': limit,
        'skip': skip,
        if (search != null && search.isNotEmpty) 'q': search,
        if (category != null) 'category': category,
        if (sortBy != null) 'sortBy': sortBy,
        if (order != null) 'order': order,
      },
      cancelToken: cancelToken,
    );
  }

  Future<List<String>> fetchCategories() async {
    final response = await _dio.get(ApiConstants.productCategory);
    return List<String>.from(response.data);
  }

  Future<Response> fetchProductsByCategory({
    required String category,
    required int limit,
    required int skip,
    CancelToken? cancelToken,
  }) {
    return _dio.get(
      '/products/category/$category',
      queryParameters: {'limit': limit, 'skip': skip},
      cancelToken: cancelToken,
    );
  }
}
