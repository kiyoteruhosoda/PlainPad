import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plainpad/app/bootstrap/app_widget.dart';
import 'package:plainpad/app/di/service_locator.dart';
import 'package:plainpad/shared/licenses/app_license_registry.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Make the status bar transparent
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

  // Lock to portrait (comment out if needed)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize dependency injection
  await setupServiceLocator();

  // Register our own licenses with LicenseRegistry
  AppLicenseRegistrar.register();

  runApp(const AppWidget());
}
