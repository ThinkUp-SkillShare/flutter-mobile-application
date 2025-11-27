import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/constants/api_constants.dart';

class GroupManagementService {

  static Future<Map<String, dynamic>?> getUserPermissions(int groupId, String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.groupPermissions(groupId)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        print('Error getting permissions: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting permissions: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getGroupStatistics(int groupId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.studyGroupBase}/$groupId/statistics'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting statistics: $e');
      return null;
    }
  }

  static Future<bool> promoteToAdmin(int groupId, int memberId, String token) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.studyGroupBase}/$groupId/members/$memberId/promote'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error promoting member: $e');
      return false;
    }
  }

  static Future<bool> demoteToMember(int groupId, int memberId, String token) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.studyGroupBase}/$groupId/members/$memberId/demote'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error demoting member: $e');
      return false;
    }
  }

  static Future<bool> removeMember(int groupId, int memberId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.studyGroupBase}/$groupId/members/$memberId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error removing member: $e');
      return false;
    }
  }

  static Future<List<int>> bulkRemoveMembers(int groupId, List<int> userIds, String token) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.studyGroupBase}/$groupId/members/bulk-remove'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'userIds': userIds}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<int>.from(data['removedUserIds'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error bulk removing members: $e');
      return [];
    }
  }

  static Future<bool> transferOwnership(int groupId, int newOwnerId, String token) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.studyGroupBase}/$groupId/transfer-ownership'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'newOwnerId': newOwnerId}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error transferring ownership: $e');
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
        Uri.parse('${ApiConstants.studyGroupBase}/$groupId'),
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
        Uri.parse('${ApiConstants.studyGroupBase}/$groupId'),
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
}