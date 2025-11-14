import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<(UserEntity, String)> login(String email, String password);
  Future<UserEntity> register(UserEntity user);
  Future<void> logout();
  Future<bool> isAuthenticated();
}