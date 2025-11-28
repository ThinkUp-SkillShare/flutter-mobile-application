import '../../models/user_model.dart';

/// Defines the contract for remote authentication data operations.
///
/// Implementations are responsible for interacting with external
/// services (e.g., REST APIs) for login and registration.
abstract class AuthRemoteDataSource {
  /// Authenticates a user with the given [email] and [password].
  ///
  /// Returns a tuple containing:
  /// - the authenticated [UserModel]
  /// - a JWT token string
  Future<(UserModel, String)> login(String email, String password);

  /// Registers a new user via the remote service.
  ///
  /// Returns the created [UserModel].
  Future<UserModel> register(UserModel user);
}
