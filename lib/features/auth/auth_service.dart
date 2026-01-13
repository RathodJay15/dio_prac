import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';

class AuthService {
  final Dio _dio = DioClient.instance.dio;

  Future<Response> login({
    required String username,
    required String password,
  }) async {
    return await _dio.post(
      ApiConstants.authLogin,
      data: {'username': username, 'password': password},
    );
  }
}
