import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/config/app_config.dart';
import 'core/di/injection.dart' as di;
import 'main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.initialize(AppConfig.dev());
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Offline development fallback
  }
  await di.setupDependencies();
  runApp(const FoodGoApp());
}
