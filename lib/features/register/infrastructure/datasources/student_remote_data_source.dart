import 'package:dio/dio.dart';
import 'package:skillshare/core/constants/api_constants.dart';

// Interfaz
abstract class StudentRemoteDataSource {
  Future<Map<String, dynamic>> createStudent(Map<String, dynamic> studentData);
  Future<Map<String, dynamic>> getStudentByUserId(int userId);
  Future<Map<String, dynamic>> updateStudent(int id, Map<String, dynamic> studentData);
}

// Implementación
class StudentRemoteDataSourceImpl implements StudentRemoteDataSource {
  final Dio dio;

  StudentRemoteDataSourceImpl({required this.dio});

  @override
  Future<Map<String, dynamic>> createStudent(Map<String, dynamic> studentData) async {
    try {
      print('🎓 Creating student profile...');
      print('📊 Student data: $studentData');

      final response = await dio.post(
        ApiConstants.studentBase,
        data: studentData,
        options: Options(
          contentType: Headers.jsonContentType,
          validateStatus: (status) => status! < 500,
        ),
      );

      print('✅ Student creation response: ${response.statusCode}');
      print('📦 Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        final errorMsg = response.data['message'] ?? 'Failed to create student';
        throw Exception(errorMsg);
      }
    } on DioException catch (e) {
      print('💥 DioException creating student: ${e.message}');
      if (e.response != null) {
        print('💥 Response status: ${e.response?.statusCode}');
        print('💥 Response data: ${e.response?.data}');
        throw Exception(e.response?.data['message'] ?? 'Network error');
      }
      throw Exception('Network connection failed');
    } catch (e) {
      print('💀 Unexpected error creating student: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  @override
  Future<Map<String, dynamic>> getStudentByUserId(int userId) async {
    try {
      final response = await dio.get(
        ApiConstants.studentByUserId(userId),
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        throw Exception('Student not found');
      } else {
        throw Exception('Failed to get student');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Student not found');
      }
      throw Exception('Network error');
    }
  }

  @override
  Future<Map<String, dynamic>> updateStudent(int id, Map<String, dynamic> studentData) async {
    try {
      final response = await dio.put(
        ApiConstants.studentById(id),
        data: studentData,
        options: Options(
          contentType: Headers.jsonContentType,
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to update student');
      }
    } on DioException catch (e) {
      throw Exception('Network error');
    }
  }
}