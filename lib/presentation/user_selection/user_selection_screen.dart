// lib/presentation/user_selection/user_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iwms_citizen_app/router/app_router.dart'; // We will create this

class UserSelectionScreen extends StatelessWidget {
  const UserSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Theme.of(context).primaryColor, const Color.fromARGB(255, 0, 0, 0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png', // Your main app logo
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 24),
            Text(
              "Welcome to IWMS",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "Who are you?",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
            ),
            const SizedBox(height: 48),

            // --- User Roles ---
            _UserRoleCard(
              icon: Icons.person,
              title: "Citizen",
              onTap: () {
                // Navigate to Citizen Login
                context.push(AppRoutePaths.citizenLogin);
              },
            ),
            _UserRoleCard(
              icon: Icons.local_shipping,
              title: "Driver",
              onTap: () {
                // Navigate to Driver Login
                context.push(AppRoutePaths.driverLogin);
              },
            ),
            _UserRoleCard(
              icon: Icons.build,
              title: "Operator",
              onTap: () {
                // Placeholder
                _showComingSoon(context);
              },
            ),
            _UserRoleCard(
              icon: Icons.admin_panel_settings,
              title: "Admin",
              onTap: () {
                // Placeholder
                _showComingSoon(context);
              },
            ),
             _UserRoleCard(
              icon: Icons.security,
              title: "Super Admin",
              onTap: () {
                // Placeholder
                 _showComingSoon(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This module is coming soon!'),
        backgroundColor: Colors.grey,
      ),
    );
  }
}

class _UserRoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _UserRoleCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor, size: 28),
              const SizedBox(width: 24),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}