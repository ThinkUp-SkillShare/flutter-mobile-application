import '../../application/auth_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_data_source.dart';
import '../models/user_model.dart';

/// Implementation of [AuthRepository] using a remote data source.
///
/// Handles user login, registration, logout, and authentication status.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  /// Logs in a user with the provided [email] and [password].
  ///
  /// Returns a tuple containing:
  /// - the authenticated [UserEntity]
  /// - the JWT token string
  @override
  Future<(UserEntity, String)> login(String email, String password) async {
    try {
      final (userModel, token) = await remoteDataSource.login(email, password);
      return (userModel.toEntity(), token);
    } catch (e) {
      // Rethrow to allow higher layers to handle the exception
      rethrow;
    }
  }

  /// Registers a new [user].
  ///
  /// Returns the created [UserEntity] after successful registration.
  @override
  Future<UserEntity> register(UserEntity user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      final registeredUser = await remoteDataSource.register(userModel);
      return registeredUser.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  /// Logs out the current user.
  ///
  /// Clears local authentication data via [AuthService].
  @override
  Future<void> logout() async {
    try {
      // Optional: call a backend logout endpoint if needed
    } catch (e) {
      // Ignore backend logout errors, local cleanup still occurs
    } finally {
      await AuthService.clearUserData();
    }
  }

  /// Returns `true` if the user is currently authenticated.
  @override
  Future<bool> isAuthenticated() async {
    return await AuthService.isAuthenticated();
  }
}