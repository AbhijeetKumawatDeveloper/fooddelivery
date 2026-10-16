import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/config/app_config.dart';
import 'core/di/injection.dart' as di;
import 'main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.initialize(AppConfig.staging());
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Staging initialization
  }
  await di.setupDependencies();
  runApp(const FoodGoApp());
}
