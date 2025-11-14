import '../../application/auth_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<(UserEntity, String)> login(String email, String password) async {
    try {
      final (userModel, token) = await remoteDataSource.login(email, password);
      return (userModel.toEntity(), token);
    } catch (e) {
      rethrow;
    }
  }

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

  @override
  Future<void> logout() async {
    try {
    } catch (e) {
      print('Warning: Could not call backend logout: $e');
    } finally {
      await AuthService.clearUserData();
    }
  }


  @override
  Future<bool> isAuthenticated() async {
    return await AuthService.isAuthenticated();
  }
}