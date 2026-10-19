import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_core/shared_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('[FoodGo Delivery Error] ${details.exceptionAsString()}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('[FoodGo Delivery Unhandled Error] $error\n$stack');
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

  runApp(const FoodGoDeliveryApp());
}

class FoodGoDeliveryApp extends StatelessWidget {
  const FoodGoDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => getIt<AuthCubit>(),
        ),
        BlocProvider<DeliveryCubit>(
          create: (_) =>
              getIt<DeliveryCubit>()..listenToAssignedOrders('partner_1'),
        ),
      ],
      child: MaterialApp(
        title: 'FoodGo — Delivery Partner',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00897B),
            primary: const Color(0xFF00897B),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF00897B),
            foregroundColor: Colors.white,
            elevation: 2,
          ),
        ),
        home: const DeliveryDashboardScreen(),
      ),
    );
  }
}
