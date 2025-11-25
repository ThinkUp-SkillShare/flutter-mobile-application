import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../auth/application/auth_service.dart';
import '../domain/entities/student_entity.dart';

class StudentService {
  Future<Student?> getStudentByUserId(int userId) async {
    try {
      final String? token = await AuthService.getAuthToken();

      print('🔗 DEBUG - Calling student endpoint for userId: $userId');
      print('🔑 DEBUG - Token available: ${token != null}');

      final response = await http.get(
        Uri.parse(ApiConstants.studentByUserId(userId)),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print('📡 DEBUG - Student API Response Status: ${response.statusCode}');
      print('📡 DEBUG - Student API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('✅ DEBUG - Student data parsed: $jsonData');

        // Verificar si viene la información del usuario
        if (jsonData['user'] != null) {
          print('✅ DEBUG - User data included in response');
        } else {
          print('⚠️ DEBUG - User data NOT included in response');
        }

        return Student.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        print('❌ DEBUG - Student not found for userId: $userId');
        return null;
      } else if (response.statusCode == 401) {
        print('❌ DEBUG - Unauthorized, token may be invalid');
        throw Exception('Unauthorized - Please login again');
      } else {
        print('❌ DEBUG - Server error: ${response.statusCode}');
        throw Exception('Failed to load student data: ${response.statusCode}');
      }
    } catch (e) {
      print('💀 DEBUG - Error in StudentService: $e');
      throw Exception('Error fetching student: $e');
    }
  }

  Future<Student> updateStudent(int id, Map<String, dynamic> updateData) async {
    try {
      final String? token = await AuthService.getAuthToken();

      final response = await http.put(
        Uri.parse(ApiConstants.studentById(id)),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(updateData),
      );

      print('📡 DEBUG - Update student response: ${response.statusCode}');
      print('📡 DEBUG - Update student body: ${response.body}');

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
}