import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:iwms_citizen_app/core/di.dart';
import 'package:iwms_citizen_app/data/models/vehicle_model.dart';
import 'package:iwms_citizen_app/logic/vehicle_tracking/vehicle_bloc.dart';
import 'package:iwms_citizen_app/logic/vehicle_tracking/vehicle_event.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants.dart';
import '../../../core/theme/app_colors.dart'; // Using your app's colors

class MapScreen extends StatefulWidget {
  final String? driverName;
  final String? vehicleNumber;

  const MapScreen({
    super.key,
    this.driverName,
    this.vehicleNumber,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  // Your original location logic - good!
  final LatLng _userLocation = const LatLng(11.3410, 77.7172); // Erode

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Use getIt to create the BLoC
      create: (context) => getIt<VehicleBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Live Vehicle Tracking'),
        ),
        body: BlocBuilder<VehicleBloc, VehicleState>(
          builder: (context, state) {
            // Re-create the UI based on BLoC state
            return Stack(
              children: [
                _buildMap(context, state),
                _buildFilterChips(context, state),
                // Show loading only if it's the very first load
                if (state is VehicleLoading)
                  const Center(child: CircularProgressIndicator()),
                // Show error only if it's the very first load
                if (state is VehicleError)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                  ),
                _buildVehicleInfoPanel(context, state),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- MAP WIDGET ---
  Widget _buildMap(BuildContext context, VehicleState state) {
    List<VehicleModel> vehiclesToShow = [];
    VehicleModel? selectedVehicle;
    VehicleFilter activeFilter = VehicleFilter.all;

    if (state is VehicleLoaded) {
      selectedVehicle = state.selectedVehicle;
      activeFilter = state.activeFilter;

      // Apply your filter logic
      vehiclesToShow = state.vehicles.where((v) {
        final status = v.status?.toLowerCase() ?? 'no data';
        switch (activeFilter) {
          case VehicleFilter.all:
            return true;
          case VehicleFilter.running:
            return status == 'running';
          case VehicleFilter.idle:
            return status == 'idle';
          case VehicleFilter.parked:
            return status == 'parked';
          case VehicleFilter.noData:
            return status == 'no data';
        }
      }).toList();
    }

    // Build markers
    final markers = vehiclesToShow.map((vehicle) {
      final isSelected = selectedVehicle?.id == vehicle.id;
      return Marker(
        width: 100,
        height: 80,
        point: LatLng(vehicle.latitude, vehicle.longitude), // Uses non-nullable lat/lng
        child: GestureDetector(
          onTap: () {
            context
                .read<VehicleBloc>()
                .add(VehicleSelectionUpdated(vehicle.id));
          },
          child: _VehicleMarker(
            vehicle: vehicle,
            isSelected: isSelected,
            getVehicleStatusColor: context.read<VehicleBloc>().getStatusColor,
          ),
        ),
      );
    }).toList();

    // Add user marker
    markers.add(Marker(
      width: 80,
      height: 80,
      point: _userLocation,
      child: const Column(
        children: [
          Icon(Icons.person_pin_circle, color: Colors.green, size: 35),
          Text('You',
              style:
                  TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        ],
      ),
    ));

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _userLocation,
        initialZoom: 14.0,
        onTap: (tapPosition, point) {
          // Deselect vehicle when tapping map
          context.read<VehicleBloc>().add(const VehicleSelectionUpdated(null));
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }

  // --- FILTER CHIPS ---
  Widget _buildFilterChips(BuildContext context, VehicleState state) {
    if (state is! VehicleLoaded) {
      return Container(); // Don't show filters unless loaded
    }

    final bloc = context.read<VehicleBloc>();

    return Positioned(
      top: 10,
      left: 10,
      right: 10,
      child: SizedBox(
        height: 50,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: VehicleFilter.values.map((filter) {
            final count = bloc.countVehiclesByFilter(filter);
            final isSelected = state.activeFilter == filter;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: FilterChip(
                label: Text(
                    '${filter.name.toUpperCase()} ($count)'), // Use count variable
                selected: isSelected,
                onSelected: (bool selected) {
                  if (selected) {
                    bloc.add(VehicleFilterUpdated(filter));
                  }
                },
                backgroundColor: Colors.white,
                selectedColor: kPrimaryColor.withOpacity(0.8),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : kTextColor,
                  fontWeight: FontWeight.bold,
                ),
                checkmarkColor: Colors.white,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // --- VEHICLE INFO PANEL ---
  Widget _buildVehicleInfoPanel(BuildContext context, VehicleState state) {
    if (state is! VehicleLoaded || state.selectedVehicle == null) {
      return Container(); // No panel if no vehicle is selected
    }

    final vehicle = state.selectedVehicle!;
    final statusColor =
        context.read<VehicleBloc>().getStatusColor(vehicle.status);

    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                // --- FIX: Use 'registrationNumber' ---
                vehicle.registrationNumber ?? 'Unknown Vehicle',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kTextColor),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration:
                        BoxDecoration(color: statusColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    vehicle.status?.toUpperCase() ?? 'NO DATA',
                    style: TextStyle(
                        fontSize: 16,
                        color: statusColor,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Divider(height: 24),
              Text(
                // --- FIX: Use 'wasteCapacityKg' as 'speed' is not available ---
                'Load: ${vehicle.wasteCapacityKg ?? 0} kg',
                style: const TextStyle(fontSize: 16, color: kTextColor),
              ),
              const SizedBox(height: 8),
              Text(
                // --- FIX: Use 'lastUpdated' ---
                'Last Update: ${vehicle.lastUpdated ?? 'N/A'}',
                style: const TextStyle(fontSize: 16, color: kTextColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- VEHICLE MARKER WIDGET ---
class _VehicleMarker extends StatelessWidget {
  final VehicleModel vehicle;
  final bool isSelected;
  final Color Function(String?) getVehicleStatusColor;

  const _VehicleMarker({
    required this.vehicle,
    required this.isSelected,
    required this.getVehicleStatusColor,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = getVehicleStatusColor(vehicle.status);
    final size = isSelected ? 45.0 : 30.0;

    return Column(
      children: [
        // Marker Icon
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: size,
          width: size,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? Colors.white : Colors.transparent,
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 4))
                  ]
                : null,
          ),
          child: const Icon(
            Icons.local_shipping,
            color: Colors.white,
            size: 20,
          ),
        ),
        // Label
        if (isSelected)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                // --- FIX: Use 'registrationNumber' ---
                vehicle.registrationNumber ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: kTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
      ],
    );
  }
}

