import 'package:flutter/material.dart';
import 'package:user_login/map.dart'; // Import the MapScreen
import '../main.dart'; // Accesses shared constants

// --- Reusable custom slide-up transition function (for MapScreen) ---
Route _createSlideUpRoute(Widget targetPage) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 500),
    pageBuilder: (context, animation, secondaryAnimation) => targetPage,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.easeOutCubic;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

class DriverDetailsScreen extends StatelessWidget {
  // Mock Data (In a real app, this would be passed from an API call)
  final String driverName = 'Rajesh Kumar';
  final String vehicleNumber = 'TN 01 AB 1234';
  final String collectionTime = 'Tomorrow, 7:00 AM - 8:00 AM';
  final String collectionType = 'Wet Waste';

  const DriverDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                          driverName,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Driver',
                          style: TextStyle(color: kPlaceholderColor, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Vehicle No: $vehicleNumber',
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
                  // Navigate to the MapScreen with the custom smooth transition
                  Navigator.of(context).push(
                    _createSlideUpRoute(MapScreen(
                      driverName: driverName,
                      vehicleNumber: vehicleNumber,
                    )),
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
