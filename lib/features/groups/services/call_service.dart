import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';

class CallService {
  static final String _baseUrl = ApiConstants.baseUrl;

  static Future<Map<String, dynamic>> createCallRoom(int groupId, String token) async {
    try {
      print('🔄 Creating call room for group: $groupId');

      final response = await http.post(
        Uri.parse('$_baseUrl/Calls/create-room'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'groupId': groupId,
        }),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create call room: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error creating call room: $e');
      throw Exception('Error creating call room: $e');
    }
  }

  static Future<Map<String, dynamic>> getCallToken(int groupId, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/calls/get-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'groupId': groupId,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get call token: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting call token: $e');
    }
  }

  static Future<void> endCall(int groupId, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/calls/end-call'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'groupId': groupId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to end call: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error ending call: $e');
    }
  }
}