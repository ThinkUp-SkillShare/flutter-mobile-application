import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/api_constants.dart';

class AuthService {
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _authTokenKey = 'auth_token';

  static Future<void> saveUserData(
    int userId,
    String email,
    String token,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_userEmailKey, email);
    await prefs.setString(_authTokenKey, token);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  static Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();

    final userId = prefs.getInt(_userIdKey);
    final token = prefs.getString(_authTokenKey);

    if (userId == null || userId <= 0) {
      return false;
    }

    if (token == null || token.isEmpty) {
      return false;
    }

    return true;
  }

  static Future<bool> isTokenValid() async {
    try {
      final token = await getAuthToken();
      if (token == null) return false;

      final response = await http.get(
        Uri.parse(ApiConstants.validateTokenEndpoint),
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error validating token: $e');
      return false;
    }
  }

  static Future<String?> getValidToken() async {
    final isValid = await isTokenValid();
    if (!isValid) {
      await logout();
      return null;
    }
    return await getAuthToken();
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_authTokenKey);
    print('🚪 User logged out successfully');
  }

  static Future<void> clearUserData() async {
    await logout();
  }

  static Future<void> updateUserProfile(String? profileImage) async {
    final prefs = await SharedPreferences.getInstance();
    if (profileImage != null) {}
  }

  static Future<int?> getCurrentUserId() async {
    try {
      final token = await getAuthToken();
      if (token == null) return null;

      // Decodificar el token JWT
      final parts = token.split('.');
      if (parts.length != 3) {
        print('❌ Invalid JWT token format');
        return null;
      }

      try {
        final payload = parts[1];
        // Normalizar base64url
        final normalizedPayload = base64Url.normalize(payload);
        final decodedBytes = base64Url.decode(normalizedPayload);
        final decodedString = utf8.decode(decodedBytes);
        final payloadMap = json.decode(decodedString) as Map<String, dynamic>;

        print('🔍 JWT Payload claims:');
        payloadMap.forEach((key, value) {
          print('   $key: $value');
        });

        // Buscar el user ID en diferentes claims
        final userId =
            payloadMap['nameid'] ??
            payloadMap['uid'] ??
            payloadMap['userId'] ??
            payloadMap['sub'];

        if (userId != null) {
          print('✅ User ID found in token: $userId');
          return int.tryParse(userId.toString());
        } else {
          print('❌ User ID not found in any claim');
          return null;
        }
      } catch (e) {
        print('❌ Error decoding JWT payload: $e');
        return null;
      }
    } catch (e) {
      print('❌ Error getting current user ID: $e');
      return null;
    }
  }
}
