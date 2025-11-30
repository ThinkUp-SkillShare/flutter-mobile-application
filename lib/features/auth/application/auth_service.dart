import 'dart:convert';
import 'dart:typed_data';
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

  // ---------------------------------------------------------------------------
  // USER ID EXTRACTION
  // ---------------------------------------------------------------------------

  static Future<int?> getUserId() async {
    try {
      // Primero intenta obtener el ID almacenado localmente
      final storedUserId = await getStoredUserId();
      if (storedUserId != null && storedUserId > 0) {
        return storedUserId;
      }

      // Si no hay ID almacenado, intenta extraerlo del token
      final token = await getAuthToken();
      if (token == null) return null;

      return _extractUserIdFromToken(token);
    } catch (e) {
      print('❌ Error getting user ID: $e');
      return null;
    }
  }

  /// Extrae el user ID del token JWT de forma robusta
  static int? _extractUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        print('❌ Invalid JWT token format');
        return null;
      }

      final payload = parts[1];

      // Agregar padding si es necesario
      String paddedPayload = payload;
      final paddingNeeded = (4 - (payload.length % 4)) % 4;
      if (paddingNeeded > 0) {
        paddedPayload = payload + '=' * paddingNeeded;
      }

      // Decodificar Base64Url
      final decodedBytes = base64Url.decode(paddedPayload);
      final decodedString = utf8.decode(decodedBytes);
      final payloadMap = json.decode(decodedString) as Map<String, dynamic>;

      print('🔍 JWT Payload: $payloadMap');

      // Buscar el user ID en diferentes claims posibles
      final userId = payloadMap['nameid'] ??
          payloadMap['uid'] ??
          payloadMap['userId'] ??
          payloadMap['sub'] ??
          payloadMap['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'];

      if (userId == null) {
        print('❌ User ID not found in JWT claims');
        return null;
      }

      // Convertir a int
      final userIdInt = userId is int ? userId : int.tryParse(userId.toString());

      if (userIdInt != null) {
        // Guardar el ID localmente para futuras consultas
        _saveUserIdLocally(userIdInt);
        return userIdInt;
      }

      print('❌ Could not parse user ID: $userId');
      return null;

    } catch (e) {
      print('❌ Error extracting user ID from token: $e');
      return null;
    }
  }

  /// Guarda el user ID localmente
  static Future<void> _saveUserIdLocally(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
  }

  static Future<String?> getUserIdAsString() async {
    final userId = await getUserId();
    return userId?.toString();
  }

  // ---------------------------------------------------------------------------
  // AUTH & TOKEN VALIDATION
  // ---------------------------------------------------------------------------

  /// Returns `true` if the user is considered authenticated based on local data.
  static Future<bool> isAuthenticated() async {
    final userId = await getStoredUserId();
    final token = await getAuthToken();

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

  // ---------------------------------------------------------------------------
  // DEBUG METHODS
  // ---------------------------------------------------------------------------

  static Future<void> debugToken() async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        print('❌ No token found');
        return;
      }

      print('🔍 Token: $token');

      final parts = token.split('.');
      if (parts.length != 3) {
        print('❌ Invalid token format');
        return;
      }

      // Decodificar header
      final header = _decodeJwtPart(parts[0]);
      print('🔍 Header: $header');

      // Decodificar payload
      final payload = _decodeJwtPart(parts[1]);
      print('🔍 Payload: $payload');

      // Extraer user ID
      final userId = await getUserId();
      print('🔍 Extracted User ID: $userId');

    } catch (e) {
      print('❌ Error debugging token: $e');
    }
  }

  /// Helper para decodificar partes JWT
  static Map<String, dynamic> _decodeJwtPart(String part) {
    try {
      // Agregar padding si es necesario
      String padded = part;
      final paddingNeeded = (4 - (part.length % 4)) % 4;
      if (paddingNeeded > 0) {
        padded = part + '=' * paddingNeeded;
      }

      final decodedBytes = base64Url.decode(padded);
      final decodedString = utf8.decode(decodedBytes);
      return json.decode(decodedString);
    } catch (e) {
      print('❌ Error decoding JWT part: $e');
      return {};
    }
  }
}