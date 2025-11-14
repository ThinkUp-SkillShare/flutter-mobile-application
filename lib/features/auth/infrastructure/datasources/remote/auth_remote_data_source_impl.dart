import 'package:dio/dio.dart';
import '../../../../../core/constants/api_constants.dart';
import '../../models/user_model.dart';
import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<(UserModel, String)> login(String email, String password) async {
    try {
      print('🚀 Attempting login to: ${ApiConstants.loginEndpoint}');
      print('📧 Email: $email');

      final response = await dio.post(
        ApiConstants.loginEndpoint,
        data: {
          'email': email,
          'password': password,
        },
        options: Options(
          contentType: Headers.jsonContentType,
          validateStatus: (status) => status! < 500,
        ),
      );

      print('✅ Response status: ${response.statusCode}');
      print('📨 Full response data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true) {
          final String token = responseData['token'];
          final userData = responseData['user'];

          final userModel = UserModel(
            userId: userData['userId'],
            email: userData['email'],
            password: '',
            profileImage: userData['profileImage'],
            createdAt: userData['createdAt'],
          );

          return (userModel, token);
        } else {
          final errorMsg = responseData['message'] ?? 'Login failed';
          print('❌ Login failed with message: $errorMsg');
          throw Exception(errorMsg);
        }
      } else {
        final errorMsg = response.data['message'] ?? 'Login failed';
        print('❌ Server error: ${response.statusCode} - $errorMsg');
        throw Exception(errorMsg);
      }
    } on DioException catch (e) {
      print('💥 DioException Type: ${e.type}');
      print('💥 DioException Message: ${e.message}');

      if (e.response != null) {
        print('💥 Response status: ${e.response?.statusCode}');
        print('💥 Response data: ${e.response?.data}');
      }

      rethrow;
    } catch (e) {
      print('💀 Unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<UserModel> register(UserModel user) async {
    try {
      final response = await dio.post(
        ApiConstants.registerEndpoint,
        data: {
          'email': user.email,
          'password': user.password,
          'profileImage': user.profileImage,
        },
        options: Options(
          contentType: Headers.jsonContentType,
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        return UserModel(
          userId: responseData['userId'] ?? user.userId,
          email: user.email,
          password: '', // Don't store password
          profileImage: user.profileImage,
          createdAt: DateTime.now().toIso8601String(),
        );
      } else if (response.statusCode == 409) {
        throw Exception('Email already exists');
      } else {
        throw Exception(response.data['message'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data['message'] ?? 'Network error';
        throw Exception(errorMessage);
      } else {
        throw Exception('Network connection failed');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  Future<bool> testConnection() async {
    try {
      print('🔗 Testing connection to: ${ApiConstants.testConnectionEndpoint}');
      final response = await dio.get(
        ApiConstants.testConnectionEndpoint,
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );

      print('✅ Connection test response: ${response.statusCode}');
      print('✅ Connection test data: ${response.data}');

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Connection test failed: $e');
      return false;
    }
  }
}