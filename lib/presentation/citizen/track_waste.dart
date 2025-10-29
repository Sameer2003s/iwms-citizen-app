import 'package:flutter/material.dart';
// Layered imports
import '../../core/constants.dart'; 

class TrackWasteScreen extends StatelessWidget {
  const TrackWasteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track My Waste'),
        backgroundColor: kPrimaryColor,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.pin_drop_outlined, size: 80, color: kPrimaryColor),
              const SizedBox(height: 20),
              const Text(
                'Real-Time Tracking (IWMS)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kTextColor),
              ),
              const SizedBox(height: 10),
              Text(
                'This screen will display the live location of the assigned collection vehicle using GPS tracking (D2D Collection & Logistics Management).',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: kPlaceholderColor),
              ),
              const SizedBox(height: 30),
              // Placeholder for a map view
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: kContainerColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBorderColor),
                ),
                child: const Center(
                  child: Text(
                    'Loading Map...',
                    style: TextStyle(color: kPlaceholderColor),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Updates will include estimated time of arrival (ETA) and route adherence alerts.',
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
