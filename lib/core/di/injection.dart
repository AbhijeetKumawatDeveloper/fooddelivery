import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/cart/data/datasources/cart_local_datasource.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/cart/domain/usecases/cart_usecases.dart';
import '../../features/cart/presentation/cubit/cart_cubit.dart';
import '../../features/checkout/data/repositories/checkout_repository_impl.dart';
import '../../features/checkout/domain/repositories/checkout_repository.dart';
import '../../features/checkout/domain/usecases/calculate_checkout.dart';
import '../../features/checkout/presentation/cubit/checkout_cubit.dart';
import '../../features/foods/data/datasources/food_local_datasource.dart';
import '../../features/foods/data/datasources/food_remote_datasource.dart';
import '../../features/foods/data/repositories/food_repository_impl.dart';
import '../../features/foods/domain/repositories/food_repository.dart';
import '../../features/foods/domain/usecases/get_foods_by_restaurant.dart';
import '../../features/foods/presentation/cubit/food_cubit.dart';
import '../../features/orders/data/datasources/order_local_datasource.dart';
import '../../features/orders/data/datasources/order_remote_datasource.dart';
import '../../features/orders/data/repositories/order_repository_impl.dart';
import '../../features/orders/domain/repositories/order_repository.dart';
import '../../features/orders/domain/usecases/create_order.dart';
import '../../features/orders/domain/usecases/get_user_orders.dart';
import '../../features/orders/domain/usecases/stream_user_orders.dart';
import '../../features/orders/presentation/cubit/order_cubit.dart';
import '../../features/restaurant_partner/data/datasources/partner_order_datasource.dart';
import '../../features/restaurant_partner/data/repositories/partner_order_repository_impl.dart';
import '../../features/restaurant_partner/domain/repositories/partner_order_repository.dart';
import '../../features/restaurant_partner/domain/usecases/update_order_status.dart';
import '../../features/restaurant_partner/domain/usecases/watch_partner_orders.dart';
import '../../features/restaurant_partner/presentation/cubit/partner_order_cubit.dart';
import '../../features/restaurants/data/datasources/restaurant_local_datasource.dart';
import '../../features/restaurants/data/datasources/restaurant_remote_datasource.dart';
import '../../features/restaurants/data/repositories/restaurant_repository_impl.dart';
import '../../features/restaurants/domain/repositories/restaurant_repository.dart';
import '../../features/restaurants/domain/usecases/get_restaurants.dart';
import '../../features/restaurants/presentation/cubit/restaurant_cubit.dart';
import '../../features/delivery_partner/data/datasources/delivery_remote_datasource.dart';
import '../../features/delivery_partner/data/repositories/delivery_repository_impl.dart';
import '../../features/delivery_partner/domain/repositories/delivery_repository.dart';
import '../../features/delivery_partner/domain/usecases/update_delivery_location.dart';
import '../../features/delivery_partner/domain/usecases/update_delivery_status.dart';
import '../../features/delivery_partner/domain/usecases/watch_assigned_orders.dart';
import '../../features/delivery_partner/presentation/cubit/delivery_cubit.dart';
import '../../features/admin/data/datasources/admin_remote_datasource.dart';
import '../../features/admin/data/repositories/admin_repository_impl.dart';
import '../../features/admin/domain/repositories/admin_repository.dart';
import '../../features/admin/domain/usecases/get_dashboard_stats.dart';
import '../../features/admin/presentation/cubit/admin_dashboard_cubit.dart';

final getIt = GetIt.instance;
final sl = getIt;

