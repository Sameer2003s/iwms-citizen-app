import 'package:flutter/material.dart';
// Note: Relative imports now work since you moved this file into presentation/citizen/
import '../../../core/constants.dart'; 
import 'package:go_router/go_router.dart'; // Import GoRouter

// --- Reusable custom slide-up transition is now deprecated, use GoRouter navigation ---

class DriverDetailsScreen extends StatelessWidget {
  // Make parameters nullable to handle data passed via GoRouter state.extra
  final String? driverName;
  final String? vehicleNumber;

  const DriverDetailsScreen({
    super.key,
    this.driverName,
    this.vehicleNumber,
  });

  // Mock Data fallback (in case GoRouter fails to pass data)
  final String collectionTime = 'Tomorrow, 7:00 AM - 8:00 AM';
  final String collectionType = 'Wet Waste';

  @override
  Widget build(BuildContext context) {
    // Safely use fallback values
    final currentDriverName = driverName ?? 'Rajesh Kumar (N/A)';
    final currentVehicleNumber = vehicleNumber ?? 'TN 01 AB 1234 (N/A)';
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Your Next Collection',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 16),

            // Collection Summary Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.schedule, color: kPrimaryColor, size: 30),
                title: Text(
                  'Type: $collectionType',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Text('Time: $collectionTime'),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 30),

            // Driver Information Section
            const Text(
              'Assigned Crew Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextColor),
            ),
            const SizedBox(height: 15),

            // Driver Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Driver Photo Placeholder
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: kPrimaryColor,
                      child: Icon(Icons.person, size: 30, color: Colors.white),
                    ),
                    const SizedBox(width: 20),
                    // Driver Name & Vehicle
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentDriverName,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Driver',
                          style: TextStyle(color: kPlaceholderColor, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Vehicle No: $currentVehicleNumber',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Track Vehicle Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  // NEW GOROUTER NAVIGATION: Navigate to the MapScreen
                  context.pushNamed(
                    'citizenMap', // Use a named route for cleaner navigation
                    extra: {
                      'driverName': currentDriverName,
                      'vehicleNumber': currentVehicleNumber,
                    },
                  );
                },
                icon: const Icon(Icons.location_searching, color: Colors.white),
                label: const Text(
                  'Track Vehicle Live',
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
