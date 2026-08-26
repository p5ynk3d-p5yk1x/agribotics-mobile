import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/services/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services (Dotenv, Logger, etc.)
  await ServiceLocator.initialize();

  runApp(
    const ProviderScope(
      child: TheEstateApp(),
    ),
  );
}
