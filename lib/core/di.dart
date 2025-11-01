import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iwms_citizen_app/data/repositories/auth_repository.dart';
import 'package:iwms_citizen_app/logic/auth/auth_bloc.dart';
import 'package:iwms_citizen_app/modules/module2_driver/services/image_compress_service.dart';
import 'package:iwms_citizen_app/data/repositories/driver_repository.dart';
import 'package:iwms_citizen_app/logic/driver/driver_bloc.dart';

// --- Vehicle Tracking Imports ---
import 'package:iwms_citizen_app/data/repositories/vehicle_repository.dart';
import 'package:iwms_citizen_app/logic/vehicle_tracking/vehicle_bloc.dart';
// --- End Vehicle Tracking Imports ---

import 'api_config.dart';

final getIt = GetIt.instance;

Future<void> setupDI() async {
  // --- External ---
  getIt.registerSingleton<Dio>(createDioClient());

  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // --- Services ---
  getIt.registerLazySingleton(() => ImageCompressService());

  // --- Repositories ---
  getIt.registerLazySingleton(() => AuthRepository(
        prefs: getIt<SharedPreferences>(),
        dio: getIt<Dio>(),
      ));

  getIt.registerLazySingleton(() => DriverRepository(
        dio: getIt<Dio>(),
        compressService: getIt<ImageCompressService>(),
      ));

  // --- Register your VehicleRepository ---
  getIt.registerLazySingleton(() => VehicleRepository(
        dioClient: getIt<Dio>(),
      ));

  // --- BLoCs ---
  getIt.registerFactory(() => AuthBloc(
        authRepository: getIt<AuthRepository>(),
      ));

  getIt.registerFactory(() => DriverBloc(
        driverRepository: getIt<DriverRepository>(),
      ));

  // --- Register your VehicleBloc ---
  getIt.registerFactory(() => VehicleBloc(
        getIt<VehicleRepository>(),
      ));
}

