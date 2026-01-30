import 'package:flutter/material.dart';

import 'package:eco_maestro/config/routes.dart';
import 'package:eco_maestro/config/theme.dart';

import 'package:eco_maestro/core/di/service_locator.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  runApp(const EcoMaestroApp());
}

class EcoMaestroApp extends StatelessWidget {
  const EcoMaestroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Eco Maestro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, // Forzamos dark mode por diseño
      routerConfig: appRouter,
    );
  }
}
