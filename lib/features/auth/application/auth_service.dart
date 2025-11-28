import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/api_constants.dart';

/// Service responsible for handling authentication-related local storage,
/// token validation, and user identity extraction.
class AuthService {
  // Local storage keys
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _authTokenKey = 'auth_token';

  // ---------------------------------------------------------------------------
  // LOCAL STORAGE METHODS
  // ---------------------------------------------------------------------------

  /// Saves the user's ID, email, and JWT token to local storage.
  static Future<void> saveUserData(int userId, String email, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_userEmailKey, email);
    await prefs.setString(_authTokenKey, token);
  }

  /// Returns stored user ID or null if not found.
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  /// Returns stored user email or null if not found.
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  /// Returns stored authentication token or null if not found.
  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  // ---------------------------------------------------------------------------
  // AUTH & TOKEN VALIDATION
  // ---------------------------------------------------------------------------

  /// Returns `true` if the user is considered authenticated based on local data.
  /// This does NOT verify the token integrity with the backend.
  static Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();

    final userId = prefs.getInt(_userIdKey);
    final token = prefs.getString(_authTokenKey);

    if (userId == null || userId <= 0) return false;
    if (token == null || token.isEmpty) return false;

    return true;
  }

  /// Validates the stored JWT token by making a request to the backend validation endpoint.
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
      // Important debug message in case token validation fails
      print('❌ Error validating token: $e');
      return false;
    }
  }

  /// Ensures the token is valid. If not, logs out the user automatically.
  static Future<String?> getValidToken() async {
    final isValid = await isTokenValid();
    if (!isValid) {
      await logout();
      return null;
    }
    return getAuthToken();
  }

  // ---------------------------------------------------------------------------
  // USER IDENTIFICATION (JWT PARSING)
  // ---------------------------------------------------------------------------

  /// Extracts the user ID from the stored JWT token.
  /// Supports multiple claim formats for compatibility.
  static Future<int?> getCurrentUserId() async {
    try {
      final token = await getAuthToken();
      if (token == null) return null;

      final parts = token.split('.');
      if (parts.length != 3) {
        print('❌ Invalid JWT token format');
        return null;
      }

      try {
        final payload = parts[1];

        // Normalize Base64URL before decoding
        final normalizedPayload = base64Url.normalize(payload);
        final decodedBytes = base64Url.decode(normalizedPayload);
        final decodedString = utf8.decode(decodedBytes);

        final payloadMap = json.decode(decodedString) as Map<String, dynamic>;

        // Extract possible user ID claims
        final userId = payloadMap['nameid'] ??
            payloadMap['uid'] ??
            payloadMap['userId'] ??
            payloadMap['sub'];

        if (userId != null) {
          return int.tryParse(userId.toString());
        }

        print('❌ User ID not found in JWT claims');
        return null;
      } catch (e) {
        print('❌ Error decoding JWT payload: $e');
        return null;
      }
    } catch (e) {
      print('❌ Error getting current user ID: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // LOGOUT & CLEANUP
  // ---------------------------------------------------------------------------

  /// Logs out the user by clearing all stored authentication data.
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_authTokenKey);
  }

  /// Clears all stored user data. Alias for logout().
  static Future<void> clearUserData() async {
    await logout();
  }

  // ---------------------------------------------------------------------------
  // PROFILE UPDATE
  // ---------------------------------------------------------------------------

  /// Updates user profile data such as profile image.
  static Future<void> updateUserProfile(String? profileImagePath) async {
    final prefs = await SharedPreferences.getInstance();

    if (profileImagePath != null) {
      await prefs.setString('profileImage', profileImagePath);
    }
  }

}
