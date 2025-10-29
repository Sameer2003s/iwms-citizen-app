import 'package:flutter/material.dart';
import '../main.dart'; // Accesses shared constants

class MapScreen extends StatelessWidget {
  final String driverName;
  final String vehicleNumber;

  const MapScreen({
    super.key,
    required this.driverName,
    required this.vehicleNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Vehicle Tracking'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on_outlined, size: 80, color: kPrimaryColor),
              const SizedBox(height: 20),
              const Text(
                'Live Map View Placeholder',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kTextColor),
              ),
              const SizedBox(height: 10),
              Text(
                'Tracking Driver: $driverName\nVehicle: $vehicleNumber',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: kPlaceholderColor),
              ),
              const SizedBox(height: 30),
              // Hint for future development
              const Text(
                'This page will integrate GPS data to show the vehicle\'s real-time location and estimated time of arrival.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
