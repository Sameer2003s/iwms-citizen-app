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

    // --- FIX: Mapping to Exact API Keys (regNo, lat/lng, vehicleMode) ---
    
    // Registration Number (Prioritize 'regNo')
    final regNo = json['regNo']?.toString() 
        ?? json['VEHICLE_NO']?.toString() 
        ?? json['vehicle_no']?.toString();
    
    // Driver Name (Prioritize 'driverName'. Normalizes '-' to null for fallback.)
    final rawDriverName = json['driverName']?.toString() 
        ?? json['DRIVER_NAME']?.toString() 
        ?? json['driver_name']?.toString();
    
    final driver = (rawDriverName == '-' || rawDriverName?.trim().isEmpty == true) 
        ? null 
        : rawDriverName;
    
    // Map coordinates (Prioritize the inner, numeric 'lat' and 'lng' fields)
    final lat = _safeParseDouble(json['lat'] ?? json['LAT'] ?? json['latitude']);
    final lon = _safeParseDouble(json['lng'] ?? json['LON'] ?? json['longitude']);
    
    // Status field (Use 'vehicleMode' or 'ignitionStatus' as primary status source)
    final apiStatus = json['vehicleMode']?.toString()
        ?? json['ignitionStatus']?.toString()
        ?? json['VEHICLE_STATUS']?.toString() 
        ?? json['status']?.toString(); 
    
    // Load/capacity data (Using loadTruck as a best guess, mapping "nill" to 0)
    final loadData = json['loadTruck']?.toString() != 'nill'
        ? json['loadTruck']
        : (json['CURRENT_LOAD'] ?? json['load']); 
    
    // Last Update Time (Use 'lastSeen' as primary)
    final updateTime = json['lastSeen']?.toString() 
        ?? json['LAST_UPDATE_TIME']?.toString();

    // --- Model Assembly ---

    // Determine unique ID (Use deviceId as a robust fallback ID)
    final vehicleId = regNo ?? json['deviceId']?.toString() ?? '${lat}_${lon}';
    
    // Determine the status (Cleaned and capitalized for consistent UI display)
    String determinedStatus;
    if (apiStatus != null) {
      determinedStatus = apiStatus.isNotEmpty 
          ? apiStatus[0].toUpperCase() + apiStatus.substring(1).toLowerCase()
          : 'No Data';
      
      // Clean up generic/null statuses
      if (determinedStatus.toLowerCase() == 'nodata' || determinedStatus.isEmpty || determinedStatus.toLowerCase() == 'nill') {
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
      
      // Pass load data through safe parser
      wasteCapacityKg: _safeParseDouble(loadData),
      lastUpdated: updateTime,
    );
  }

  @override
  List<Object?> get props => [
        id, latitude, longitude, registrationNumber, driverName, status, wasteCapacityKg, lastUpdated
      ];
}
