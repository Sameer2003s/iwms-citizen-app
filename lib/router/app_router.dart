// lib/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iwms_citizen_app/logic/auth/auth_bloc.dart';
import 'package:iwms_citizen_app/logic/auth/auth_state.dart';
import 'package:iwms_citizen_app/router/route_observer.dart';

// --- Import all your screens ---
// Splash & User Selection
import 'package:iwms_citizen_app/modules/module1_citizen/citizen/splashscreen.dart';
import 'package:iwms_citizen_app/presentation/user_selection/user_selection_screen.dart';
// Module 1: Citizen
import 'package:iwms_citizen_app/modules/module1_citizen/citizen/login.dart';
import 'package:iwms_citizen_app/modules/module1_citizen/citizen/register.dart';
import 'package:iwms_citizen_app/modules/module1_citizen/citizen/home.dart';
import 'package:iwms_citizen_app/modules/module1_citizen/citizen/calender.dart';
import 'package:iwms_citizen_app/modules/module1_citizen/citizen/track_waste.dart';
import 'package:iwms_citizen_app/modules/module1_citizen/citizen/driver_details.dart';
import 'package:iwms_citizen_app/modules/module1_citizen/citizen/map.dart';
// Module 2: Driver
import 'package:iwms_citizen_app/modules/module2_driver/presentation/driver_login_screen.dart';
import 'package:iwms_citizen_app/modules/module2_driver/presentation/driver_home_screen.dart';
import 'package:iwms_citizen_app/modules/module2_driver/presentation/driver_qr_scan_screen.dart';
import 'package:iwms_citizen_app/modules/module2_driver/presentation/driver_data_screen.dart';

// --- Define static route paths ---
class AppRoutePaths {
  static const String splash = '/';
  static const String selectUser = '/select-user';

  static const String citizenLogin = '/citizen/login';
  static const String citizenRegister = '/citizen/register';
  static const String citizenHome = '/citizen/home';
  static const String citizenWelcome = '/citizen/welcome';

  static const String citizenHistory = '/citizen/history';
  static const String citizenTrack = '/citizen/track';
  static const String citizenDriverDetails = '/citizen/driver-details';
  static const String citizenMap = '/citizen/map';

  static const String driverLogin = '/driver/login';
  static const String driverHome = '/driver/home';
  static const String driverQrScan = '/driver/qrscan';
  static const String driverData = '/driver/data';
}

// --- The App Router ---
class AppRouter {
  final AuthBloc authBloc;
  final RouteObserver<PageRoute> routeObserver;
  late final GoRouter router; // <-- Keep this as late final

  AppRouter({
    required this.authBloc,
    required this.routeObserver,
    required Listenable refreshListenable,
  }) {
    // --- FIX: Initialize the router HERE, inside the constructor ---
    router = GoRouter(
      routes: _routes,
      initialLocation: AppRoutePaths.splash,
      debugLogDiagnostics: true,
      redirect: _redirect,
      refreshListenable: refreshListenable,
      observers: [routeObserver],
    );
    // --- END FIX ---
  }

  // Define all routes
  final List<RouteBase> _routes = [
    GoRoute(
      path: AppRoutePaths.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.selectUser,
      builder: (context, state) => const UserSelectionScreen(),
    ),

    // --- Module 1: Citizen Routes ---
    GoRoute(
      path: AppRoutePaths.citizenLogin,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.citizenRegister,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.citizenWelcome,
      builder: (context, state) {
        final authState = authBloc.state;
        // Use a fallback in case userName is null
        String userName = (authState is AuthStateAuthenticated)
            ? authState.userName ?? "Citizen"
            : "Citizen";
        return HomeScreen(userName: userName);
      },
    ),
    GoRoute(
      path: AppRoutePaths.citizenHome,
      builder: (context, state) {
        final authState = authBloc.state;
        String userName = (authState is AuthStateAuthenticated)
            ? authState.userName ?? "Citizen"
            : "Citizen";
        return CitizenDashboard(userName: userName);
      },
    ),
    GoRoute(
      path: AppRoutePaths.citizenHistory,
      builder: (context, state) => const CalendarScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.citizenTrack,
      builder: (context, state) => const TrackWasteScreen(),
    ),
    GoRoute(
        path: AppRoutePaths.citizenDriverDetails,
        builder: (context, state) {
          return const DriverDetailsScreen(
            driverName: 'Rajesh Kumar',
            vehicleNumber: 'TN 01 AB 1234',
          );
        }),
    GoRoute(
      name: 'citizenMap',
      path: AppRoutePaths.citizenMap,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        return MapScreen(
          driverName: data['driverName'],
          vehicleNumber: data['vehicleNumber'],
        );
      },
    ),

    // --- Module 2: Driver Routes ---
    GoRoute(
      path: AppRoutePaths.driverLogin,
      builder: (context, state) => const DriverLoginScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.driverHome,
      builder: (context, state) => const DriverHomeScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.driverQrScan,
      builder: (context, state) => const DriverQrScanScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.driverData,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        return DriverDataScreen(
          customerId: data['customerId'] ?? 'Error',
          customerName: data['customerName'] ?? 'Error',
          contactNo: data['contactNo'] ?? 'Error',
          latitude: data['latitude'] ?? '0.0',
          longitude: data['longitude'] ?? '0.0',
        );
      },
    ),
  ];

  // --- Redirect Logic (with Role-Based Routing) ---
  String? _redirect(BuildContext context, GoRouterState state) {
    // Use the authBloc instance directly
    final authState = authBloc.state;
    final location = state.matchedLocation;
    final onSplash = location == AppRoutePaths.splash;

    // 1. While app is initializing, stay on splash
    if (authState is AuthStateInitial) {
      return null;
    }

    final isLoggingIn = (location == AppRoutePaths.citizenLogin ||
        location == AppRoutePaths.citizenRegister ||
        location == AppRoutePaths.driverLogin ||
        location == AppRoutePaths.selectUser);

    // 2. If user is authenticated
    if (authState is AuthStateAuthenticated) {
      // If they are on a login page or splash, redirect them to their home page
      if (isLoggingIn || onSplash) {
        if (authState.role == UserRole.driver) {
          return AppRoutePaths.driverHome;
        }
        if (authState.role == UserRole.citizen) {
          return AppRoutePaths.citizenHome;
        }
      }
      // Otherwise, let them stay where they are
      return null;
    }

    // 3. If user is UNauthenticated
    if (authState is AuthStateUnauthenticated || authState is AuthStateFailure) {
      // If they are on the splash screen, redirect to user selection
      if (onSplash) {
        return AppRoutePaths.selectUser;
      }
      // If they are already on a login page, let them stay
      if (isLoggingIn) {
        return null;
      }
      // If they are on any other secure page, redirect them
      return AppRoutePaths.selectUser;
    }

    // Default case
    return null;
  }
}

