import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:skill_share/features/auth/domain/repositories/auth_repository.dart';
import 'package:skill_share/features/auth/domain/use_cases/login_use_case.dart';
import 'package:skill_share/features/auth/domain/use_cases/register_use_case.dart';
import 'package:skill_share/features/auth/infrastructure/datasources/remote/auth_remote_data_source.dart';
import 'package:skill_share/features/auth/infrastructure/datasources/remote/auth_remote_data_source_impl.dart';
import 'package:skill_share/features/auth/infrastructure/repositories/auth_repository_impl.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton(() => Dio()
    ..options = BaseOptions(
      baseUrl: 'http://10.0.2.2:5118/api',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    )
    ..interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    )));

  sl.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
}