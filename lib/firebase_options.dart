// File generated for FoodGo Firebase configuration.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC40v0jEPK-M8Za5ouAO9P_ppEPGVhFV-Q',
    appId: '1:642236225844:android:1741064360b452ffd7ed61',
    messagingSenderId: '642236225844',
    projectId: 'fooddelivery-bc953',
    storageBucket: 'fooddelivery-bc953.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC40v0jEPK-M8Za5ouAO9P_ppEPGVhFV-Q',
    appId: '1:642236225844:android:1741064360b452ffd7ed61',
    messagingSenderId: '642236225844',
    projectId: 'fooddelivery-bc953',
    storageBucket: 'fooddelivery-bc953.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC40v0jEPK-M8Za5ouAO9P_ppEPGVhFV-Q',
    appId: '1:642236225844:android:1741064360b452ffd7ed61',
    messagingSenderId: '642236225844',
    projectId: 'fooddelivery-bc953',
    storageBucket: 'fooddelivery-bc953.firebasestorage.app',
  );
}
