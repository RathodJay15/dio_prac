import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/token_storage.dart';

class NetworkInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await TokenStorage.getToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Logging (request)
    debugPrint('➡️ REQUEST: ${options.method} ${options.uri}');
    debugPrint('Headers: ${options.headers}');
    debugPrint('Body: ${options.data}');

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Logging (response)
    debugPrint('✅ RESPONSE: ${response.requestOptions.uri}');
    debugPrint('Status: ${response.statusCode}');
    debugPrint('Data: ${response.data}');

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('❌ ERROR: ${err.requestOptions.uri}');
    debugPrint('Type: ${err.type}');
    debugPrint('Message: ${err.message}');

    if (err.response?.statusCode == 401) {
      // Token expired / invalid
      TokenStorage.clearToken();
      // Later: redirect to login
    }

    super.onError(err, handler);
  }
}
