import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:iwms_citizen_app/core/theme/app_theme.dart';
import 'package:iwms_citizen_app/router/go_router_refresh_stream.dart'; // <-- IMPORT
import 'package:iwms_citizen_app/router/route_observer.dart';

import 'core/di.dart';
import 'logic/auth/auth_bloc.dart';
import 'router/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupDI();

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
    // 1. Create the AuthBloc instance from GetIt
    final authBloc = getIt<AuthBloc>();

    // 2. Create the refresh stream notifier that listens to the bloc
    final refreshListenable = GoRouterRefreshStream(authBloc.stream);

    // 3. We must provide the AuthBloc to the widget tree
    return BlocProvider<AuthBloc>(
      create: (context) => authBloc,
      child: Builder(
        builder: (context) {
          // 4. Create the AppRouter, passing dependencies
          final appRouter = AppRouter(
            routeObserver: routeObserver,
            refreshListenable: refreshListenable, // <-- PASS Listenable
          );

          // 5. Store the context in GetIt for the BLoC in the redirect.
          // This is still needed so the _redirect logic can *read*
          // the current BLoC state synchronously.
          if (!getIt.isRegistered<BuildContext>()) {
            getIt.registerSingleton<BuildContext>(context,
                dispose: (_) => getIt.unregister<BuildContext>());
          }

          return MaterialApp.router(
            locale: DevicePreview.locale(context),
            builder: DevicePreview.appBuilder,
            useInheritedMediaQuery: true,
            title: 'IWMS Citizen App',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            routerConfig: appRouter.router,
          );
        },
      ),
    );
  }
}