import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Layered imports
import '../data/repositories/auth_repository.dart';
import '../data/repositories/vehicle_repository.dart'; // <<< ADDED VEHICLE REPO IMPORT
import '../logic/auth/auth_bloc.dart';
import '../logic/vehicle_tracking/vehicle_cubit.dart'; // <<< ADDED VEHICLE CUBIT IMPORT

final getIt = GetIt.instance;

void setupDI() {
  // 1. SERVICES / CLIENTS 
  
  // Register Future<SharedPreferences> for the Repository to resolve internally.
  getIt.registerLazySingleton<Future<SharedPreferences>>(
    () => SharedPreferences.getInstance(),
  );

  // Register Dio instance
  getIt.registerLazySingleton<Dio>(() => Dio());
  
  // 2. REPOSITORIES 
  
  // Register the AuthRepository.
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      dioClient: getIt<Dio>(),
      sharedPreferencesFuture: getIt<Future<SharedPreferences>>(), 
    ),
  );
  
  // <<< CRITICAL FIX: REGISTERING VEHICLE REPOSITORY >>>
  getIt.registerLazySingleton<VehicleRepository>(
    () => VehicleRepository(
      dioClient: getIt<Dio>(),
    ),
  );

  // 3. BLOCS / CUBITS 
  
  // Register the AuthBloc
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      authRepository: getIt<AuthRepository>(),
    ),
  );

  // <<< CRITICAL FIX: REGISTERING VEHICLE CUBIT >>>
  getIt.registerFactory<VehicleCubit>(
    () => VehicleCubit(
      getIt<VehicleRepository>(), // Pass the newly registered repository
    ),
  );
}
