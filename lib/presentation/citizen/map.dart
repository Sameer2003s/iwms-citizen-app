import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as geo;
import 'dart:ui'; // Explicitly used for Path, Canvas

// Layered Imports (Using absolute paths for guaranteed resolution)
import '../../core/constants.dart';
import '../../core/di.dart';
import '../../logic/vehicle_tracking/vehicle_bloc.dart';
import '../../logic/vehicle_tracking/vehicle_event.dart';
import '../../data/models/vehicle_model.dart';

// --- 1. NEW CREATIVE MARKER WIDGET ---
class VehicleMarkerWidget extends StatefulWidget {
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
  State<VehicleMarkerWidget> createState() => _VehicleMarkerWidgetState();
}

class _VehicleMarkerWidgetState extends State<VehicleMarkerWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isSelected) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant VehicleMarkerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected) {
      _animationController.repeat(reverse: true);
    } else {
      _animationController.stop();
      _animationController.reset();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A modern, stacked marker design
    return GestureDetector(
      onTap: () => widget.onTap(widget.vehicleId),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulsing animation for selected marker
          if (widget.isSelected)
            FadeTransition(
              opacity: Tween<double>(begin: 0.7, end: 0.0)
                  .animate(_animationController),
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          // Main marker body (pin shape)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black45, blurRadius: 5, offset: Offset(0, 2))
              ],
            ),
            child: const Icon(
              Icons.local_shipping,
              color: Colors.white,
              size: 20,
            ),
          ),
          // Pin pointer
          Positioned(
            top: 36,
            child: CustomPaint(
              size: const Size(12, 12),
              painter: PinPointerPainter(color: widget.color),
            ),
          ),
        ],
      ),
    );
  }
}

// 2. Custom Painter (Unchanged)
class PinPointerPainter extends CustomPainter {
  final Color color;
  PinPointerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
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
// --- END MARKER WIDGETS ---

// 🟢 START FIX: Converted to StatefulWidget for search
class MapScreen extends StatefulWidget {
  final String? driverName;
  final String? vehicleNumber;

  // 🟢 START FIX: Removed 'const' from constructor
  const MapScreen({
    // 🟢 END FIX
    super.key,
    this.driverName,
    this.vehicleNumber,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // 🟢 END FIX
  static const geo.LatLng _initialCenter = geo.LatLng(20.5937, 78.9629);

  // 🟢 START ADDITION: State for Search UI
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<String> _suggestions = [];
  bool _isSearchFocused = false;
  // 🟢 END ADDITION

  @override
  void initState() {
    super.initState();
    // 🟢 START ADDITION: Listeners for Search
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
        if (!_isSearchFocused) {
          _suggestions = []; // Clear suggestions when unfocused
        }
      });
    });

