import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';

class UsersService {
  final Dio _dio = DioClient.instance.dio;

  Future<Response> fetchUsers({
    required int limit,
    required int skip,
    CancelToken? cancelToken,
  }) async {
    return await _dio.get(
      '/users',
      queryParameters: {'limit': limit, 'skip': skip},
      cancelToken: cancelToken,
    );
  }
}
