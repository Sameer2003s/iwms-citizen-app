import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iwms_citizen_app/data/repositories/auth_repository.dart';
import 'package:iwms_citizen_app/logic/auth/auth_bloc.dart';
import 'api_config.dart'; // <-- THIS IS THE FIX

final getIt = GetIt.instance;

void setupDI() {
  // --- External ---
  
  // Register Dio as a Singleton
  getIt.registerSingleton<Dio>(createDioClient()); // <-- This will now be found

  // Register SharedPreferences as a Future
  getIt.registerSingletonAsync<SharedPreferences>(
      () => SharedPreferences.getInstance());

  // --- Repositories ---
  
  // AuthRepository (depends on Dio and SharedPreferences)
  getIt.registerSingletonWithDependencies<AuthRepository>(
    () => AuthRepository(
      prefs: getIt<SharedPreferences>(),
      dio: getIt<Dio>(),
    ),
    dependsOn: [SharedPreferences],
  );

  // --- BLoCs ---
  
  // AuthBloc (depends on AuthRepository)
  getIt.registerSingletonWithDependencies<AuthBloc>(
    () => AuthBloc(
      authRepository: getIt<AuthRepository>(),
    ),
    dependsOn: [AuthRepository],
  );
}

