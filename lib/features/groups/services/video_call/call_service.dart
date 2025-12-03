import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../../core/constants/api_constants.dart';

/// Service for handling video call operations including room management,
/// participant coordination, and call statistics.
class CallService {
  static const String _baseUrl = ApiConstants.baseUrl;

  /// Creates a new call room or joins an existing one for the specified group.
  /// Returns the call ID if successful, null otherwise.
  static Future<String?> createOrJoinCall(int groupId, String token) async {
    try {
      // Check for active call first
      final activeCallData = await _getActiveCall(groupId, token);

      if (activeCallData['success'] == true && activeCallData['callId'] != null) {
        // Join existing call
        final joinResult = await _joinCall(groupId, token);
        if (joinResult['success'] == true) {
          return activeCallData['callId'];
        }
      }

      // Create new call room
      final roomData = await _createCallRoom(groupId, token);
      if (roomData['success'] == true) {
        return roomData['callId'];
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Fetches call history for a specific study group.
  static Future<List<dynamic>> getCallHistory(int groupId, String token) async {
    final response = await http.get(
      Uri.parse(ApiConstants.callHistory(groupId)),
      headers: ApiConstants.headersWithToken(token),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to get call history: ${response.statusCode}');
  }

  /// Creates a new call room for the specified group.
  static Future<Map<String, dynamic>> _createCallRoom(int groupId, String token) async {
    final response = await http.post(
      Uri.parse(ApiConstants.createCallRoom),
      headers: ApiConstants.headersWithToken(token),
      body: json.encode({'groupId': groupId}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to create call room: ${response.statusCode}');
  }

  /// Joins an existing call for the specified group.
  static Future<Map<String, dynamic>> _joinCall(int groupId, String token) async {
    final response = await http.post(
      Uri.parse(ApiConstants.joinCallEndpoint),
      headers: ApiConstants.headersWithToken(token),
      body: json.encode({'groupId': groupId}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to join call: ${response.statusCode}');
  }

  /// Retrieves call token for WebRTC connection.
  static Future<Map<String, dynamic>> getCallToken(int groupId, String token) async {
    final response = await http.post(
      Uri.parse(ApiConstants.getCallTokenEndpoint),
      headers: ApiConstants.headersWithToken(token),
      body: json.encode({'groupId': groupId}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to get call token: ${response.statusCode}');
  }

  /// Ends an active call for the specified group.
  static Future<void> endCall(int groupId, String token) async {
    final response = await http.post(
      Uri.parse(ApiConstants.endCallEndpoint),
      headers: ApiConstants.headersWithToken(token),
      body: json.encode({'groupId': groupId}),
    );

    if (response.statusCode != 200 && response.statusCode != 404) {
      throw Exception('Failed to end call: ${response.statusCode}');
    }
  }

  /// Retrieves call statistics for a specific group.
  static Future<Map<String, dynamic>> getCallStats(int groupId, String token) async {
    final response = await http.get(
      Uri.parse(ApiConstants.callStats(groupId)),
      headers: ApiConstants.headersWithToken(token),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to get call stats: ${response.statusCode}');
  }

  /// Retrieves user-specific call statistics.
  static Future<Map<String, dynamic>> getUserCallStats(String token) async {
    final response = await http.get(
      Uri.parse(ApiConstants.userCallStats),
      headers: ApiConstants.headersWithToken(token),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to get user call stats: ${response.statusCode}');
  }

  /// Checks for active call in the specified group.
  static Future<Map<String, dynamic>> _getActiveCall(int groupId, String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.activeCall(groupId)),
        headers: ApiConstants.headersWithToken(token),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'No active call'};
      }
      throw Exception('Failed to get active call: ${response.statusCode}');
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}