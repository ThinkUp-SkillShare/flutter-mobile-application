import 'package:dio/dio.dart';
import 'package:skillshare/core/constants/api_constants.dart';

/// Interface for student remote data operations
abstract class StudentRemoteDataSource {
  Future<Map<String, dynamic>> createStudent(Map<String, dynamic> studentData);
  Future<Map<String, dynamic>> getStudentByUserId(int userId);
  Future<Map<String, dynamic>> updateStudent(int id, Map<String, dynamic> studentData);
}

/// Implementation of StudentRemoteDataSource using Dio for HTTP requests
class StudentRemoteDataSourceImpl implements StudentRemoteDataSource {
  final Dio dio;

  StudentRemoteDataSourceImpl({required this.dio});

  /// Creates a new student profile
  @override
  Future<Map<String, dynamic>> createStudent(Map<String, dynamic> studentData) async {
    try {
      final response = await dio.post(
        ApiConstants.studentBase,
        data: studentData,
        options: Options(
          contentType: Headers.jsonContentType,
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        final errorMsg = response.data['message'] ?? 'Failed to create student';
        throw Exception(errorMsg);
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Network error');
      }
      throw Exception('Network connection failed');
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  /// Retrieves a student profile by user ID
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

  /// Updates an existing student profile
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