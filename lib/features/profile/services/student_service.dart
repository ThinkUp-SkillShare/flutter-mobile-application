import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../auth/application/auth_service.dart';
import '../domain/entities/student_entity.dart';

/// Service responsible for handling student-related API operations.
/// Follows the repository pattern within the DDD architecture.
class StudentService {

  /// Fetches a student by their user ID from the API.
  Future<Student?> getStudentByUserId(int userId) async {
    try {
      final String? token = await AuthService.getAuthToken();

      final response = await http.get(
        Uri.parse(ApiConstants.studentByUserId(userId)),
        headers: _buildHeaders(token),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Student.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        return null;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Failed to load student data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching student: $e');
    }
  }

  /// Updates a student's information in the API.
  Future<Student> updateStudent(int id, Map<String, dynamic> updateData) async {
    try {
      final String? token = await AuthService.getAuthToken();

      final response = await http.put(
        Uri.parse(ApiConstants.studentById(id)),
        headers: _buildHeaders(token),
        body: json.encode(updateData),
      );

      if (response.statusCode == 200) {
        final updatedStudentData = json.decode(response.body);
        return Student.fromJson(updatedStudentData);
      } else {
        throw Exception('Failed to update student: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating student: $e');
    }
  }

  /// Builds HTTP headers with authentication token.
  Map<String, String> _buildHeaders(String? token) {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }
}