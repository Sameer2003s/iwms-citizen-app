import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as geo; 
import 'dart:ui'; // Explicitly used for Path, Canvas

// Layered Imports (Using absolute paths for guaranteed resolution)
import 'package:iwms_citizen_app/core/constants.dart';
import 'package:iwms_citizen_app/core/di.dart';
import 'package:iwms_citizen_app/logic/vehicle_tracking/vehicle_bloc.dart'; 
import 'package:iwms_citizen_app/logic/vehicle_tracking/vehicle_event.dart'; 
import 'package:iwms_citizen_app/data/models/vehicle_model.dart'; 


// --- 1. CUSTOM MARKER WIDGET (The stylized pin) ---
class VehicleMarkerWidget extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final String vehicleId;
  final Function(String?) onTap;

  const VehicleMarkerWidget({
    super.key,
    required this.color,
    required this.isSelected,
    required this.vehicleId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(vehicleId),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.yellow.shade200 : Colors.white,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: isSelected ? 10 : 5,
                  spreadRadius: isSelected ? 2 : 0,
                ),
              ],
            ),
            child: const Icon(
              Icons.local_shipping_outlined, // Truck icon
              color: Colors.white,
              size: 20,
            ),
          ),
          // Pin Pointer (Small triangle pointing down)
          CustomPaint(
            size: const Size(10, 10),
            painter: PinPointerPainter(color: color),
          ),
        ],
      ),
    );
  }
}

// 2. Custom Painter to draw the bottom pin triangle
class PinPointerPainter extends CustomPainter {
  final Color color;
  PinPointerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path(); 
    path.moveTo(size.width / 2, size.height);
    path.lineTo(0, 0);
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant PinPointerPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
// --- END CUSTOM MARKER WIDGETS ---


class MapScreen extends StatelessWidget {
  final String? driverName;
  final String? vehicleNumber;

  const MapScreen({
    super.key,
    this.driverName,
    this.vehicleNumber,
  });

  static const geo.LatLng _initialCenter = geo.LatLng(20.5937, 78.9629); 

  // --- Utility Helpers ---
  Color _getStatusColor(String? status) {
    // FIX: Safely handles null status passed from the model
    final s = (status ?? '').toLowerCase();
    switch (s) {
      case 'running':
      case 'moving vehicle': // Matches the API's 'Moving vehicle'
        return Colors.green.shade700;
      case 'idle':
        return Colors.orange.shade700;
      case 'parked':
      case 'off': // Matches the API's 'OFF' status
        return Colors.blueGrey;
      case 'no data':
      case 'maintenance':
        return Colors.red;
      default:
        return kPlaceholderColor;
    }
  }

