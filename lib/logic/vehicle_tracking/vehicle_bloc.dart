import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart'; 
// FIX: Import Events (defines VehicleEvent, VehicleFetchRequested, etc.)
import 'vehicle_event.dart'; 
import '../../data/models/vehicle_model.dart';
import '../../data/repositories/vehicle_repository.dart';
// FIX: Import constants (defines VehicleFilter enum)
import '../../core/constants.dart'; 

// --- STATE DEFINITIONS ---

abstract class VehicleState extends Equatable {
  const VehicleState();
  // FIX: Allow nullable objects in props for consistency
  @override
  List<Object?> get props => [];
}

// FIX: Added 'const' to constructors
class VehicleInitial extends VehicleState { const VehicleInitial(); }
class VehicleLoading extends VehicleState {}
class VehicleError extends VehicleState {
  final String message;
  const VehicleError(this.message);
  @override
  List<Object?> get props => [message];
}

class VehicleLoaded extends VehicleState {
  final List<VehicleModel> vehicles;
  final VehicleModel? selectedVehicle;
  final VehicleFilter activeFilter; 

  const VehicleLoaded(this.vehicles, {
    this.selectedVehicle,
    this.activeFilter = VehicleFilter.all,
  });

  @override
  List<Object?> get props => [vehicles, selectedVehicle, activeFilter]; 

  VehicleLoaded copyWith({
    VehicleModel? selectedVehicle,
    VehicleFilter? activeFilter,
    List<VehicleModel>? vehicles,
  }) {
    return VehicleLoaded(
      vehicles ?? this.vehicles,
      selectedVehicle: selectedVehicle,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }
}

// --- BLOC LOGIC ---

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final VehicleRepository _repository;
  Timer? _timer;
  static const int refreshIntervalSeconds = 15; // Auto-refresh interval

  // FIX: Now this line is valid because VehicleInitial is const.
  VehicleBloc(this._repository) : super(const VehicleInitial()) { 
    // 1. Event Mappings
    on<VehicleFetchRequested>(_onFetchRequested);
    on<VehicleFilterUpdated>(_onFilterUpdated);
    on<VehicleSelectionUpdated>(_onSelectionUpdated);
    
    _startAutoRefresh();
  }
  
  // 🟢 FIX: New helper to check status aliases (Moving Vehicle maps to running)
  bool _isVehicleRunning(VehicleModel v) {
    final status = (v.status ?? '').toLowerCase();
    return status == 'running' || status == 'moving vehicle';
  }

  // --- Core Fetch Logic ---
  Future<void> _fetchAndEmitVehicles(Emitter<VehicleState> emit, {bool showLoading = true}) async {
    if (showLoading && state is! VehicleLoaded) {
      emit(VehicleLoading());
    }
    try {
      final vehicleList = await _repository.fetchAllVehicleLocations();
      
      // Preserve existing filter and selection if already loaded
      final currentState = state is VehicleLoaded ? state as VehicleLoaded : null;

      emit(VehicleLoaded(
        vehicleList,
        selectedVehicle: currentState?.selectedVehicle,
        activeFilter: currentState?.activeFilter ?? VehicleFilter.all,
      ));
    } catch (e) {
      if (state is VehicleLoaded) {
        // Keep existing data on failure to prevent flicker (silent fail)
        print("Auto-refresh failed: $e. Keeping existing map data.");
      } else {
        emit(VehicleError("Failed to fetch vehicle locations."));
      }
    }
  }

  // --- Event Handlers ---

  void _onFetchRequested(VehicleFetchRequested event, Emitter<VehicleState> emit) async {
    // For manual fetch, we show loading screen if not already loaded
    await _fetchAndEmitVehicles(emit, showLoading: true);
  }

  void _onFilterUpdated(VehicleFilterUpdated event, Emitter<VehicleState> emit) {
    if (state is VehicleLoaded) {
      final loadedState = state as VehicleLoaded;
      if (loadedState.activeFilter != event.filter) {
        emit(loadedState.copyWith(activeFilter: event.filter, selectedVehicle: null)); 
      }
    }
  }

  void _onSelectionUpdated(VehicleSelectionUpdated event, Emitter<VehicleState> emit) {
    if (state is! VehicleLoaded) return;
    
    final loadedState = state as VehicleLoaded;
    final vehicleId = event.vehicleId;
    
    VehicleModel? selected;
    if (vehicleId != null) {
      try {
        selected = loadedState.vehicles.firstWhere((v) => v.id == vehicleId);
      } catch (e) {
        print('Vehicle not found for ID: $vehicleId'); 
      }
    }
    
    emit(loadedState.copyWith(selectedVehicle: selected));
  }
  
  // --- Timer Management (Auto-refresh) ---
  void _startAutoRefresh() {
    _timer?.cancel(); 
    
    _timer = Timer.periodic(
      const Duration(seconds: refreshIntervalSeconds),
      (timer) {
        add(VehicleFetchRequested());
      },
    );
  }

  // 🟢 FIX: Map API status words to app statuses using robust lowercase comparison.
  Color _getStatusColor(String? status) {
    final s = (status ?? '').toLowerCase();
    // Use the helper for running/moving alias
    if (_isVehicleRunning(VehicleModel(id: '', latitude: 0, longitude: 0, status: status))) {
        return Colors.green.shade700;
    }
    
    switch (s) {
      case 'idle':
        return Colors.orange.shade700;
      case 'parked':
      case 'off': // Maps "OFF" or "Parked" API status to parked color
      case 'stopped':
        return Colors.blueGrey;
      case 'no data':
      case 'maintenance':
        return Colors.red;
      default:
        return kPlaceholderColor;
    }
  }
  
  // 🟢 FIX: New helper to get the count based on aliases for the UI
  int countVehiclesByFilter(VehicleFilter filter) {
      if (state is! VehicleLoaded) return 0;
      final vehicles = (state as VehicleLoaded).vehicles;
      
      switch(filter) {
          case VehicleFilter.all:
              return vehicles.length;
          case VehicleFilter.running:
              // Use the helper to catch "moving vehicle"
              return vehicles.where((v) => _isVehicleRunning(v)).length;
          case VehicleFilter.idle:
              return vehicles.where((v) => (v.status ?? '').toLowerCase() == 'idle').length;
          case VehicleFilter.parked:
              return vehicles.where((v) => (v.status ?? '').toLowerCase() == 'parked' || (v.status ?? '').toLowerCase() == 'off' || (v.status ?? '').toLowerCase() == 'stopped').length;
          case VehicleFilter.noData:
              return vehicles.where((v) => (v.status ?? '').toLowerCase() == 'no data').length;
      }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
