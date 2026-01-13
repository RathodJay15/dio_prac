import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';

class ProductDetailsService {
  final Dio _dio = DioClient.instance.dio;

  Future<Response> fetchProduct(int id) {
    return _dio.get(
      '/products/$id',
      options: Options(
        receiveTimeout: const Duration(seconds: 5), //  simulate timeout
      ),
    );
  }
}
