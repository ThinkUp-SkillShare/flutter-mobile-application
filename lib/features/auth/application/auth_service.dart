import 'dart:convert';
import 'dart:io';
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
  static Future<int?> getStoredUserId() async {
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

  /// Returns the user ID from stored data or token
  static Future<int?> getUserId() async {
    final storedUserId = await getStoredUserId();
    if (storedUserId != null && storedUserId > 0) {
      return storedUserId;
    }

    final token = await getAuthToken();
    if (token == null) return null;

    return _extractUserIdFromToken(token);
  }

  /// Extracts user ID from JWT token
  static int? _extractUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }

      final payload = parts[1];
      final paddingNeeded = (4 - (payload.length % 4)) % 4;
      final paddedPayload = payload + '=' * paddingNeeded;

      final decodedBytes = base64Url.decode(paddedPayload);
      final decodedString = utf8.decode(decodedBytes);
      final payloadMap = json.decode(decodedString) as Map<String, dynamic>;

      // Look for user ID in possible claims
      final userId = payloadMap['nameid'] ??
          payloadMap['uid'] ??
          payloadMap['userId'] ??
          payloadMap['sub'] ??
          payloadMap['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'];

      if (userId == null) return null;

      return userId is int ? userId : int.tryParse(userId.toString());
    } catch (e) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // AUTH & TOKEN VALIDATION
  // ---------------------------------------------------------------------------

  /// Returns `true` if the user is considered authenticated based on local data.
  static Future<bool> isAuthenticated() async {
    final userId = await getStoredUserId();
    final token = await getAuthToken();
    return userId != null && userId > 0 && token != null && token.isNotEmpty;
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
      return false;
    }
  }

  /// Ensures the token is valid. If not, logs out the user automatically.
  /// Returns the token if valid, null otherwise.
  static Future<String?> getValidToken() async {
    try {
      final isValid = await isTokenValid();
      if (!isValid) {
        await logout();
        return null;
      }
      return await getAuthToken();
    } catch (e) {
      await logout();
      return null;
    }
  }

  /// Validates the token by making a request to the backend validation endpoint.
  /// If invalid, logs out the user and returns null.
  static Future<String?> validateAndGetToken() async {
    return await getValidToken();
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
}