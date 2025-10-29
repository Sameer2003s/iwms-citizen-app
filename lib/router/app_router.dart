import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async'; // <<< FIXED: Added dart:async for StreamSubscription

// New layered imports
import '../core/di.dart';
import '../logic/auth/auth_bloc.dart';
import '../logic/auth/auth_state.dart';

// Import all relocated Presentation layer files 
import '../presentation/citizen/splashscreen.dart'; 
import '../presentation/citizen/login.dart';
import '../presentation/citizen/home.dart';
import '../presentation/citizen/register.dart';
import '../presentation/citizen/calender.dart';
import '../presentation/citizen/driver_details.dart';
import '../presentation/citizen/track_waste.dart';
import '../presentation/citizen/map.dart'; // <<< ADDED MAP IMPORT


// --- Named Routes (The map addresses) ---
class AppRoutePaths {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';

  // Citizen Paths
  static const citizenDashboard = '/citizen/dashboard';
  static const citizenHistory = '/citizen/history';
  static const citizenTrack = '/citizen/track';
  static const citizenDriverDetails = '/citizen/driver-details';
  static const citizenMap = '/citizen/map'; // New path for the map screen
}


class AppRouter {
  final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
  final AuthBloc authBloc = getIt<AuthBloc>(); 

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutePaths.splash,
    navigatorKey: rootNavigatorKey,

    // 2. REDIRECTION LOGIC 
    redirect: (BuildContext context, GoRouterState state) {
      final authState = authBloc.state; 

      final isLoggingIn = state.uri.toString() == AppRoutePaths.login;
      final isRegistering = state.uri.toString() == AppRoutePaths.register;
      final isSplash = state.uri.toString() == AppRoutePaths.splash;

      // --- LOGIC RULES ---
      if (authState.role == UserRole.unknown) {
        return isSplash ? null : AppRoutePaths.splash;
      }

      if (authState.role == UserRole.unauthenticated) {
        return isLoggingIn || isRegistering ? null : AppRoutePaths.login;
      }

      if (authState.role == UserRole.citizen) {
        if (isLoggingIn || isSplash || isRegistering) {
            return AppRoutePaths.citizenDashboard;
        }
        return null;
      }
      
      return null;
    },

    // 3. LISTEN TO STATE
    refreshListenable: GoRouterRefreshStream(authBloc.stream),

    // 4. ROUTE DEFINITIONS 
    routes: [
      // Splash Screen
      GoRoute(
        path: AppRoutePaths.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Authentication Routes
      GoRoute(
        path: AppRoutePaths.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutePaths.register,
        builder: (context, state) => const RegisterScreen(),
      ),

      // Citizen Module Routes
      GoRoute(
        path: AppRoutePaths.citizenDashboard,
        builder: (context, state) => CitizenDashboard(
          userName: authBloc.state.userName ?? 'Citizen', 
        ),
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
            return DriverDetailsScreen(
                // Data is not required for the driver details screen based on your setup
                driverName: 'Rajesh Kumar', 
                vehicleNumber: 'TN 01 AB 1234', 
            );
        },
      ),
      // New Map Route to receive data via state.extra
      GoRoute(
        name: 'citizenMap',
        path: AppRoutePaths.citizenMap,
        builder: (context, state) {
            // Retrieve arguments passed via context.pushNamed(extra: ...)
            final args = state.extra as Map<String, dynamic>? ?? {};
            return MapScreen(
                driverName: args['driverName'] as String? ?? 'N/A',
                vehicleNumber: args['vehicleNumber'] as String? ?? 'N/A',
            );
        },
      ),
    ],
  );
}

// --- Helper class to integrate Bloc Stream with GoRouter refresh listener ---
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
