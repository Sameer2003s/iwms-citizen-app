import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'splashscreen.dart'; // Import the new SplashScreen file

// --- COLOR AND STYLE CONSTANTS (Vibrant Green, Black, White theme) ---
// PRIMARY COLOR: Color.fromARGB(255, 30, 139, 34) (Darker Green)
const Color kPrimaryColor = Color.fromARGB(255, 30, 139, 34); 
const Color kTextColor = Color(0xFF212121); // Dark Black for text
const Color kPlaceholderColor = Color(0xFF757575); // Grey for hints
const Color kContainerColor = Color(0xFFF5F5F5); // Light container background
const Color kBorderColor = Color(0xFFE0E0E0); // Light grey border
const Color kAccentBlue = Color(0xFF1E88E5); // Used in tracking/other actions

void main() {
  runApp(
    DevicePreview(
      builder: (context) => const MyApp(), 
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Device Preview Configuration
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      useInheritedMediaQuery: true, 
      
      title: 'IWMS Citizen App',
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        // Define a color scheme primarily to influence widgets like the date picker
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryColor,
          primary: kPrimaryColor,
          secondary: kPrimaryColor,
        ),
        // Set Inter/Sans Serif style properties
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 16.0),
          labelLarge: TextStyle(fontWeight: FontWeight.bold),
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: kPrimaryColor, 
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: kContainerColor,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: kBorderColor, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: kBorderColor, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: kPrimaryColor, width: 2), 
          ),
        )
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(), // Starts with the Splash Screen
    );
  }
}

// 1. Reusable custom slide-up transition function (for seamless navigation)
Route createSlideUpRoute(Widget targetPage) {
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