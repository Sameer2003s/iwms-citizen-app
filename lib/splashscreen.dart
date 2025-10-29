import 'package:flutter/material.dart';
import 'dart:async';
import 'login.dart'; // Navigate to LoginScreen next
import '../main.dart'; // Accesses shared constants, createSlideUpRoute

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  double _opacity = 0.0; 
  late final AnimationController _bottomAnimationController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _scaleAnimation;
  final Duration _popDuration = const Duration(milliseconds: 700);

  Widget _imageAsset(String fileName, {required double width, required double height}) {
    // Placeholder image asset function for zigma and blueplanet
    return Image.asset(
      'assets/images/$fileName',
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }

  @override
  void initState() {
    super.initState();
    
    _bottomAnimationController = AnimationController(
      vsync: this,
      duration: _popDuration,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2), 
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _bottomAnimationController,
      curve: Curves.easeOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8, 
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bottomAnimationController,
      curve: Curves.easeOut,
    ));
    
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0; 
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        _bottomAnimationController.forward();
      }
    });

    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        // Use the centralized helper for smooth navigation
        Navigator.of(context).pushReplacement(
          createSlideUpRoute(const LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _bottomAnimationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // Accessing kPrimaryColor indirectly via context for the text color if needed, 
    // but preserving the original black for maximum contrast on white background.
    final accentColor = kTextColor; 

    return Scaffold(
      backgroundColor: Colors.white, 
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Spacer(flex: 2),
            
            // --- MAIN LOGO AND TEXT SECTION (Fades in over 3s) ---
            AnimatedOpacity(
              opacity: _opacity, 
              duration: const Duration(seconds: 3), 
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/logo.png', 
                    width: 120, 
                    height: 120, 
                  ),
                  const SizedBox(height: 20), 
                  
                  Text(
                    "Integrated Waste",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.w800, 
                      color: accentColor, 
                    ),
                  ),
                  
                  Text(
                    "Management Suite",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.w800,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
            ),
            
            const Spacer(flex: 3),
            
            // --- BOTTOM SECTION ANIMATION (Fades/Slides/Scales in over 0.7s) ---
            FadeTransition( 
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(_bottomAnimationController),
              child: SlideTransition(
                position: _slideAnimation, 
                child: ScaleTransition(
                  scale: _scaleAnimation, 
                  child: Column(
                    children: [
                      const SizedBox(height: 60), 
                      const Text(
                        "Powered by",
                        style: TextStyle(
                          fontSize: 14, 
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          _imageAsset('zigma.png', width: 120, height: 60),
                          const SizedBox(width: 20),
                          _imageAsset('blueplanet.png', width: 150, height: 60),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}