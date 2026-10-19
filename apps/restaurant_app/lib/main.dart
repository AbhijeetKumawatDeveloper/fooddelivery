import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_core/shared_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('[FoodGo Restaurant POS Error] ${details.exceptionAsString()}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('[FoodGo Restaurant Unhandled Error] $error\n$stack');
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

  runApp(const FoodGoRestaurantApp());
}

class FoodGoRestaurantApp extends StatelessWidget {
  const FoodGoRestaurantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => getIt<AuthCubit>(),
        ),
        BlocProvider<PartnerOrderCubit>(
          create: (_) => getIt<PartnerOrderCubit>()..listenToOrders('rest_1'),
        ),
      ],
      child: MaterialApp(
        title: 'FoodGo — Restaurant Partner POS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFE65100),
            primary: const Color(0xFFE65100),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFE65100),
            foregroundColor: Colors.white,
            elevation: 2,
          ),
        ),
        home: const PartnerDashboardScreen(),
      ),
    );
  }
}
