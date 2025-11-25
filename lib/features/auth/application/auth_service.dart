import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _authTokenKey = 'auth_token';

  static Future<void> saveUserData(int userId, String email, String token) async {
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


  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_authTokenKey);
  }

  static Future<void> updateUserProfile(String? profileImage) async {
    final prefs = await SharedPreferences.getInstance();
    if (profileImage != null) {
    }
  }
}