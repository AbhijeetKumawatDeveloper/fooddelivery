import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import '../../../features/restaurants/data/datasources/restaurant_local_datasource.dart';
import '../../../features/restaurants/data/datasources/restaurant_remote_datasource.dart';
import '../../../features/restaurants/data/repositories/restaurant_repository_impl.dart';
import '../../../features/restaurants/domain/repositories/restaurant_repository.dart';
import '../../../features/restaurants/domain/usecases/get_restaurants.dart';
import '../../../features/restaurants/presentation/cubit/restaurant_cubit.dart';

void registerRestaurantModule(GetIt sl) {
  sl.registerLazySingleton<RestaurantRemoteDataSource>(() {
    try {
      return RestaurantRemoteDataSource(sl<FirebaseFirestore>());
    } catch (_) {
      return const RestaurantRemoteDataSource();
    }
  });

  sl.registerLazySingleton<RestaurantLocalDataSource>(
    () => const RestaurantLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<RestaurantRepository>(
    () => RestaurantRepositoryImpl(
      sl<RestaurantRemoteDataSource>(),
      sl<RestaurantLocalDataSource>(),
    ),
  );

  sl.registerLazySingleton<GetRestaurants>(
    () => GetRestaurants(sl<RestaurantRepository>()),
  );

  sl.registerFactory(() => RestaurantCubit(sl<GetRestaurants>()));
}
