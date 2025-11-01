// lib/modules/module2_driver/presentation/driver_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // <-- ADD THIS
import 'package:go_router/go_router.dart';
import 'package:iwms_citizen_app/core/theme/app_colors.dart';
import 'package:iwms_citizen_app/logic/auth/auth_bloc.dart'; // <-- ADD THIS
import 'package:iwms_citizen_app/logic/auth/auth_event.dart'; // <-- ADD THIS
import 'package:iwms_citizen_app/logic/auth/auth_state.dart'; // <-- ADD THIS
import 'package:iwms_citizen_app/router/app_router.dart'; 

class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- FIX: Read user data from the AuthBloc state ---
    final authState = context.watch<AuthBloc>().state;
    String staffName = "Driver";
    if (authState is AuthStateAuthenticated) {
      staffName = authState.userName ?? "Driver";
    }
    // We can't get siteName from this state, so we'll omit it for now
    // final String siteName = loginData?['siteName'] ?? 'Your Site';
    // --- END FIX ---

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Driver Dashboard"),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // --- FIX: Dispatch logout event ---
              context.read<AuthBloc>().add(AuthLogoutRequested());
              // The router will automatically handle the redirect.
              // --- END FIX ---
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Header Card ---
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome, $staffName", // <-- This will now show the correct name
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.grey.shade600, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          "Site: (Site Name)", // <-- Hardcoded for now
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- Main Action: Scan QR (This is from d2d_waste_collection) ---
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    // This links to the QR Scan Screen
                    context.push(AppRoutePaths.driverQrScan);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_scanner,
                        size: 150,
                        color: AppColors.primaryBlue,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Scan Household QR",
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Tap here to start scanning",
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // --- Other Actions ---
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.map_outlined),
                label: const Text("View Route"),
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success, // Use theme color
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}