import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Layered imports
import '../../../core/constants.dart'; 
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_event.dart';
import '../../../router/app_router.dart';

// Import local files (now siblings) for the actual pages, though GoRouter typically uses paths

// --- 1. HOME SCREEN (Onboarding Completion View) ---

class HomeScreen extends StatelessWidget {
  final String userName; 

  const HomeScreen({
    super.key,
    required this.userName,
  });
  
  // Helper widget to display the logo
  Widget _imageAsset(String fileName, {required double width, required double height}) {
    return Image.asset(
      'assets/images/$fileName',
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }

  void _navigateToDashboard(BuildContext context) {
    // GoRouter handles the navigation and stack manipulation automatically
    context.go(AppRoutePaths.citizenHome);
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
              
              // --- NAVIGATION BUTTON ---
              TextButton(
        onPressed: () { // <-- THIS IS THE FIX
         context.go(AppRoutePaths.citizenHome);
        },
        
        child: const Text(
         'Skip to Dashboard',
         // ... style
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

  void _showQrCodeModal(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8), 
      barrierDismissible: true, 
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

  void _showNotificationModal(BuildContext context) {
    final List<Map<String, String>> mockNotifications = [
      {'time': '5 min ago', 'message': 'The collector is 15 minutes away from your location. Please prepare your waste.'},
      {'time': '2 hours ago', 'message': 'Next collection schedule is tomorrow: Wet Waste.'},
      {'time': 'Yesterday', 'message': 'Thank you for segregating! Your service rating is 5 stars.'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.5, 
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
                      leading: const Icon(Icons.notifications_active, color: kPrimaryColor),
                      title: Text(notif['message']!, style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text(notif['time']!, style: const TextStyle(color: kPlaceholderColor, fontSize: 12)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: kPlaceholderColor),
                      onTap: () {
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
    Color contentColor = defaultColor;
    Color boxColor = defaultColor.withOpacity(0.1);

    if (title.contains('Waste')) {
      double? weight;
      try {
        String numericPart = value.split(' ')[0];
        weight = double.tryParse(numericPart);
      } catch (e) {
        weight = null;
      }

      if (weight != null) {
        if (weight <= 10.0) {
          contentColor = Colors.green.shade700; 
          boxColor = Colors.green.shade100;
        } else if (weight >= 20.0) {
          contentColor = Colors.red.shade700; 
          boxColor = Colors.red.shade100;
        } else {
          contentColor = Colors.blue.shade700; 
          boxColor = Colors.blue.shade100;
        }
      }
    } else {
      boxColor = Colors.white; 
      contentColor = kPrimaryColor;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: boxColor, 
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 12, color: contentColor, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: contentColor)),
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
        elevation: 0, 
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () => _showNotificationModal(context), 
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
                _showQrCodeModal(context); 
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: kPrimaryColor),
              title: const Text('Collection History & Weighment'),
              onTap: () {
                Navigator.pop(context);
                // GoRouter Navigation
                context.go(AppRoutePaths.citizenHistory);
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on_outlined, color: kPrimaryColor),
              title: const Text('Track My Waste'),
              onTap: () {
                Navigator.pop(context);
                // GoRouter Navigation
                context.go(AppRoutePaths.citizenTrack);
              },
            ),
            ListTile(
              leading: const Icon(Icons.star_rate_outlined, color: kPrimaryColor),
              title: const Text('Rate Last Collection'),
              onTap: () {
                Navigator.pop(context);
                // TODO: GoRouter Navigation to Rating screen 
              },
            ),
            ListTile(
              leading: const Icon(Icons.payments_outlined, color: kPrimaryColor),
              title: const Text('View Charges & Fines'),
              onTap: () {
                Navigator.pop(context);
                // TODO: GoRouter Navigation to Fines/Charges screen
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.feedback_outlined, color: Colors.orange),
              title: const Text('Raise Grievance (Help Desk)'),
              onTap: () {
                Navigator.pop(context);
                // TODO: GoRouter Navigation to Grievance Redressal
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                // **BLOC INTEGRATION: Dispatch Logout Event**
                context.read<AuthBloc>().add(AuthLogoutRequested());
                // GoRouter's redirect logic will handle the navigation back to /login
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
              child: InkWell( 
                onTap: () {
                  // GoRouter Navigation to Driver Details
                  context.go(AppRoutePaths.citizenDriverDetails);
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
                // Card 1: QR Code Access
                _buildDashboardCard(
                  context,
                  icon: Icons.qr_code_2,
                  title: 'My QR Code',
                  onTap: () {
                    _showQrCodeModal(context); 
                  },
                ),
                // Card 2: Collection History
                _buildDashboardCard(
                  context,
                  icon: Icons.history,
                  title: 'Collection History',
                  onTap: () {
                    // GoRouter Navigation
                    context.go(AppRoutePaths.citizenHistory);
                  },
                ),
                // Card 3: Raise Grievance
                _buildDashboardCard(
                  context,
                  icon: Icons.feedback_outlined,
                  title: 'Raise Grievance',
                  onTap: () {
                    // TODO: GoRouter Navigation to Grievance Redressal
                  },
                ),
                // Card 4: Rate Service
                _buildDashboardCard(
                  context,
                  icon: Icons.star_rate_outlined,
                  title: 'Rate Collector',
                  onTap: () {
                    // TODO: GoRouter Navigation to Rating screen
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
