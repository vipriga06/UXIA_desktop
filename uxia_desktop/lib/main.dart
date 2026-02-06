import 'package:flutter/material.dart';
import 'constants/app_constants.dart';
import 'screens/login_screen.dart';
import 'services/settings_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsManager = SettingsManager();
  await settingsManager.initialize();
  runApp(LaMenuApp(settingsManager: settingsManager));
}

class LaMenuApp extends StatelessWidget {
  final SettingsManager settingsManager;

  const LaMenuApp({super.key, required this.settingsManager});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(AppConstants.primaryColorValue),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(AppConstants.bgColorValue),
        fontFamily: AppConstants.fontFamily,
      ),
      home: LoginScreen(settingsManager: settingsManager),
    );
  }
}