  Widget _detailRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: kTextColor)),
          const Spacer(),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, VehicleFilter filter, VehicleLoaded loadedState) {
    final isSelected = loadedState.activeFilter == filter;
    
    String statusKey;
    switch (filter) {
      case VehicleFilter.all:
        statusKey = 'All';
        break;
      case VehicleFilter.running:
        statusKey = 'Running';
        break;
      case VehicleFilter.idle:
        statusKey = 'Idle';
        break;
      case VehicleFilter.parked:
        statusKey = 'Parked';
        break;
      case VehicleFilter.noData:
        statusKey = 'No Data'; 
        break;
      default:
        statusKey = 'All';
        break;
    }
    
    // 🟢 FIX: Call the Bloc's centralized helper method for the accurate count.
    final count = context.read<VehicleBloc>().countVehiclesByFilter(filter);

    final color = _getStatusColor(statusKey); 

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ActionChip(
        avatar: isSelected ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
        label: Text(
          '$statusKey ($count)', 
          style: TextStyle(
            color: isSelected ? Colors.white : color, 
            fontWeight: FontWeight.bold, 
            fontSize: 13
          )
        ),
        backgroundColor: isSelected ? color : Colors.white,
        side: BorderSide(color: color, width: 1.5),
        onPressed: () {
          final newFilter = isSelected ? VehicleFilter.all : filter;
          context.read<VehicleBloc>().add(VehicleFilterUpdated(newFilter));
        },
      ),
    );
  }

  Widget _buildVehicleListModal(BuildContext context, List<VehicleModel> vehicles) {
    // 🔄 FIX: Read the Bloc
    final loadedState = context.read<VehicleBloc>().state as VehicleLoaded;
    
    // The filter list logic remains correct as it relies on the loadedState filter.
    final filteredList = vehicles.where((v) {
      if (loadedState.activeFilter == VehicleFilter.all) return true;
      final vehicleStatusLowerCase = (v.status ?? 'No Data').toLowerCase();
      
      // Match the vehicle status to the filter by its alias (e.g., 'running' matches 'moving vehicle')
      switch (loadedState.activeFilter) {
        case VehicleFilter.running:
          return vehicleStatusLowerCase == 'running' || vehicleStatusLowerCase == 'moving vehicle';
        case VehicleFilter.idle:
          return vehicleStatusLowerCase == 'idle';
        case VehicleFilter.parked:
          return vehicleStatusLowerCase == 'parked' || vehicleStatusLowerCase == 'off' || vehicleStatusLowerCase == 'stopped';
        case VehicleFilter.noData:
          return vehicleStatusLowerCase == 'no data';
        case VehicleFilter.all:
          return true;
      }
    }).toList();


    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Filtered Vehicles (${filteredList.length})',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20, fontWeight: FontWeight.bold, color: kTextColor),
            ),
          ),
          const Divider(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final vehicle = filteredList[index];
                final isSelected = loadedState.selectedVehicle?.id == vehicle.id;
                
                return _buildVehicleTile(context, vehicle, isSelected);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildVehicleTile(BuildContext context, VehicleModel vehicle, bool isSelected) {
    final statusColor = _getStatusColor(vehicle.status); 

    final regNo = vehicle.registrationNumber ?? 'N/A';
    // 🟢 FIX: Handle '-' or empty string for driver name display
    final driver = (vehicle.driverName == null || vehicle.driverName!.trim().isEmpty || vehicle.driverName! == '-') 
        ? 'Unknown' 
        : vehicle.driverName!;
        
    final statusText = vehicle.status ?? 'No Data';
    final load = vehicle.wasteCapacityKg?.toStringAsFixed(1) ?? '0.0';


    return InkWell(
      onTap: () {
        context.read<VehicleBloc>().add(VehicleSelectionUpdated(vehicle.id));
        Navigator.pop(context); 
      },
      child: Container(
        padding: const EdgeInsets.all(12.0),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: isSelected ? kPrimaryColor : kBorderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(regNo, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(statusText, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Driver: $driver', style: const TextStyle(fontSize: 14, color: kPlaceholderColor)),
            Text('Load: $load kg', style: TextStyle(fontSize: 14, color: kTextColor.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context, VehicleModel vehicle) {
    final regNo = vehicle.registrationNumber ?? 'N/A';
    // 🟢 FIX: Handle '-' or empty string for driver name display
    final driver = (vehicle.driverName == null || vehicle.driverName!.trim().isEmpty || vehicle.driverName! == '-') 
        ? 'Unknown' 
        : vehicle.driverName!;
        
    final statusText = vehicle.status ?? 'No Data';
    final load = vehicle.wasteCapacityKg?.toStringAsFixed(1) ?? '0.0';
    final updateTime = vehicle.lastUpdated ?? 'Unknown Time';

    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20), 
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Details: $regNo', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 22, color: kPrimaryColor)),
              IconButton(
                icon: const Icon(Icons.close, color: kPlaceholderColor),
                onPressed: () => context.read<VehicleBloc>().add(const VehicleSelectionUpdated(null)),
              ),
            ],
          ),
          const Divider(),
          _detailRow(Icons.person, 'Driver:', driver, kTextColor), 
          _detailRow(Icons.pin_drop_outlined, 'Status:', statusText, _getStatusColor(statusText)), 
          _detailRow(Icons.speed, 'Load:', '$load kg', Colors.blue),
          _detailRow(Icons.history, 'Last Update:', updateTime, kTextColor.withOpacity(0.8)),
        ],
      ),
    );
  }


  // --- Main Widget ---
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<VehicleBloc>()..add(VehicleFetchRequested()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Live Vehicle Monitoring'),
          backgroundColor: kPrimaryColor,
        ),
        body: BlocBuilder<VehicleBloc, VehicleState>(
          builder: (context, state) {
            if (state is VehicleLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is VehicleError) {
              return Center(child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)));
            }

            final loadedState = state is VehicleLoaded ? state : null;
            if (loadedState == null) {
              return const Center(child: Text('Map data is unavailable.', style: TextStyle(color: kPlaceholderColor)));
            }
            
            // --- Vehicle Filtering for Markers (Logic remains the same) ---
            final String filterStatusLowerCase = loadedState.activeFilter == VehicleFilter.all
                ? 'all'
                : (loadedState.activeFilter == VehicleFilter.noData
                    ? 'no data' 
                    : loadedState.activeFilter.name.toLowerCase()); 
                    
            final visibleVehicles = loadedState.vehicles.where((v) {
              final vehicleStatusLowerCase = (v.status ?? 'No Data').toLowerCase();
              
              if (filterStatusLowerCase == 'all') {
                return true;
              }
              
              // We rely on the aliases configured in the filter logic in the List Modal.
              if (filterStatusLowerCase == 'running') {
                  return vehicleStatusLowerCase == 'running' || vehicleStatusLowerCase == 'moving vehicle';
              }
              if (filterStatusLowerCase == 'parked') {
                  return vehicleStatusLowerCase == 'parked' || vehicleStatusLowerCase == 'off' || vehicleStatusLowerCase == 'stopped';
              }
              
              return vehicleStatusLowerCase == filterStatusLowerCase;
            }).toList();

            final visibleMarkers = visibleVehicles.map((vehicle) {
              final isSelected = loadedState.selectedVehicle?.id == vehicle.id; 
              final markerColor = _getStatusColor(vehicle.status);

              return Marker(
                width: 50.0,
                height: 50.0,
                point: geo.LatLng(vehicle.latitude, vehicle.longitude),
                child: VehicleMarkerWidget(
                  color: markerColor,
                  isSelected: isSelected,
                  vehicleId: vehicle.id,
                  onTap: (id) => context.read<VehicleBloc>().add(VehicleSelectionUpdated(id)),
                ),
              );
            }).toList();

            // --- Full Screen Map Layout ---
            return Stack(
              children: [
                // 1. Map Widget (Background)
                FlutterMap(
                  options: MapOptions(
                    initialCenter: _initialCenter,
                    initialZoom: 5.5, 
                    onTap: (tapPosition, point) {
                        context.read<VehicleBloc>().add(const VehicleSelectionUpdated(null)); 
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.iwms_citizen_app',
                    ),
                    MarkerLayer(
                      markers: visibleMarkers,
                    ),
                  ],
                ),
                
                // 2. Filter Bar (Pinned to the top)
                Positioned(
                  top: 10,
                  left: 10,
                  right: 10,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: VehicleFilter.values.map((filter) {
                                  return _buildFilterChip(context, filter, loadedState);
                                }).toList(),
                              ),
                            ),
                          ),
                          // 🟢 FIX: Repositioned the Vehicle List button here
                          IconButton(
                            icon: const Icon(Icons.list_alt, color: kPrimaryColor),
                            tooltip: 'Show Vehicle List',
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                ),
                                builder: (_) => _buildVehicleListModal(context, loadedState.vehicles),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // 3. Floating Vehicle Details Card (Bottom Overlay)
                if (loadedState.selectedVehicle != null)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildDetailsCard(context, loadedState.selectedVehicle!),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
