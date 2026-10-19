import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../features/orders/data/datasources/order_local_datasource.dart';
import '../../../features/orders/data/datasources/order_remote_datasource.dart';
import '../../../features/orders/data/repositories/order_repository_impl.dart';
import '../../../features/orders/domain/repositories/order_repository.dart';
import '../../../features/orders/domain/usecases/create_order.dart';
import '../../../features/orders/domain/usecases/get_user_orders.dart';
import '../../../features/orders/domain/usecases/stream_user_orders.dart';
import '../../../features/orders/presentation/cubit/order_cubit.dart';

void registerOrderModule(GetIt sl) {
  sl.registerLazySingleton<OrderRemoteDataSource>(() {
    try {
      return OrderRemoteDataSource(sl<FirebaseFirestore>());
    } catch (_) {
      return const OrderRemoteDataSource();
    }
  });

  sl.registerLazySingleton<OrderLocalDataSource>(() {
    return OrderLocalDataSourceImpl(
      prefs: sl.isRegistered<SharedPreferences>()
          ? sl<SharedPreferences>()
          : null,
    );
  });

  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(
      sl<OrderRemoteDataSource>(),
      sl<OrderLocalDataSource>(),
    ),
  );

  sl.registerLazySingleton<CreateOrder>(
    () => CreateOrder(sl<OrderRepository>()),
  );

  sl.registerLazySingleton<GetUserOrders>(
    () => GetUserOrders(sl<OrderRepository>()),
  );

  sl.registerLazySingleton<StreamUserOrders>(
    () => StreamUserOrders(sl<OrderRepository>()),
  );

  sl.registerFactory<OrderCubit>(
    () => OrderCubit(
      createOrderUseCase: sl<CreateOrder>(),
      getUserOrdersUseCase: sl<GetUserOrders>(),
      streamUserOrdersUseCase: sl<StreamUserOrders>(),
    ),
  );
}
