import 'package:dio/dio.dart';
import 'network_interceptor.dart';
import '/core/constants/api_constants.dart';

class DioClient {
  static DioClient? _instance;
  late Dio dio;

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: Duration(seconds: 10),
        headers: {'Accept': 'application/json'},
      ),
    );
    dio.interceptors.add(NetworkInterceptor());
  }
  static DioClient get instance {
    _instance ??= DioClient._internal(); //??= means “assign only if null”.
    return _instance!;
  } //A lazy Singleton getter that returns the same DioClient instance every time.
}
