import 'package:equatable/equatable.dart';

class VehicleModel extends Equatable {
  // Core identification and location fields
  final String id; 
  final double latitude; 
  final double longitude; 

  // Fields made nullable to handle missing API data without crashing
  final String? registrationNumber;
  final String? driverName;
  final String? status; 
  final double? wasteCapacityKg;
  final String? lastUpdated;

  const VehicleModel({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.registrationNumber,
    this.driverName,
    this.status,
    this.wasteCapacityKg,
    this.lastUpdated,
  });

  // Factory constructor to safely parse JSON from the API
  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    // Helper function for safe double parsing, defaulting to 0.0 if data is null or invalid
    double _safeParseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is String) return double.tryParse(value) ?? 0.0;
      if (value is num) return value.toDouble();
      return 0.0;
    }

    // --- CRITICAL API KEY MAPPING (Assuming VAM/ZIGMA Telematics Fields) ---
    
    // Registration Number (Assuming keys like VEHICLE_NO or VEHICLENO)
    final regNo = json['VEHICLE_NO']?.toString() ?? json['VEHICLENO']?.toString();
    
    // Driver Name
    final driver = json['DRIVER_NAME']?.toString() ?? json['DRIVER']?.toString();
    
    // Map coordinates (critical for map view)
    // NOTE: If LAT/LON are strings, the safe parser handles conversion.
    final lat = _safeParseDouble(json['LAT'] ?? json['latitude']);
    final lon = _safeParseDouble(json['LON'] ?? json['longitude']);
    
    // Status field
    final apiStatus = json['VEHICLE_STATUS']?.toString() ?? json['STATUS']?.toString();
    
    // Load/capacity data
    final loadData = json['CURRENT_LOAD'] ?? json['LOAD'];
    
    // Last Update Time
    final updateTime = json['LAST_UPDATE_TIME']?.toString() ?? json['LUPT']?.toString();

    // --- Model Assembly ---

    // Determine unique ID
    final vehicleId = regNo ?? '${lat}_${lon}';
    
    // Determine the status (Cleaned and capitalized for consistent filtering/UI display)
    String determinedStatus;
    if (apiStatus != null) {
      determinedStatus = apiStatus[0].toUpperCase() + apiStatus.substring(1).toLowerCase();
      
      if (determinedStatus.toLowerCase() == 'nodata' || determinedStatus.isEmpty) {
        determinedStatus = 'No Data'; 
      }
    } else {
        determinedStatus = 'No Data'; 
    }


    return VehicleModel(
      id: vehicleId,
      latitude: lat,
      longitude: lon,
      
      // Assigning mapped values
      registrationNumber: regNo,
      driverName: driver,
      status: determinedStatus, 
      
      wasteCapacityKg: _safeParseDouble(loadData),
      lastUpdated: updateTime,
    );
  }

  @override
  List<Object?> get props => [
        id, latitude, longitude, registrationNumber, driverName, status, wasteCapacityKg, lastUpdated
      ];
}
