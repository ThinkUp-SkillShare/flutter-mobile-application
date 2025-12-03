import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case responsible for handling the login flow.
///
/// Delegates authentication to the provided [AuthRepository].
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  /// Executes the login process using the given credentials.
  ///
  /// Returns a tuple containing:
  /// - the authenticated [UserEntity]
  /// - the JWT token associated with the session
  Future<(UserEntity, String)> execute(String email, String password) {
    return repository.login(email, password);
  }
}