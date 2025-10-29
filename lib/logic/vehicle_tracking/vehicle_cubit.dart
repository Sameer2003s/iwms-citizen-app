import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart'; 
import 'package:flutter_map/flutter_map.dart'; 
import 'package:latlong2/latlong.dart'; 

// Layered Imports
import '../../data/models/vehicle_model.dart';
import '../../data/repositories/vehicle_repository.dart';
import '../../core/constants.dart';

// --- NEW ENUM FOR FILTERING ---
enum VehicleFilter { all, running, idle, parked, noData }

// --- STATE DEFINITIONS ---

abstract class VehicleState extends Equatable {
  const VehicleState();
  @override
  List<Object?> get props => [];
}

class VehicleInitial extends VehicleState {}
class VehicleLoading extends VehicleState {}
class VehicleError extends VehicleState {
  final String message;
  const VehicleError(this.message);
  @override
  List<Object?> get props => [message];
}

class VehicleLoaded extends VehicleState {
  final List<VehicleModel> vehicles;
  final List<Marker> markers; 
  final VehicleModel? selectedVehicle;
  final VehicleFilter activeFilter; // NEW: Tracks the current filter

  const VehicleLoaded({
    required this.vehicles,
    required this.markers,
    this.selectedVehicle,
    this.activeFilter = VehicleFilter.all, // Default to all
  });

  @override
  List<Object?> get props => [vehicles, markers, selectedVehicle, activeFilter]; 

  // Helper method for easy state copying
  VehicleLoaded copyWith({
    VehicleModel? selectedVehicle,
    VehicleFilter? activeFilter,
  }) {
    return VehicleLoaded(
      vehicles: vehicles,
      markers: markers,
      selectedVehicle: selectedVehicle,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }
}

// --- CUBIT LOGIC ---

class VehicleCubit extends Cubit<VehicleState> {
  final VehicleRepository _repository;

  VehicleCubit(this._repository) : super(VehicleInitial());

  // Function to fetch vehicles from the repository (runs once on load)
  Future<void> fetchVehicles() async {
    emit(VehicleLoading());
    try {
      final vehicleList = await _repository.fetchAllVehicleLocations();
      
      final markers = _generateMarkers(vehicleList, selectVehicle); 
      
      emit(VehicleLoaded(vehicles: vehicleList, markers: markers));
    } catch (e) {
      print("Error fetching vehicles: $e");
      emit(VehicleError("Failed to fetch vehicle locations."));
    }
  }
  
  // NEW: Method to change the active filter
  void filterVehicles(VehicleFilter filter) {
    if (state is VehicleLoaded) {
      final loadedState = state as VehicleLoaded;
      if (loadedState.activeFilter != filter) {
        emit(loadedState.copyWith(activeFilter: filter, selectedVehicle: null));
      }
    }
  }

  // Function to handle marker tap event
  void selectVehicle(String? vehicleId) {
    if (state is! VehicleLoaded) return;
    
    final loadedState = state as VehicleLoaded;
    
    if (vehicleId == null || loadedState.selectedVehicle?.id == vehicleId) {
      if (loadedState.selectedVehicle != null) {
        emit(loadedState.copyWith(selectedVehicle: null));
      }
      return;
    }
    
    try {
      final selected = loadedState.vehicles.firstWhere(
        (v) => v.id == vehicleId, 
      );
      emit(loadedState.copyWith(selectedVehicle: selected));
    } catch (e) {
      print('Vehicle not found for ID: $vehicleId'); 
    }
  }

  // Helper to convert VehicleModel list into FlutterMap Markers
  List<Marker> _generateMarkers(List<VehicleModel> vehicles, Function(String?) onMarkerTap) {
    return vehicles.map((vehicle) {
      final isCollecting = vehicle.status == 'Running';
      final markerColor = isCollecting ? Colors.green.shade800 : (vehicle.status == 'Idle' ? Colors.orange : (vehicle.status == 'Parked' ? Colors.blueGrey : Colors.grey));
      
      return Marker(
        width: 40.0,
        height: 40.0,
        point: LatLng(vehicle.latitude, vehicle.longitude),
        child: GestureDetector(
          onTap: () => onMarkerTap(vehicle.id), 
          child: Icon(
            Icons.local_shipping,
            color: markerColor,
            size: 35.0,
          ),
        ),
      );
    }).toList();
  }
}
