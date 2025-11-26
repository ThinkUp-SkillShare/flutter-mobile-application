import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../core/constants/api_constants.dart';

class GroupService {

  static Future<Map<String, dynamic>> getGroupById(int groupId, int userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.studyGroupById(groupId, userId: userId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load group details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getGroupById: $e');
      throw Exception('Error loading group details: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getUserGroups(int userId, String token) async {
    try {
      print('🔐 Getting user groups for userId: $userId');

      final response = await http.get(
        Uri.parse(ApiConstants.studyGroupsByUserId(userId)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📡 User groups response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = List<Map<String, dynamic>>.from(json.decode(response.body));
        print('✅ Loaded ${data.length} user groups');

        if (data.isNotEmpty) {
          print('🔍 DEBUG - First group structure:');
          print('   Keys: ${data[0].keys}');
          print('   coverImage: ${data[0]['coverImage']}');
          print('   cover_image: ${data[0]['cover_image']}');
        }

        return data;
      } else {
        print('❌ Failed to load user groups: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load user groups: ${response.statusCode}');
      }
    } catch (e) {
      print('🚨 Error fetching user groups: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getFeaturedGroups(int userId, String token) async {
    try {
      print('🔐 Getting featured groups for userId: $userId');

      final response = await http.get(
        Uri.parse('${ApiConstants.studyGroupBase}/featured?userId=$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📡 Featured groups response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = List<Map<String, dynamic>>.from(json.decode(response.body));
        print('✅ Loaded ${data.length} featured groups');

        // Asegurar que memberCount sea int
        for (var group in data) {
          if (group['memberCount'] is String) {
            group['memberCount'] = int.tryParse(group['memberCount']) ?? 0;
          }
          // Si viene como double, convertirlo a int
          if (group['memberCount'] is double) {
            group['memberCount'] = (group['memberCount'] as double).toInt();
          }
        }

        // DEBUG: Mostrar los grupos ordenados
        print('🎯 Featured groups (sorted by member count):');
        for (var i = 0; i < data.length; i++) {
          final group = data[i];
          print('   ${i + 1}. "${group['name']}" - ${group['memberCount']} members');
        }

        return data;
      } else {
        print('❌ Failed to load featured groups: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load featured groups: ${response.statusCode}');
      }
    } catch (e) {
      print('🚨 Error fetching featured groups: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getAllGroups(String token) async {
    try {
      print('🔐 Getting ALL groups...');

      final response = await http.get(
        Uri.parse(ApiConstants.studyGroupBase),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📡 All groups response: ${response.statusCode}');
      print('📡 All groups response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = List<Map<String, dynamic>>.from(json.decode(response.body));
        print('✅ Loaded ${data.length} TOTAL groups');

        for (var i = 0; i < data.length && i < 5; i++) {
          final group = data[i];
          print('   ${i + 1}. "${group['name']}"');
          print('      - subjectId: ${group['subjectId']}');
          print('      - subjectName: ${group['subjectName']}');
          print('      - memberCount: ${group['memberCount']}');
        }

        return data;
      } else {
        print('❌ Failed to load all groups: ${response.statusCode}');
        print('Response headers: ${response.headers}');
        throw Exception('Failed to load all groups: ${response.statusCode}');
      }
    } catch (e) {
      print('🚨 Error fetching all groups: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getPopularSubjects(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.subjectBase}/popular'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    }
    throw Exception('Failed to load popular subjects');
  }

  static Future<List<Map<String, dynamic>>> getAllSubjects(String token) async {
    try {
      print('🔐 Getting all subjects...');

      final response = await http.get(
        Uri.parse(ApiConstants.subjectBase),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📡 Subjects response: ${response.statusCode}');
      print('📡 Subjects response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = List<Map<String, dynamic>>.from(json.decode(response.body));
        print('✅ Loaded ${data.length} subjects');

        print('🔍 DEBUG: All subjects:');
        for (var subject in data) {
          print('   - ${subject['id']}: ${subject['name']}');
        }

        return data;
      } else {
        print('❌ Failed to load subjects: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load subjects: ${response.statusCode}');
      }
    } catch (e) {
      print('🚨 Error fetching subjects: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getGroupDetails(int groupId, int userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.studyGroupById(groupId, userId: userId)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load group details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching group details: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> createGroup({
    required String name,
    required String token,
    String? description,
    String? coverImage,
    int? subjectId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.studyGroupBase),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': name,
          'description': description,
          'coverImage': coverImage,
          'subjectId': subjectId,
        }),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create group: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating group: $e');
      return null;
    }
  }

  static Future<bool> joinGroup(int groupId, String token) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.joinGroup(groupId)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error joining group: $e');
      return false;
    }
  }

  static Future<bool> leaveGroup(int groupId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiConstants.leaveGroup(groupId)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error leaving group: $e');
      return false;
    }
  }

  static Future<bool> updateGroup({
    required int groupId,
    required String token,
    String? name,
    String? description,
    String? coverImage,
    int? subjectId,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (description != null) body['description'] = description;
      if (coverImage != null) body['coverImage'] = coverImage;
      if (subjectId != null) body['subjectId'] = subjectId;

      final response = await http.put(
        Uri.parse(ApiConstants.studyGroupById(groupId)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Error updating group: $e');
      return false;
    }
  }

  static Future<bool> deleteGroup(int groupId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiConstants.studyGroupById(groupId)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Error deleting group: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getGroupMembers(int groupId, String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.groupMembers(groupId)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception('Failed to load group members: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching group members: $e');
      return [];
    }
  }
}