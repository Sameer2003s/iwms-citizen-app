// lib/core/constants.dart

import 'package:flutter/material.dart';

// --- COLOR AND STYLE CONSTANTS ---
const Color kPrimaryColor = Color.fromARGB(255, 30, 139, 34); 
const Color kTextColor = Color(0xFF212121); // Dark Black for text
const Color kPlaceholderColor = Color(0xFF757575); // Grey for hints
const Color kContainerColor = Color(0xFFF5F5F5); // Light container background
const Color kBorderColor = Color(0xFFE0E0E0); // Light grey border

// --- REUSABLE HELPER (No longer needed when we use GoRouter, but useful for now) ---
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