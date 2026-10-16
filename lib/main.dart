import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart' as di;
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/cart/presentation/cubit/cart_cubit.dart';
import 'features/restaurants/presentation/cubit/restaurant_cubit.dart';
import 'features/restaurants/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Graceful fallback to offline mock mode when Firebase configuration / credentials are not yet added
  }
  await di.setupDependencies();
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
        debugShowCheckedModeBanner: false,
        title: 'FoodGo',
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
