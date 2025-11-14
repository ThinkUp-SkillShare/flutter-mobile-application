import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:skill_share/features/auth/domain/repositories/auth_repository.dart';
import 'package:skill_share/features/auth/domain/use_cases/login_use_case.dart';
import 'package:skill_share/features/auth/domain/use_cases/register_use_case.dart';

import '../features/auth/infrastructure/datasources/remote/auth_remote_data_source.dart';
import '../features/auth/infrastructure/datasources/remote/auth_remote_data_source_impl.dart';
import '../features/auth/infrastructure/repositories/auth_repository_impl.dart';
import 'constants/api_constants.dart';

final GetIt getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton<Dio>(() => Dio()
    ..options.baseUrl = ApiConstants.baseUrl
    ..options.connectTimeout = const Duration(seconds: 30)
    ..options.receiveTimeout = const Duration(seconds: 30)
    ..interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    )));

  getIt.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(remoteDataSource: getIt<AuthRemoteDataSource>()),
  );

  getIt.registerLazySingleton<LoginUseCase>(
        () => LoginUseCase(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<RegisterUseCase>(
        () => RegisterUseCase(getIt<AuthRepository>()),
  );
}