    _searchController.addListener(() {
      final text = _searchController.text;
      if (text.isNotEmpty && _isSearchFocused) {
        // Simulate fetching 4 suggestions
        setState(() {
          _suggestions = [
            '$text near me',
            '$text Main Road',
            '${text}point of interest',
            'City starting with $text',
          ];
        });
      } else {
        setState(() {
          _suggestions = [];
        });
      }
    });
    // 🟢 END ADDITION
  }

  @override
  void dispose() {
    // 🟢 START ADDITION: Dispose controllers
    _searchController.dispose();
    _searchFocusNode.dispose();
    // 🟢 END ADDITION
    super.dispose();
  }

  // --- Utility Helpers ---

  // Status color logic (unchanged)
  Color _getStatusColor(String? status) {
    final s = (status ?? '').toLowerCase();
    switch (s) {
      case 'running':
        return Colors.green.shade700;
      case 'idle':
        return Colors.orange.shade700;
      case 'parked':
        return Colors.blueGrey.shade700;
      case 'no data':
      case 'maintenance':
        return Colors.red.shade700;
      default:
        return kPlaceholderColor;
    }
  }

  // --- NEW UI WIDGETS ---

  // 1. Redesigned Filter Chip
  Widget _buildFilterChip(
      BuildContext context, VehicleFilter filter, VehicleLoaded loadedState) {
    final isSelected = loadedState.activeFilter == filter;

    String statusKey;
    IconData statusIcon;
    switch (filter) {
      case VehicleFilter.all:
        statusKey = 'All';
        statusIcon = Icons.clear_all;
        break;
      case VehicleFilter.running:
        statusKey = 'Running';
        statusIcon = Icons.directions_run;
        break;
      case VehicleFilter.idle:
        statusKey = 'Idle';
        statusIcon = Icons.pause_circle_outline;
        break;
      case VehicleFilter.parked:
        statusKey = 'Parked';
        statusIcon = Icons.local_parking;
        break;
      case VehicleFilter.noData:
        statusKey = 'No Data';
        statusIcon = Icons.signal_cellular_off;
        break;
    }

    final count = context.read<VehicleBloc>().countVehiclesByFilter(filter);
    final color = _getStatusColor(statusKey);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: InkWell(
        onTap: () {
          final newFilter = isSelected ? VehicleFilter.all : filter;
          context.read<VehicleBloc>().add(VehicleFilterUpdated(newFilter));
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color : kBorderColor,
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [
                    const BoxShadow(
                      color: Colors.black12,
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    )
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                statusIcon,
                size: 18,
                color: isSelected ? Colors.white : color,
              ),
              const SizedBox(width: 6),
              Text(
                '$statusKey ($count)',
                style: TextStyle(
                  color: isSelected ? Colors.white : kTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 2. Redesigned Vehicle List Modal (Unchanged logic, just UI trigger)
  Widget _buildVehicleListModal(
      BuildContext context, List<VehicleModel> vehicles) {
    final loadedState = context.read<VehicleBloc>().state as VehicleLoaded;

    final filteredList = vehicles.where((v) {
      if (loadedState.activeFilter == VehicleFilter.all) return true;
      final vehicleStatusLowerCase = (v.status ?? 'No Data').toLowerCase();
      switch (loadedState.activeFilter) {
        case VehicleFilter.running:
          return vehicleStatusLowerCase == 'running';
        case VehicleFilter.idle:
          return vehicleStatusLowerCase == 'idle';
        case VehicleFilter.parked:
          return vehicleStatusLowerCase == 'parked';
        case VehicleFilter.noData:
          return vehicleStatusLowerCase == 'no data';
        case VehicleFilter.all:
          return true;
      }
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.7, // Taller modal
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Grabber handle
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: kBorderColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtered Vehicles (${filteredList.length})',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: kTextColor),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
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

  // 3. Redesigned Vehicle List Tile
  Widget _buildVehicleTile(
      BuildContext context, VehicleModel vehicle, bool isSelected) {
    final statusColor = _getStatusColor(vehicle.status);

    final regNo = vehicle.registrationNumber ?? 'N/A';
    final driver = (vehicle.driverName == null ||
            vehicle.driverName!.trim().isEmpty ||
            vehicle.driverName! == '-')
        ? 'Unknown'
        : vehicle.driverName!;

    final statusText = vehicle.status ?? 'No Data';
    final load = vehicle.wasteCapacityKg?.toStringAsFixed(1) ?? '0.0';

    return InkWell(
      onTap: () {
        context.read<VehicleBloc>().add(VehicleSelectionUpdated(vehicle.id));
        Navigator.pop(context); // Close the modal
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryColor.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
              color: isSelected ? kPrimaryColor : kBorderColor, width: 1.5),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.local_shipping, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(regNo,
                      style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                          color: kTextColor)),
                  const SizedBox(height: 4),
                  Text('Driver: $driver',
                      style: const TextStyle(
                          fontSize: 14, color: kPlaceholderColor)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(statusText,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('$load kg',
                    style: TextStyle(
                        fontSize: 14,
                        color: kTextColor.withOpacity(0.8),
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 4. Redesigned Details Card (now part of the bottom sheet)
  // 🟢 START FIX: Added {Key? key}
  Widget _buildDetailsCard(BuildContext context, VehicleModel vehicle,
      {Key? key}) {
    // 🟢 END FIX
    final regNo = vehicle.registrationNumber ?? 'N/A';
    final driver = (vehicle.driverName == null ||
            vehicle.driverName!.trim().isEmpty ||
            vehicle.driverName! == '-')
        ? 'Unknown'
        : vehicle.driverName!;

    final statusText = vehicle.status ?? 'No Data';
    final load = vehicle.wasteCapacityKg?.toStringAsFixed(1) ?? '0.0';
    final updateTime = vehicle.lastUpdated ?? 'Unknown Time';

    Widget detailRow(IconData icon, String label, String value, Color color) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          children: [
            Icon(icon, size: 20, color: kPlaceholderColor),
            const SizedBox(width: 12),
            Text(label,
                style: const TextStyle(fontSize: 15, color: kPlaceholderColor)),
            const Spacer(),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    // 🟢 START FIX: Wrapped Column in SingleChildScrollView to prevent overflow
    return SingleChildScrollView(
      key: key,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0), // Removed bottom padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    regNo,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontSize: 24,
                        color: kTextColor,
                        fontWeight: FontWeight.w800),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: kPlaceholderColor),
                  onPressed: () => context
                      .read<VehicleBloc>()
                      .add(const VehicleSelectionUpdated(null)),
                ),
              ],
            ),
            Text(
              'Driver: $driver',
              style: const TextStyle(
                  fontSize: 16,
                  color: kPlaceholderColor,
                  fontWeight: FontWeight.w500),
            ),
            const Divider(height: 24),
            detailRow(Icons.pin_drop_outlined, 'Status:', statusText,
                _getStatusColor(statusText)),
            detailRow(Icons.scale_outlined, 'Load:', '$load kg', kTextColor),
            detailRow(Icons.history, 'Last Update:', updateTime, kTextColor),
            const SizedBox(height: 20), // Added padding for scroll end
          ],
        ),
      ),
    );
    // 🟢 END FIX
  }

  // --- Main Widget ---
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<VehicleBloc>()..add(VehicleFetchRequested()),
      child: Scaffold(
        // 🟢 START FIX: Added AppBar back
        appBar: AppBar(
          title: const Text('Live Vehicle Monitoring'),
          backgroundColor: kPrimaryColor,
          elevation: 0,
          actions: [
            BlocBuilder<VehicleBloc, VehicleState>(
              builder: (context, state) {
                if (state is VehicleLoading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                  );
                }
                return IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  tooltip: 'Refresh Data',
                  onPressed: () {
                    context.read<VehicleBloc>().add(VehicleFetchRequested());
                  },
                );
              },
            ),
          ],
        ),
        // 🟢 END FIX
        body: BlocBuilder<VehicleBloc, VehicleState>(
          builder: (context, state) {
            // Determine loaded state for map markers
            final loadedState = state is VehicleLoaded ? state : null;
            final vehicles = loadedState?.vehicles ?? [];

            // Filtering logic for markers
            final String filterStatusLowerCase =
                loadedState?.activeFilter == VehicleFilter.all
                    ? 'all'
                    : loadedState?.activeFilter.name.toLowerCase() ?? 'all';

            final visibleVehicles = vehicles.where((v) {
              final vehicleStatusLowerCase =
                  (v.status ?? 'No Data').toLowerCase();
              if (filterStatusLowerCase == 'all') return true;
              return vehicleStatusLowerCase == filterStatusLowerCase;
            }).toList();

            final visibleMarkers = visibleVehicles.map((vehicle) {
              final isSelected = loadedState?.selectedVehicle?.id == vehicle.id;
              final markerColor = _getStatusColor(vehicle.status);

              return Marker(
                width: 60.0,
                height: 60.0,
                point: geo.LatLng(vehicle.latitude, vehicle.longitude),
                child: VehicleMarkerWidget(
                  color: markerColor,
                  isSelected: isSelected,
                  vehicleId: vehicle.id,
                  onTap: (id) => context
                      .read<VehicleBloc>()
                      .add(VehicleSelectionUpdated(id)),
                ),
              );
            }).toList();

            // 🟢 START ADDITION: Calculate bottom sheet height for floating button
            final isVehicleSelected = loadedState?.selectedVehicle != null;
            final double bottomSheetHeight = isVehicleSelected ? 290 : 130;
            // 🟢 END ADDITION

            // --- Full Screen Map Layout ---
            return Stack(
              children: [
                // 1. Map Widget (Background)
                FlutterMap(
                  options: MapOptions(
                    initialCenter: _initialCenter,
                    initialZoom: 5.5,
                    onTap: (tapPosition, point) {
                      // Deselect vehicle when tapping map
                      context
                          .read<VehicleBloc>()
                          .add(const VehicleSelectionUpdated(null));
                      // 🟢 START ADDITION: Unfocus search bar
                      _searchFocusNode.unfocus();
                      // 🟢 END ADDITION
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.iwms_citizen_app',
                    ),
                    MarkerLayer(
                      markers: visibleMarkers,
                    ),
                  ],
                ),

                // 2. Show spinner on initial load
                if (state is VehicleInitial ||
                    (state is VehicleLoading && loadedState == null))
                  const Center(child: CircularProgressIndicator()),

                // 3. Show initial error
                if (state is VehicleError && loadedState == null)
                  Center(
                      child: Text('Error: ${state.message}',
                          style: const TextStyle(color: Colors.red))),

                // 4. Animated Bottom Sheet
                if (loadedState != null)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildAnimatedBottomSheet(
                        context, loadedState, bottomSheetHeight),
                  ),

                // 5. 🟢 START ADDITION: Floating Vehicle List Button
                if (loadedState != null)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    bottom: bottomSheetHeight + 16, // Floats above the sheet
                    right: 16,
                    child: FloatingActionButton(
                      mini: true,
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => _buildVehicleListModal(
                              context, loadedState.vehicles),
                        );
                      },
                      backgroundColor: Colors.white,
                      tooltip: 'Show Vehicle List',
                      child: const Icon(Icons.list_alt_outlined,
                          color: kPrimaryColor, size: 24),
                    ),
                  ),
                // 🟢 END ADDITION

                // 6. 🟢 START ADDITION: Search Bar UI
                _buildSearchUI(context),
                // 🟢 END ADDITION
              ],
            );
          },
        ),
      ),
    );
  }

  // --- 🟢 START ADDITION: Search UI Widget ---
  Widget _buildSearchUI(BuildContext context) {
    return Positioned(
      // Use SafeArea to position below the AppBar
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                child: Row(
                  children: [
                    // 🟢 START FIX: Changed to Menu icon to open drawer
                    // If you don't have a drawer, change this to Icons.arrow_back
                    // and Navigator.of(context).pop();
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: kTextColor),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    // 🟢 END FIX
                    // Text Field
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Search for your location...',
                          hintStyle: const TextStyle(color: kPlaceholderColor),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
                        ),
                      ),
                    ),
                    // 🟢 START FIX: Removed refresh button, it's in the AppBar
                    const SizedBox(width: 16), // Add padding
                    // 🟢 END FIX
                  ],
                ),
              ),
              // Suggestions List
              if (_isSearchFocused && _suggestions.isNotEmpty)
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(top: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: _suggestions.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.location_on_outlined,
                            color: kPlaceholderColor),
                        title: Text(_suggestions[index]),
                        onTap: () {
                          // TODO: Handle suggestion tap
                          _searchController.text = _suggestions[index];
                          _searchFocusNode.unfocus();
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  // 🟢 END ADDITION

  // --- NEW ANIMATED BOTTOM SHEET WIDGET ---
  Widget _buildAnimatedBottomSheet(
      BuildContext context, VehicleLoaded loadedState, double height) {
    // 🟢 START FIX: Pass height, remove list button
    final bool isVehicleSelected = loadedState.selectedVehicle != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      // Height changes based on selection
      height: height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 15, spreadRadius: 0)
        ],
      ),
      child: Column(
        children: [
          // 1. Grabber Handle
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: kBorderColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          // 2. Filter Chips Row
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
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
                // 🟢 START FIX: Removed list button
                // IconButton(...)
                // 🟢 END FIX
              ],
            ),
          ),
          const Divider(height: 1),
          // 3. Animated Details Section
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                // Animate content fading in/out
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: isVehicleSelected
                  // We use a Key to tell the AnimatedSwitcher that the *content* has changed
                  ? _buildDetailsCard(
                      context,
                      loadedState.selectedVehicle!,
                      key: ValueKey(loadedState.selectedVehicle!.id),
                    )
                  // Use an empty, keyed container for the "out" state
                  : Container(key: const ValueKey('empty')),
            ),
          ),
        ],
      ),
    );
    // 🟢 END FIX
  }
}

