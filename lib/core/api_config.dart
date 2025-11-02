import 'package:dio/dio.dart';

// This function creates and configures a Dio instance
Dio createDioClient() {
  final dio = Dio(
    BaseOptions(
      // You can set a base URL here if all requests share one
      // baseUrl: 'http://zigma.in:80/d2d_app/',
      connectTimeout: const Duration(seconds: 10), // Increased timeout
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // You can add interceptors here for logging or auth tokens
  dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));

  return dio;
}

// --- ADDED THESE ---
class ApiConfig {
  // Real Driver Login
  static const String driverLogin = 'http://zigma.in/d2d_app/login.php';

  // Mock Citizen Login (URL isn't used, but good to have)
  static const String citizenLogin = 'http://zigma.in/d2d_app/citizen_login.php';
}
// --- END ADD ---

// Base URL (without query params)
const String kVehicleApiBaseUrl =
    "https://api.vamosys.com/mobile/getGrpDataForTrustedClients";

// API Parameters (ZIGMA specific credentials - THESE MUST BE PROTECTED!)
const String kProviderName = "ZIGMA";
const String kFCode = "VAM";