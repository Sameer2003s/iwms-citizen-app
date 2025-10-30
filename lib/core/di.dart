import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Layered imports
import '../data/repositories/auth_repository.dart';
import '../data/repositories/vehicle_repository.dart'; // <<< IMPORTS VEHICLE REPO
import '../logic/auth/auth_bloc.dart';
import '../logic/vehicle_tracking/vehicle_cubit.dart'; // <<< IMPORTS VEHICLE CUBIT

final getIt = GetIt.instance;

void setupDI() {
  // 1. SERVICES / CLIENTS 
  
  // Register Future<SharedPreferences> that the Repository will await internally.
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
  
  // Register the VehicleRepository (using Dio for API calls)
  getIt.registerLazySingleton<VehicleRepository>(
    () => VehicleRepository(
      dioClient: getIt<Dio>(),
    ),
  );

  // 3. BLOCS / CUBITS 
  
  // Register the AuthBloc (Factory, as it holds state)
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      authRepository: getIt<AuthRepository>(),
    ),
  );

  // Register the VehicleCubit (Factory, as it holds map state)
  getIt.registerFactory<VehicleCubit>(
    () => VehicleCubit(
      getIt<VehicleRepository>(), 
    ),
  );
}