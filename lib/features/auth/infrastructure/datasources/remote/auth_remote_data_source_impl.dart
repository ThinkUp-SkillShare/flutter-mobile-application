import 'package:dio/dio.dart';
import '../../../../../../core/constants/api_constants.dart';
import '../../../domain/exceptions/auth_exceptions.dart';
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
          throw LoginException(errorMsg);
        }
      } else if (response.statusCode == 401) {
        throw InvalidCredentialsException('Invalid email or password');
      } else if (response.statusCode == 404) {
        throw UserNotFoundException('Email not registered');
      } else {
        throw LoginException(response.data['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection. Please check your network.');
      } else {
        final errorMessage = e.response?.data['message'] ?? 'Network error occurred';
        throw LoginException(errorMessage);
      }
    } catch (e) {
      if (e is LoginException || e is InvalidCredentialsException ||
          e is UserNotFoundException || e is NetworkException) {
        rethrow;
      }
      throw LoginException('An unexpected error occurred during login');
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
          password: '',
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