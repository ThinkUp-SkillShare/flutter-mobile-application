import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case responsible for handling user registration.
///
/// Delegates the creation of a new user to the provided [AuthRepository].
class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  /// Executes the registration process for the given [user].
  ///
  /// Returns the created [UserEntity] after successful registration.
  Future<UserEntity> execute(UserEntity user) {
    return repository.register(user);
  }
}