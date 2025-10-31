import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart'; 
import 'package:iwms_citizen_app/core/theme/app_theme.dart'; // <-- IMPORT NEW THEME

import 'core/di.dart';       
import 'logic/auth/auth_bloc.dart'; 
import 'router/app_router.dart';   
// We no longer need constants here, theme handles it

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize Dependency Injection (from your repo)
  setupDI(); 

  // 2. Run the application (from your repo)
  runApp(
    DevicePreview(
      enabled: !kReleaseMode, 
      builder: (context) => const MyApp(), 
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter(); 

    return 
      BlocProvider(
        create: (context) => getIt<AuthBloc>(),
        child: 
          MaterialApp.router( 
            locale: DevicePreview.locale(context),
            builder: DevicePreview.appBuilder,
            useInheritedMediaQuery: true, 
            
            title: 'IWMS Citizen App',
            
            // --- USE OUR NEW THEME ---
            theme: AppTheme.lightTheme, 
            // --- END THEME ---
            
            debugShowCheckedModeBanner: false,
            routerConfig: appRouter.router,
          ), 
      );
  }
}