import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../core/constants/api_constants.dart';

/// Service class to handle all operations related to study groups.
class GroupService {
  // ==============================
  // CRUD Operations for Groups
  // ==============================

  /// Create a new study group.
  static Future<Map<String, dynamic>?> createGroup({
    required String name,
    required String token,
    String? description,
    String? coverImage,
    int? subjectId,
  }) async {
    try {
      final body = <String, dynamic>{
        'name': name,
        'description': description ?? '',
      };

      if (coverImage != null && coverImage.isNotEmpty) body['coverImage'] = coverImage;
      if (subjectId != null) body['subjectId'] = subjectId;

      final response = await http.post(
        Uri.parse(ApiConstants.studyGroupBase),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
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

  /// Update an existing study group.
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

  /// Delete a study group.
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

  // ==============================
  // Group Membership Operations
  // ==============================

  /// Join a study group.
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

  /// Leave a study group.
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

  /// Get members of a specific group.
  static Future<List<Map<String, dynamic>>> getGroupMembers(
      int groupId,
      String token,
      ) async {
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

  // ==============================
  // Group Retrieval Operations
  // ==============================

  /// Get detailed information about a group.
  static Future<Map<String, dynamic>?> getGroupById(
      int groupId,
      int userId,
      String token,
      ) async {
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
      } else if (response.statusCode == 404) {
        throw Exception('Group not found');
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed');
      } else {
        throw Exception('Failed to load group: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching group by ID: $e');
      return null;
    }
  }

  /// Get all groups for a user.
  static Future<List<Map<String, dynamic>>> getUserGroups(int userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.studyGroupsByUserId(userId)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = List<Map<String, dynamic>>.from(json.decode(response.body));

        // Ensure memberCount is integer
        for (var group in data) {
          if (group['memberCount'] is String) {
            group['memberCount'] = int.tryParse(group['memberCount']) ?? 0;
          } else if (group['memberCount'] is double) {
            group['memberCount'] = (group['memberCount'] as double).toInt();
          }
        }

        return data;
      } else {
        throw Exception('Failed to load user groups: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user groups: $e');
      return [];
    }
  }

  /// Get featured groups for a user.
  static Future<List<Map<String, dynamic>>> getFeaturedGroups(int userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.studyGroupBase}/featured?userId=$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = List<Map<String, dynamic>>.from(json.decode(response.body));

        // Ensure memberCount is integer
        for (var group in data) {
          if (group['memberCount'] is String) {
            group['memberCount'] = int.tryParse(group['memberCount']) ?? 0;
          } else if (group['memberCount'] is double) {
            group['memberCount'] = (group['memberCount'] as double).toInt();
          }
        }

        return data;
      } else {
        throw Exception('Failed to load featured groups: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching featured groups: $e');
      return [];
    }
  }

  /// Get all groups.
  static Future<List<Map<String, dynamic>>> getAllGroups(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.studyGroupBase),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception('Failed to load all groups: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching all groups: $e');
      return [];
    }
  }

  // ==============================
  // Subject Retrieval Operations
  // ==============================

  /// Get popular subjects.
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

  /// Get all subjects.
  static Future<List<Map<String, dynamic>>> getAllSubjects(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.subjectBase),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception('Failed to load subjects: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching subjects: $e');
      return [];
    }
  }
}
