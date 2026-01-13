import 'package:dio/dio.dart';
import '../../core/storage/token_storage.dart';
import 'auth_service.dart';
import '../../core/models/user_model.dart';

class AuthController {
  final AuthService _authService = AuthService();

  Future<String?> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _authService.login(
        username: username,
        password: password,
      );

      final token = response.data['accessToken'];

      if (token != null) {
        await TokenStorage.saveToken(token);
        final data = response.data;
        final user = UserModel.fromJson(data);
        await TokenStorage.saveUser(user);
        return null; // success
      }

      return 'Invalid response from server';
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        return 'Invalid username or password';
      }

      if (e.type == DioExceptionType.connectionTimeout) {
        return 'Connection timeout. Try again.';
      }

      return 'Something went wrong';
    }
  }
}
