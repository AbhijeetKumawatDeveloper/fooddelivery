import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_core/shared_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('[FoodGo Customer Error] ${details.exceptionAsString()}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('[FoodGo Customer Unhandled Error] $error\n$stack');
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

  runApp(const FoodGoCustomerApp());
}

class FoodGoCustomerApp extends StatelessWidget {
  const FoodGoCustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => getIt<AuthCubit>(),
        ),
        BlocProvider<RestaurantCubit>(
          create: (_) => getIt<RestaurantCubit>()..loadRestaurants(),
        ),
        BlocProvider<CartCubit>(
          create: (_) => getIt<CartCubit>()..loadCart(),
        ),
        BlocProvider<OrderCubit>(
          create: (_) => getIt<OrderCubit>(),
        ),
      ],
      child: MaterialApp(
        title: 'FoodGo — Customer App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const CustomerHomeScreen(),
      ),
    );
  }
}

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}
