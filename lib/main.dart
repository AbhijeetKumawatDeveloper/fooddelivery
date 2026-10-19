import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/config/app_config.dart';
import 'core/di/injection.dart' as di;
import 'core/logger/app_bloc_observer.dart';
import 'core/logger/app_logger.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/cart/presentation/cubit/cart_cubit.dart';
import 'features/restaurants/presentation/cubit/restaurant_cubit.dart';
import 'features/restaurants/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Production Crash Reporting & Global Unhandled Error Trapping
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('[FoodGo FlutterError] ${details.exceptionAsString()}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('[FoodGo Unhandled Platform Error] $error\n$stack');
    return true;
  };

  AppConfig.initialize(AppConfig.prod());
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Graceful fallback to offline mock mode when Firebase configuration / credentials are not yet added
  }
  await di.setupDependencies();
  Bloc.observer = AppBlocObserver(logger: di.getIt<AppLogger>());
  runApp(const FoodGoApp());
}

class FoodGoApp extends StatelessWidget {
  const FoodGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => di.getIt<AuthCubit>()),
        BlocProvider<CartCubit>(
          create: (_) => di.getIt<CartCubit>()..loadCart(),
        ),
        BlocProvider<RestaurantCubit>(
          create: (_) => di.getIt<RestaurantCubit>()..loadRestaurants(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner:
            AppConfig.instance.environment != Environment.prod,
        title: AppConfig.instance.appTitle,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
