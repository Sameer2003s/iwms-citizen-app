import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode/print

// Layered imports (These must be present in your project)
import '../models/vehicle_model.dart';

class VehicleRepository {
  final Dio dioClient;

  // 1. Define the actual API endpoint
  static const String _liveLocationApi = 
      "https://api.vamosys.com/mobile/getGrpDataForTrustedClients?providerName=ZIGMA&fcode=VAM";

  VehicleRepository({
    required this.dioClient,
  });

  // 2. Fetch data from the live API
  Future<List<VehicleModel>> fetchAllVehicleLocations() async {
    try {
      // Perform the actual GET request using Dio
      final Response response = await dioClient.get(_liveLocationApi);

      // Check for success status code
      if (response.statusCode == 200) {
        
        final List<dynamic> dataList;
        
        // --- Robust JSON Parsing ---
        // We assume the list of vehicles is the root data or nested under a key.
        if (response.data is List) {
          // Case 1: Response is a root array
          dataList = response.data as List<dynamic>;
        } else if (response.data is Map && response.data.containsKey('data')) {
          // Case 2: Response is a map containing a 'data' key (or similar)
          dataList = response.data['data'] as List<dynamic>;
        } else if (response.data is Map) {
          // Fallback check if a key named 'vehicles' or similar exists (adjust this if needed)
          // For now, if it's a Map, we'll try to find the list of vehicles within it.
          // This requires knowing the exact API structure. For safety, we rely on the list itself.
          throw const FormatException("Unexpected API root format. Expected a List.");
        } else {
          throw const FormatException("Unexpected API response format.");
        }

        // Map the list of raw JSON objects to Dart VehicleModel objects
        return dataList.map((json) => VehicleModel.fromJson(json)).toList();

      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: "API returned status code: ${response.statusCode}",
        );
      }
    } on DioException catch (e) {
      // Re-throw a custom exception for the Cubit to catch and display
      if (kDebugMode) {
        print('Network Error fetching vehicles: ${e.message}');
      }
      throw Exception("Network Error: Could not connect to API.");
    } catch (e) {
      if (kDebugMode) {
        print('Parsing/Format Error: $e');
      }
      throw Exception("Failed to process vehicle data (Check VehicleModel parsing).");
    }
  }
}