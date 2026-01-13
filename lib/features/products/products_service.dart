import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';

class ProductsService {
  final Dio _dio = DioClient.instance.dio;

  Future<Response> fetchProducts({
    required int limit,
    required int skip,
    String? search,
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
      },
      cancelToken: cancelToken,
    );
  }
}
