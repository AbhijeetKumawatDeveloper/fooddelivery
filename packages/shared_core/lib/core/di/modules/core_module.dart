import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../logger/app_logger.dart';

Future<void> registerCoreModule(GetIt sl) async {
  // Centralized Application Logger
  if (!sl.isRegistered<AppLogger>()) {
    sl.registerLazySingleton<AppLogger>(() => const ConsoleAppLogger());
  }

  // Local Key-Value Persistence
  try {
    final sharedPreferences = await SharedPreferences.getInstance();
    if (!sl.isRegistered<SharedPreferences>()) {
      sl.registerSingleton<SharedPreferences>(sharedPreferences);
    }
  } catch (_) {
    // Graceful fallback for offline, widget test, or mock environments
  }

  // Firebase Core Services
  if (!sl.isRegistered<FirebaseAuth>()) {
    sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  }
  if (!sl.isRegistered<FirebaseFirestore>()) {
    sl.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance,
    );
  }
}
