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

// Base URL (without query params)
const String kVehicleApiBaseUrl =
    "https://api.vamosys.com/mobile/getGrpDataForTrustedClients";

// API Parameters (ZIGMA specific credentials - THESE MUST BE PROTECTED!)
const String kProviderName = "ZIGMA";
const String kFCode = "VAM";

