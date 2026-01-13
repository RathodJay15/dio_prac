import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class TokenStorage {
  static const _tokenKey = 'access_token';
  static const _userKey = 'user_profile';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_userKey);
    if (data == null) return null;
    return UserModel.fromJson(jsonDecode(data));
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}

//////Save token in secure storage-----------------------------------------
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class SecureTokenStorage {
//   static const _keyAccessToken = 'access_token';

//   static const _storage = FlutterSecureStorage();

//   // Save token
//   static Future<void> saveAccessToken(String token) async {
//     await _storage.write(
//       key: _keyAccessToken,
//       value: token,
//     );
//   }

//   // Read token
//   static Future<String?> getAccessToken() async {
//     return await _storage.read(key: _keyAccessToken);
//   }

//   // Clear token (logout / 401)
//   static Future<void> clearAccessToken() async {
//     await _storage.delete(key: _keyAccessToken);
//   }
// }
