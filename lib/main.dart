import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iwms_citizen_app/core/di.dart';
import 'package:iwms_citizen_app/logic/auth/auth_bloc.dart';
// We don't need auth_event.dart here
import 'package:iwms_citizen_app/router/app_router.dart';
import 'package:iwms_citizen_app/router/go_router_refresh_stream.dart';
import 'package:iwms_citizen_app/router/route_observer.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDI(); // Await the DI setup

  final authBloc = getIt<AuthBloc>();
  final appRouter = AppRouter(
    authBloc: authBloc, // Pass the BLoC instance
    routeObserver: routeObserver,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
  );

  runApp(
    DevicePreview(
      enabled: true, // <-- Make sure this is true to see the preview
      builder: (context) => MyApp(appRouter: appRouter.router),
    ),
  );
}

class MyApp extends StatelessWidget {
  final GoRouter appRouter;

  const MyApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      // The AuthBloc is already initialized by getIt,
      // and its constructor already calls AuthStatusChecked.
      // We just need to provide the instance.
      value: getIt<AuthBloc>(),
      child: MaterialApp.router(
        title: 'IWMS',
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
      ),
    );
  }
}

