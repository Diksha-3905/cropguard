import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:plant_diagnostics/screens/home_screen.dart';
import 'package:plant_diagnostics/services/database_service.dart';
import 'package:plant_diagnostics/utils/app_theme.dart';
import 'package:plant_diagnostics/utils/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  // Initialize local SQLite DB
  await DatabaseService.instance.init();

  runApp(
    const ProviderScope(
      child: PlantDiagnosticsApp(),
    ),
  );
}

class PlantDiagnosticsApp extends StatelessWidget {
  const PlantDiagnosticsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CropGuard — Plant Diagnostics',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
