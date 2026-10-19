import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_core/shared_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('[FoodGo Admin Web Error] ${details.exceptionAsString()}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('[FoodGo Admin Web Unhandled Error] $error\n$stack');
    return true;
  };

  AppConfig.initialize(AppConfig.prod());

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('[Firebase Init Fallback] $e');
  }

  await setupDependencies();
  Bloc.observer = AppBlocObserver(logger: getIt<AppLogger>());

  runApp(const FoodGoAdminWebApp());
}

class FoodGoAdminWebApp extends StatelessWidget {
  const FoodGoAdminWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => getIt<AuthCubit>(),
        ),
        BlocProvider<AdminDashboardCubit>(
          create: (_) => getIt<AdminDashboardCubit>()..loadDashboardData(),
        ),
      ],
      child: MaterialApp(
        title: 'FoodGo — Platform Admin Console',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E293B),
            primary: const Color(0xFF0F172A),
            secondary: const Color(0xFF3B82F6),
            surface: const Color(0xFFF8FAFC),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0F172A),
            foregroundColor: Colors.white,
            elevation: 2,
          ),
        ),
        home: const AdminDashboardScreen(),
      ),
    );
  }
}
