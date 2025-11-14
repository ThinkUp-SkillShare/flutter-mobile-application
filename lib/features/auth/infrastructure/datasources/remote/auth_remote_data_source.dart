import '../../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<(UserModel, String)> login(String email, String password);
  Future<UserModel> register(UserModel user);
}