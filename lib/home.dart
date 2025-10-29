import 'package:flutter/material.dart';
import '../main.dart'; // Accesses shared constants
import 'driver_details.dart'; // Required for navigation from the dashboard
import 'calender.dart'; // Required for navigation from the dashboard
import 'track_waste.dart'; // Required for navigation to the tracking page

// --- SHARED TRANSITION HELPER ---
Route _createSlideUpRoute(Widget targetPage) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 500),
    pageBuilder: (context, animation, secondaryAnimation) => targetPage,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.easeOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

// --- 1. HOME SCREEN (Onboarding Completion View) ---

class HomeScreen extends StatelessWidget {
  // Field to hold the user's name passed from registration
  final String userName; 

  const HomeScreen({
    super.key,
    required this.userName,
  });
  
  // Helper widget to display the logo
  Widget _imageAsset(String fileName, {required double width, required double height}) {
    // Assuming 'assets/images/logo.png' exists
    return Image.asset(
      'assets/images/$fileName',
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }

  void _navigateToDashboard(BuildContext context) {
    // Navigate to the actual dashboard and replace all routes below it
    Navigator.of(context).pushAndRemoveUntil(
      _createSlideUpRoute(CitizenDashboard(userName: userName)),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration Successful'),
        automaticallyImplyLeading: false, 
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- WELCOME MESSAGE ---
              Text(
                'Welcome, $userName!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: kPrimaryColor,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 40),
              
              // Display the actual logo
              _imageAsset('logo.png', width: 80, height: 80), 
              const SizedBox(height: 20),
              
              const Text(
                'Registration Complete!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kTextColor),
              ),
              const SizedBox(height: 10),
              Text(
                'Your unique QR code is now active for waste collection verification.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: kTextColor.withOpacity(0.7)),
              ),
              const SizedBox(height: 40),
              
              // Placeholder for future actions: View QR Code
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.qr_code_2, color: kPrimaryColor),
                  label: const Text('View My Collection QR Code'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: kPrimaryColor, width: 2),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
              const SizedBox(height: 10),

               // Placeholder for future actions: Raise Grievance
               SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.feedback_outlined, color: kPrimaryColor),
                  label: const Text('Raise a Grievance'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: kPrimaryColor, width: 2),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // --- NEW SKIP BUTTON ---
              TextButton(
                onPressed: () => _navigateToDashboard(context),
                child: Text(
                  'Skip to Dashboard',
                  style: TextStyle(
                    fontSize: 16,
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 2. CITIZEN DASHBOARD (The actual app home with drawer) ---

class CitizenDashboard extends StatelessWidget {
  final String userName;

  const CitizenDashboard({super.key, required this.userName});

  // --- QR MODAL METHOD ---
  void _showQrCodeModal(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8), // Dark background for visibility
      barrierDismissible: true, // Allows dismissal by tapping background
      builder: (BuildContext context) {
        return ScaleTransition( 
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(parent: ModalRoute.of(context)!.animation!, curve: Curves.easeOutCubic),
          ),
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            contentPadding: EdgeInsets.zero,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Text(
                        "Your Collection QR Code",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kTextColor),
                      ),
                      const SizedBox(height: 20),
                      // The QR code image itself (Assuming 'assets/images/qr.png' exists)
                      Image.asset(
                        'assets/images/qr.png', 
                        width: 250, 
                        height: 250, 
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                // Closing instruction at the bottom (optional)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(bottom: 12),
                  child: const Text(
                    "Tap outside to close",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: kPlaceholderColor),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- NOTIFICATION MODAL METHOD ---
  void _showNotificationModal(BuildContext context) {
    // Mock Notification Data
    final List<Map<String, String>> mockNotifications = [
      {'time': '5 min ago', 'message': 'The collector is 15 minutes away from your location. Please prepare your waste.'},
      {'time': '2 hours ago', 'message': 'Next collection schedule is tomorrow: Wet Waste.'},
      {'time': 'Yesterday', 'message': 'Thank you for segregating! Your service rating is 5 stars.'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows content to control height
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.5, // Take half the screen height
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notifications',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontSize: 24,
                      color: kTextColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: kTextColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: mockNotifications.length,
                  itemBuilder: (context, index) {
                    final notif = mockNotifications[index];
                    return ListTile(
                      leading: Icon(Icons.notifications_active, color: kPrimaryColor),
                      title: Text(notif['message']!, style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text(notif['time']!, style: const TextStyle(color: kPlaceholderColor, fontSize: 12)),
                      trailing: Icon(Icons.arrow_forward_ios, size: 14, color: kPlaceholderColor),
                      onTap: () {
                        // TODO: Implement navigation to relevant screen (e.g., Map for the "15 minutes away" alert)
                        Navigator.pop(context);
                      },
                      contentPadding: EdgeInsets.zero,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  // Helper function to build professional-looking dashboard cards
  Widget _buildDashboardCard(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: kPrimaryColor),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600, color: kTextColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper function for small stat cards
  Widget _buildStatCard(String title, String value, Color defaultColor) {
    // 1. Logic to determine status color based on weight for Dry/Wet/Mixed waste
    Color contentColor = defaultColor;
    Color boxColor = defaultColor.withOpacity(0.1);

    // Only apply weight logic to waste types
    if (title.contains('Waste')) {
      // Safely parse the value string (e.g., '12.5 kg' -> 12.5)
      double? weight;
      try {
        String numericPart = value.split(' ')[0];
        weight = double.tryParse(numericPart);
      } catch (e) {
        weight = null;
      }

      if (weight != null) {
        if (weight <= 10.0) {
          // Less than or equal to 10 kg -> MILD RARE GREEN
          contentColor = Colors.green.shade700; 
          boxColor = Colors.green.shade100;
        } else if (weight >= 20.0) {
          // More than or equal to 20 kg -> MILD RARE RED
          contentColor = Colors.red.shade700; 
          boxColor = Colors.red.shade100;
        } else {
          // Otherwise (10.0 < weight < 20.0) -> MILD RARE BLUE
          contentColor = Colors.blue.shade700; 
          boxColor = Colors.blue.shade100;
        }
      }
    } else {
      // For non-weight stats (Total Collections, Compliance Rating), set background to White and text to kPrimaryColor
      boxColor = Colors.white; 
      contentColor = kPrimaryColor;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: boxColor, // Conditional background color
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 12, color: contentColor, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: contentColor)), // Conditional content color
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Waste Manager'),
        backgroundColor: kPrimaryColor,
        elevation: 0, // Make the app bar flat
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () => _showNotificationModal(context), // Link to the new modal
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: kPrimaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.account_circle, color: Colors.white, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    'Hello, $userName!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_2, color: kPrimaryColor),
              title: const Text('My Collection QR Code'),
              onTap: () {
                Navigator.pop(context); 
                _showQrCodeModal(context); // Show modal from the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: kPrimaryColor),
              title: const Text('Collection History & Weighment'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to the Calendar/History screen
                Navigator.of(context).push(_createSlideUpRoute(const CalendarScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on_outlined, color: kPrimaryColor),
              title: const Text('Track My Waste'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to the Track Waste page
                Navigator.of(context).push(_createSlideUpRoute(const TrackWasteScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.star_rate_outlined, color: kPrimaryColor),
              title: const Text('Rate Last Collection'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement navigation to Rating screen (Feedback Collection)
              },
            ),
            ListTile(
              leading: const Icon(Icons.payments_outlined, color: kPrimaryColor),
              title: const Text('View Charges & Fines'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement navigation to Fines/Charges screen
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.feedback_outlined, color: Colors.orange),
              title: const Text('Raise Grievance (Help Desk)'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement navigation to Grievance Redressal
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement actual logout and navigate back to LoginScreen
              },
            ),
          ],
        ),
      ),
      // --- DASHBOARD BODY (White Background) ---
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Header
            Text(
              'Your Dashboard',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontSize: 28, 
                fontWeight: FontWeight.w800, 
                color: kTextColor
              ),
            ),
            const SizedBox(height: 20),

            // 1. Next Collection Card (NOW TAPABLE)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell( // <-- InkWell makes the card tappable
                onTap: () {
                  Navigator.of(context).push(_createSlideUpRoute(const DriverDetailsScreen()));
                },
                child: ListTile(
                  leading: const Icon(Icons.schedule, size: 40, color: kPrimaryColor),
                  title: Text('Next Collection: Wet Waste', style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Tomorrow, 7:00 AM - 8:00 AM', style: TextStyle(color: kPlaceholderColor)),
                  trailing: Chip(
                    label: const Text('Segregate!', style: TextStyle(color: Colors.white)),
                    backgroundColor: kPrimaryColor,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Quick Actions Grid
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextColor),
            ),
            const SizedBox(height: 10),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: <Widget>[
                // Card 1: QR Code Access (Linked to new modal)
                _buildDashboardCard(
                  context,
                  icon: Icons.qr_code_2,
                  title: 'My QR Code',
                  onTap: () {
                    _showQrCodeModal(context); // Calls the smooth QR modal
                  },
                ),
                // Card 2: Collection History
                _buildDashboardCard(
                  context,
                  icon: Icons.history,
                  title: 'Collection History',
                  onTap: () {
                    // Navigate to Calendar/History screen
                    Navigator.of(context).push(_createSlideUpRoute(const CalendarScreen()));
                  },
                ),
                // Card 3: Raise Grievance
                _buildDashboardCard(
                  context,
                  icon: Icons.feedback_outlined,
                  title: 'Raise Grievance',
                  onTap: () {
                    // TODO: Navigate to Grievance Redressal
                  },
                ),
                // Card 4: Rate Service
                _buildDashboardCard(
                  context,
                  icon: Icons.star_rate_outlined,
                  title: 'Rate Collector',
                  onTap: () {
                    // TODO: Navigate to Rating screen
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),

            // 3. Stats Summary (Header)
            const Text(
              'Monthly Stats',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextColor),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(child: _buildStatCard('Dry Waste', '12.5 kg', Colors.blue)), 
                const SizedBox(width: 10),
                Expanded(child: _buildStatCard('Wet Waste', '25.0 kg', Colors.green)), 
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildStatCard('Total Collections', '8 / month', Colors.deepOrange)), 
                const SizedBox(width: 10),
                Expanded(child: _buildStatCard('Compliance Rating', '4.8 Stars', Colors.purple)), 
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}