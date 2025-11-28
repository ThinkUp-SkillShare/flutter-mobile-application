import '../entities/user_entity.dart';

/// Defines the contract for authentication-related operations.
/// Implementations of this repository must provide:
/// - user login
/// - user registration
/// - logout handling
/// - authentication status validation
abstract class AuthRepository {
  /// Attempts to authenticate a user with the given email and password.
  ///
  /// Returns a tuple containing:
  /// - the authenticated [UserEntity]
  /// - a JWT token string
  Future<(UserEntity, String)> login(String email, String password);

  /// Registers a new user and returns the created [UserEntity].
  Future<UserEntity> register(UserEntity user);

  /// Clears authentication data and logs out the current user.
  Future<void> logout();

  /// Returns `true` if the user is currently authenticated.
  Future<bool> isAuthenticated();
}
