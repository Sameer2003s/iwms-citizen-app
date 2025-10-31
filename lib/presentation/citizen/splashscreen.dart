import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iwms_citizen_app/logic/auth/auth_bloc.dart';
import 'package:iwms_citizen_app/logic/auth/auth_event.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();

    // --- AUTH LOGIC ---
    // Wait for the BLoC's internal init (e.g., SharedPreferences)
    // The GoRouter redirect will handle navigation once the state changes.
    context.read<AuthBloc>().initialization.then((_) {
      // Once init is done, check the auth status
      context.read<AuthBloc>().add(AuthStatusChecked());
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use the theme from main.dart
    return Scaffold(
      backgroundColor: Colors.white, 
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png', // From your repo
                    width: 150,
                    height: 150,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Integrated Waste Management Suite",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF0D47A1), // primaryBlue
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          _buildPoweredBySection(),
        ],
      ),
    );
  }

  Widget _buildPoweredBySection() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Text(
            "powered by",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/zigma.png', // From your repo
                height: 30,
              ),
              const SizedBox(width: 24),
              Image.asset(
                'assets/images/blueplanet.png', // From your repo
                height: 30,
              ),
            ],
          ),
        ],
      ),
    );
  }
}