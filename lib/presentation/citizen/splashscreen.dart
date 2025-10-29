import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

// Layered imports
import '../../core/constants.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_event.dart'; 
import '../../logic/auth/auth_state.dart'; 

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

  final Duration _minDisplayDuration = const Duration(seconds: 2, milliseconds: 500); 

  Widget _imageAsset(String fileName, {required double width, required double height}) {
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
    
    final AuthBloc authBloc = context.read<AuthBloc>();

    // 1. Start the minimum time future
    final minTimeFuture = Future.delayed(_minDisplayDuration);

    // 2. Wait for BOTH the minimum time AND the auth bloc's internal initialization to complete
    // CRITICAL FIX: Using the public 'initialization' getter
    Future.wait([authBloc.initialization, minTimeFuture]).then((_) {
      // Once both are done, dispatch the final AuthStatusChecked event
      authBloc.add(AuthStatusChecked());
    });
    
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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-cache all important images for fast loading
    precacheImage(const AssetImage('assets/images/logo.png'), context);
    precacheImage(const AssetImage('assets/images/zigma.png'), context);
    precacheImage(const AssetImage('assets/images/blueplanet.png'), context);
  }
  
  @override
  void dispose() {
    _bottomAnimationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Spacer(flex: 2),
            
            // --- MAIN LOGO AND TEXT SECTION ---
            AnimatedOpacity(
              opacity: _opacity, 
              duration: const Duration(seconds: 3), 
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _imageAsset('logo.png', width: 120, height: 120),
                  const SizedBox(height: 20), 
                  
                  const Text(
                    "Integrated Waste",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.w800, 
                      color: kTextColor, 
                    ),
                  ),
                  
                  const Text(
                    "Management Suite",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.w800,
                      color: kTextColor,
                    ),
                  ),
                ],
              ),
            ),
            
            const Spacer(flex: 3),
            
            // --- BOTTOM SECTION ANIMATION ---
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
