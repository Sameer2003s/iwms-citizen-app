import 'dart:async';
import 'package:dio/dio.dart';
import '../models/vehicle_model.dart';

class VehicleRepository {
  final Dio dioClient;
  // NOTE: You would use dioClient to hit your real API here.

  VehicleRepository({required this.dioClient});

  Future<List<VehicleModel>> fetchAllVehicleLocations() async {
    // --- MOCK API DATA SIMULATION ---
    // In a real app: final response = await dioClient.get('YOUR_API_LINK');
    await Future.delayed(const Duration(milliseconds: 1000));

    const mockData = [
      {
        "id": "V001",
        "registration_number": "TN 01 BC 1001",
        "driver_name": "Rajesh Sharma",
        "latitude": 13.0827, // Chennai, TN
        "longitude": 80.2707,
        "status": "Collecting",
        "waste_capacity_kg": 55.5,
        "last_updated": "5 min ago"
      },
      {
        "id": "V002",
        "registration_number": "KA 03 AD 2002",
        "driver_name": "Priya Singh",
        "latitude": 18.5204, // Pune, MH
        "longitude": 73.8567,
        "status": "Idle",
        "waste_capacity_kg": 10.2,
        "last_updated": "1 hour ago"
      },
      {
        "id": "V003",
        "registration_number": "DL 9C XY 3003",
        "driver_name": "Amit Patel",
        "latitude": 28.7041, // New Delhi
        "longitude": 77.1025,
        "status": "Maintenance",
        "waste_capacity_kg": 0.0,
        "last_updated": "3 days ago"
      }
    ];
    
    return mockData.map((json) => VehicleModel.fromJson(json)).toList();
  }
}
