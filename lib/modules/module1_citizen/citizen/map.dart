import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants.dart';

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
  // --- FIX: Removed 'const' as LatLng constructor is not const ---
  final LatLng _driverLocation = LatLng(11.3410, 77.7172); // Erode, Tamil Nadu
  final LatLng _userLocation = LatLng(11.3450, 77.7190); // A nearby location

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Vehicle Tracking'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            // --- FIX: Use MapOptions for flutter_map: ^4.0.0 ---
            options: MapOptions(
              center: _driverLocation,
              zoom: 15.0,
            ),
            // --- END FIX ---
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  // Driver Marker
                  // --- FIX: Use Marker() with a builder ---
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: _driverLocation,
                    builder: (ctx) => const Column(
                      children: [
                        Icon(
                          Icons.local_shipping,
                          color: kPrimaryColor,
                          size: 35,
                        ),
                        Text(
                          'Driver',
                          style: TextStyle(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                  // User (Citizen) Marker
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: _userLocation,
                    builder: (ctx) => const Column(
                      children: [
                        Icon(
                          Icons.person_pin_circle,
                          color: Colors.green,
                          size: 35,
                        ),
                        Text(
                          'You',
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                  // --- END FIX ---
                ],
              ),
            ],
          ),
          // Information Panel
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.driverName ?? 'Rajesh Kumar',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: kTextColor),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vehicle: ${widget.vehicleNumber ?? 'TN 01 AB 1234'}',
                      style: const TextStyle(fontSize: 16, color: kTextColor),
                    ),
                    const Divider(height: 24),
                    const Text(
                      'Arriving in approx. 5 minutes',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: kPrimaryColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

