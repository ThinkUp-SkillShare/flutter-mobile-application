import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';

class CallService {
  static final String _baseUrl = ApiConstants.baseUrl;

  static Future<String?> createOrJoinCall(int groupId, String token) async {
    try {
      print('🔄 Creating or joining call for group: $groupId');

      final activeCall = await getActiveCall(groupId, token);
      print('📡 Active call check result: ${activeCall['success']} - ${activeCall['callId']}');

      if (activeCall['success'] == true && activeCall['callId'] != null) {
        print('✅ Found active call: ${activeCall['callId']}');

        final joinResult = await joinCall(groupId, token);
        print('📡 Join call result: ${joinResult['success']}');

        if (joinResult['success'] == true) {
          return activeCall['callId'];
        } else {
          print('⚠️ Failed to join existing call, creating new one...');
        }
      }

      print('🆕 No active call found, creating new one...');
      final roomData = await createCallRoom(groupId, token);

      if (roomData['success'] == true) {
        return roomData['callId'];
      } else {
        throw Exception('Failed to create call room: ${roomData['message']}');
      }
    } catch (e) {
      print('❌ Error in createOrJoinCall: $e');
      return null;
    }
  }

  static Future<List<dynamic>> getCallHistory(int groupId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/Calls/call-history/$groupId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get call history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting call history: $e');
    }
  }

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

  static Future<Map<String, dynamic>> joinCall(int groupId, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/Calls/join-call'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'groupId': groupId,
        }),
      );

      print('📡 Join call response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to join call: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error joining call: $e');
      throw Exception('Error joining call: $e');
    }
  }

  static Future<Map<String, dynamic>> getCallToken(int groupId, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/Calls/get-token'),
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
        Uri.parse('$_baseUrl/Calls/end-call'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'groupId': groupId,
        }),
      );

      print('📡 End call response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Call ended successfully');
      } else if (response.statusCode == 404) {
        print('⚠️ No active call found to end');
      } else {
        throw Exception('Failed to end call: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error ending call: $e');
    }
  }

  static Future<Map<String, dynamic>> getCallStats(int groupId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/Calls/call-stats/$groupId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get call stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting call stats: $e');
    }
  }

  static Future<Map<String, dynamic>> getUserCallStats(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/Calls/user-stats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get user call stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting user call stats: $e');
    }
  }

  static Future<Map<String, dynamic>> getActiveCall(int groupId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/Calls/active-call/$groupId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Active call response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        // No active call found
        return {'success': false, 'message': 'No active call'};
      } else {
        throw Exception('Failed to get active call: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting active call: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}