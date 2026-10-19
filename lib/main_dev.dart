import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/config/app_config.dart';
import 'core/di/injection.dart' as di;
import 'core/logger/app_bloc_observer.dart';
import 'core/logger/app_logger.dart';
import 'firebase_options.dart';
import 'main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.initialize(AppConfig.dev());
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // Offline development fallback
  }
  await di.setupDependencies();
  Bloc.observer = AppBlocObserver(logger: di.getIt<AppLogger>());
  runApp(const FoodGoApp());
}
