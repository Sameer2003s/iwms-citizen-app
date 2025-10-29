import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart'; 

// New layered imports
import 'core/di.dart';       
import 'logic/auth/auth_bloc.dart'; 
import 'router/app_router.dart';   
import 'core/constants.dart';      


void main() {
  // CRITICAL: Initialize bindings instantly for platform plugins (like SharedPreferences)
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize Dependency Injection synchronously. AuthBloc handles the internal async wait.
  setupDI(); 

  // 2. Run the application immediately, ensuring the fastest boot time.
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
      // 2. Provide the AuthBloc to the entire widget tree
      BlocProvider(
        // AuthBloc constructor handles the async SharedPreferences lookup internally.
        create: (context) => getIt<AuthBloc>(),
        child: 
          MaterialApp.router( 
            locale: DevicePreview.locale(context),
            builder: DevicePreview.appBuilder,
            useInheritedMediaQuery: true, 
            
            title: 'IWMS Citizen App',
            theme: ThemeData(
              primaryColor: kPrimaryColor,
              colorScheme: ColorScheme.fromSeed(
                seedColor: kPrimaryColor,
                primary: kPrimaryColor,
                secondary: kPrimaryColor,
              ),
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
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: kContainerColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  borderSide: BorderSide(color: kBorderColor, width: 1),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  borderSide: BorderSide(color: kBorderColor, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  borderSide: BorderSide(color: kPrimaryColor, width: 2), 
                ),
              ),
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                  TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                },
              ),
            ),
            debugShowCheckedModeBanner: false,
            
            routerConfig: appRouter.router,
          ), 
      );
  }
}