Future<void> setupDependencies() async {
  // ---------------------------------------------------------------------------
  // Core / Local Storage
  // ---------------------------------------------------------------------------
  try {
    final sharedPreferences = await SharedPreferences.getInstance();
    if (!getIt.isRegistered<SharedPreferences>()) {
      getIt.registerSingleton<SharedPreferences>(sharedPreferences);
    }
  } catch (_) {
    // Graceful fallback for test or uninitialized environments
  }

  // ---------------------------------------------------------------------------
  // Features - Auth
  // ---------------------------------------------------------------------------
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  getIt.registerLazySingleton<AuthRemoteDataSource>(() {
    try {
      return AuthRemoteDataSource(getIt<FirebaseAuth>());
    } catch (_) {
      return const AuthRemoteDataSource();
    }
  });

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
  );

  getIt.registerLazySingleton<SignIn>(() => SignIn(getIt<AuthRepository>()));
  getIt.registerLazySingleton<SignUp>(() => SignUp(getIt<AuthRepository>()));
  getIt.registerLazySingleton<SignOut>(() => SignOut(getIt<AuthRepository>()));
  getIt.registerLazySingleton<ResetPassword>(
    () => ResetPassword(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<AuthCubit>(
    () => AuthCubit(
      repository: getIt<AuthRepository>(),
      signIn: getIt<SignIn>(),
      signUp: getIt<SignUp>(),
      signOut: getIt<SignOut>(),
      resetPassword: getIt<ResetPassword>(),
    ),
  );

  // ---------------------------------------------------------------------------
  // Features - Restaurants (Firestore Remote + Local Fallback)
  // ---------------------------------------------------------------------------
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  getIt.registerLazySingleton<RestaurantRemoteDataSource>(() {
    try {
      return RestaurantRemoteDataSource(getIt<FirebaseFirestore>());
    } catch (_) {
      return const RestaurantRemoteDataSource();
    }
  });

  getIt.registerLazySingleton<RestaurantLocalDataSource>(
    () => const RestaurantLocalDataSourceImpl(),
  );

  getIt.registerLazySingleton<RestaurantRepository>(
    () => RestaurantRepositoryImpl(
      getIt<RestaurantRemoteDataSource>(),
      getIt<RestaurantLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton<GetRestaurants>(
    () => GetRestaurants(getIt<RestaurantRepository>()),
  );

  getIt.registerFactory(() => RestaurantCubit(getIt<GetRestaurants>()));

  // ---------------------------------------------------------------------------
  // Features - Foods (Firestore Remote + Local Fallback)
  // ---------------------------------------------------------------------------
  getIt.registerLazySingleton<FoodRemoteDataSource>(() {
    try {
      return FoodRemoteDataSource(getIt<FirebaseFirestore>());
    } catch (_) {
      return const FoodRemoteDataSource();
    }
  });

  getIt.registerLazySingleton<FoodLocalDataSource>(
    () => const FoodLocalDataSourceImpl(),
  );

  getIt.registerLazySingleton<FoodRepository>(
    () => FoodRepositoryImpl(
      getIt<FoodRemoteDataSource>(),
      getIt<FoodLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton<GetFoodsByRestaurant>(
    () => GetFoodsByRestaurant(getIt<FoodRepository>()),
  );

  getIt.registerFactory<FoodCubit>(
    () => FoodCubit(getIt<GetFoodsByRestaurant>()),
  );

  // ---------------------------------------------------------------------------
  // Features - Cart (Local SharedPreferences Persistence)
  // ---------------------------------------------------------------------------
  getIt.registerLazySingleton<CartLocalDataSource>(() {
    return CartLocalDataSourceImpl(
      prefs: getIt.isRegistered<SharedPreferences>()
          ? getIt<SharedPreferences>()
          : null,
    );
  });

  getIt.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(getIt<CartLocalDataSource>()),
  );

  getIt.registerLazySingleton(() => GetCartItems(getIt<CartRepository>()));

  getIt.registerLazySingleton(() => AddToCart(getIt<CartRepository>()));

  getIt.registerLazySingleton(
    () => UpdateCartQuantity(getIt<CartRepository>()),
  );

  getIt.registerLazySingleton(() => ClearCart(getIt<CartRepository>()));

  getIt.registerLazySingleton(
    () => CartCubit(
      repository: getIt<CartRepository>(),
      getCartItems: getIt<GetCartItems>(),
      addToCartUseCase: getIt<AddToCart>(),
      updateCartQuantity: getIt<UpdateCartQuantity>(),
      clearCartUseCase: getIt<ClearCart>(),
    ),
  );

  // ---------------------------------------------------------------------------
  // Features - Checkout
  // ---------------------------------------------------------------------------
  getIt.registerLazySingleton<CalculateCheckout>(() => CalculateCheckout());

  getIt.registerLazySingleton<CheckoutRepository>(
    () => CheckoutRepositoryImpl(
      getIt.isRegistered<SharedPreferences>()
          ? getIt<SharedPreferences>()
          : null,
    ),
  );

  getIt.registerFactory<CheckoutCubit>(
    () => CheckoutCubit(
      calculateCheckout: getIt<CalculateCheckout>(),
      repository: getIt<CheckoutRepository>(),
    ),
  );

  // ---------------------------------------------------------------------------
  // Features - Orders (Customer App)
  // ---------------------------------------------------------------------------
  getIt.registerLazySingleton<OrderRemoteDataSource>(() {
    try {
      return OrderRemoteDataSource(getIt<FirebaseFirestore>());
    } catch (_) {
      return const OrderRemoteDataSource();
    }
  });

  getIt.registerLazySingleton<OrderLocalDataSource>(() {
    return OrderLocalDataSourceImpl(
      prefs: getIt.isRegistered<SharedPreferences>()
          ? getIt<SharedPreferences>()
          : null,
    );
  });

  getIt.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(
      getIt<OrderRemoteDataSource>(),
      getIt<OrderLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton<CreateOrder>(
    () => CreateOrder(getIt<OrderRepository>()),
  );

  getIt.registerLazySingleton<GetUserOrders>(
    () => GetUserOrders(getIt<OrderRepository>()),
  );

  getIt.registerLazySingleton<StreamUserOrders>(
    () => StreamUserOrders(getIt<OrderRepository>()),
  );

  getIt.registerFactory<OrderCubit>(
    () => OrderCubit(
      createOrderUseCase: getIt<CreateOrder>(),
      getUserOrdersUseCase: getIt<GetUserOrders>(),
      streamUserOrdersUseCase: getIt<StreamUserOrders>(),
    ),
  );

  // ---------------------------------------------------------------------------
  // Features - Restaurant Partner
  // ---------------------------------------------------------------------------
  getIt.registerLazySingleton<PartnerOrderDataSource>(() {
    try {
      return PartnerOrderRemoteDataSource(getIt<FirebaseFirestore>());
    } catch (_) {
      return PartnerOrderRemoteDataSource();
    }
  });

  getIt.registerLazySingleton<PartnerOrderRepository>(
    () => PartnerOrderRepositoryImpl(getIt<PartnerOrderDataSource>()),
  );

  getIt.registerLazySingleton<WatchPartnerOrders>(
    () => WatchPartnerOrders(getIt<PartnerOrderRepository>()),
  );

  getIt.registerLazySingleton<UpdateOrderStatus>(
    () => UpdateOrderStatus(getIt<PartnerOrderRepository>()),
  );

  getIt.registerFactory<PartnerOrderCubit>(
    () => PartnerOrderCubit(
      watchPartnerOrders: getIt<WatchPartnerOrders>(),
      updateOrderStatus: getIt<UpdateOrderStatus>(),
      repository: getIt<PartnerOrderRepository>(),
    ),
  );

  // ---------------------------------------------------------------------------
  // Features - Delivery Partner
  // ---------------------------------------------------------------------------
  getIt.registerLazySingleton<DeliveryDataSource>(() {
    try {
      return DeliveryRemoteDataSource(getIt<FirebaseFirestore>());
    } catch (_) {
      return DeliveryRemoteDataSource();
    }
  });

  getIt.registerLazySingleton<DeliveryRepository>(
    () => DeliveryRepositoryImpl(getIt<DeliveryDataSource>()),
  );

  getIt.registerLazySingleton<WatchAssignedOrders>(
    () => WatchAssignedOrders(getIt<DeliveryRepository>()),
  );

  getIt.registerLazySingleton<UpdateDeliveryStatus>(
    () => UpdateDeliveryStatus(getIt<DeliveryRepository>()),
  );

  getIt.registerLazySingleton<UpdateDeliveryLocation>(
    () => UpdateDeliveryLocation(getIt<DeliveryRepository>()),
  );

  getIt.registerFactory<DeliveryCubit>(
    () => DeliveryCubit(
      watchAssignedOrders: getIt<WatchAssignedOrders>(),
      updateDeliveryStatus: getIt<UpdateDeliveryStatus>(),
      updateDeliveryLocation: getIt<UpdateDeliveryLocation>(),
      repository: getIt<DeliveryRepository>(),
    ),
  );

  // ---------------------------------------------------------------------------
  // Features - Admin Console
  // ---------------------------------------------------------------------------
  getIt.registerLazySingleton<AdminDataSource>(() {
    try {
      return AdminRemoteDataSource(getIt<FirebaseFirestore>());
    } catch (_) {
      return AdminRemoteDataSource();
    }
  });

  getIt.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(getIt<AdminDataSource>()),
  );

  getIt.registerLazySingleton<GetDashboardStats>(
    () => GetDashboardStats(getIt<AdminRepository>()),
  );

  getIt.registerFactory<AdminDashboardCubit>(
    () => AdminDashboardCubit(
      getDashboardStats: getIt<GetDashboardStats>(),
      repository: getIt<AdminRepository>(),
    ),
  );
}

Future<void> initDependencies() => setupDependencies();
