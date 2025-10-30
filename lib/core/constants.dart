// lib/core/constants.dart

import 'package:flutter/material.dart';

// --- COLOR AND STYLE CONSTANTS ---
const Color kPrimaryColor = Color.fromARGB(255, 30, 139, 34); 
const Color kTextColor = Color(0xFF212121); // Dark Black for text
const Color kPlaceholderColor = Color(0xFF757575); // Grey for hints
const Color kContainerColor = Color(0xFFF5F5F5); // Light container background
const Color kBorderColor = Color(0xFFE0E0E0); // Light grey border

// --- NEW ENUM FOR FILTERING (Shared by Bloc and UI) ---
enum VehicleFilter { all, running, idle, parked, noData }

// --- REUSABLE HELPER (No longer needed when we use GoRouter) ---
// The previously defined `createSlideUpRoute` function has been removed
// as GoRouter handles transitions efficiently using the routes configuration.
