import 'package:equatable/equatable.dart';

class VehicleModel extends Equatable {
  final String id;
  final String registrationNumber;
  final String driverName;
  final double latitude;
  final double longitude;
  final String status; // e.g., 'Collecting', 'Idle', 'Maintenance'
  final double wasteCapacityKg;
  final String lastUpdated;

  const VehicleModel({
    required this.id,
    required this.registrationNumber,
    required this.driverName,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.wasteCapacityKg,
    required this.lastUpdated,
  });

  // Factory to create a VehicleModel from JSON (API response)
  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as String,
      registrationNumber: json['registration_number'] as String,
      driverName: json['driver_name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      status: json['status'] as String,
      wasteCapacityKg: (json['waste_capacity_kg'] as num).toDouble(),
      lastUpdated: json['last_updated'] as String,
    );
  }

  @override
  List<Object> get props => [
        id,
        registrationNumber,
        driverName,
        latitude,
        longitude,
        status,
        wasteCapacityKg,
        lastUpdated,
      ];
}
