import 'package:dio/dio.dart';
import 'package:dio_prac/core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';

class AddProductService {
  final Dio _dio = DioClient.instance.dio;

  Future<Response> addProduct({
    required String title,
    required int price,
    required MultipartFile image,
  }) {
    final formData = FormData.fromMap({
      'title': title,
      'price': price,
      'image': image, // DummyJSON accepts this key
    });

    return _dio.post(ApiConstants.addProduct, data: formData);
  }
}
