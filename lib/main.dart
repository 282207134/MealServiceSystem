import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_bootstrap.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'presentation/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppBootstrap.initialize();
  runApp(const ProviderScope(child: FoodOrderingApp()));
}

class FoodOrderingApp extends StatelessWidget {
  const FoodOrderingApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.router;

    return MaterialApp.router(
      title: AppConfig.appName,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
