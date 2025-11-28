import 'package:dio/dio.dart';
import '../../../../../core/constants/api_constants.dart';
import '../../models/user_model.dart';
import 'auth_remote_data_source.dart';

/// Implementation of [AuthRemoteDataSource] using Dio for HTTP requests.
///
/// Handles user login and registration with the remote API.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  /// Performs login with the provided [email] and [password].
  ///
  /// Returns a tuple containing:
  /// - the authenticated [UserModel]
  /// - the JWT token string
  ///
  /// Throws an [Exception] if login fails or the server returns an error.
  @override
  Future<(UserModel, String)> login(String email, String password) async {
    try {
      final response = await dio.post(
        ApiConstants.loginEndpoint,
        data: {'email': email, 'password': password},
        options: Options(
          contentType: Headers.jsonContentType,
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true) {
          final String token = responseData['token'];
          final userData = responseData['user'];

          final userModel = UserModel(
            userId: userData['userId'],
            email: userData['email'],
            password: '', // Password is not stored
            profileImage: userData['profileImage'],
            createdAt: userData['createdAt'],
          );

          return (userModel, token);
        } else {
          final errorMsg = responseData['message'] ?? 'Login failed';
          throw Exception(errorMsg);
        }
      } else {
        final errorMsg = response.data['message'] ?? 'Login failed';
        throw Exception(errorMsg);
      }
    } on DioException catch (e) {
      // Handle network or server errors
      final errorMessage = e.response?.data['message'] ?? e.message;
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('An unexpected error occurred during login');
    }
  }

  /// Registers a new user with the remote API.
  ///
  /// Returns the created [UserModel] after successful registration.
  /// Throws an [Exception] if registration fails.
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
          password: '', // Do not store password
          profileImage: user.profileImage,
          createdAt: DateTime.now().toIso8601String(),
        );
      } else if (response.statusCode == 409) {
        throw Exception('Email already exists');
      } else {
        throw Exception(response.data['message'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Network error';
      throw Exception(errorMessage);
    } catch (_) {
      throw Exception('An unexpected error occurred during registration');
    }
  }
}