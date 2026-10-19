import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import '../../../features/foods/data/datasources/food_local_datasource.dart';
import '../../../features/foods/data/datasources/food_remote_datasource.dart';
import '../../../features/foods/data/repositories/food_repository_impl.dart';
import '../../../features/foods/domain/repositories/food_repository.dart';
import '../../../features/foods/domain/usecases/get_foods_by_restaurant.dart';
import '../../../features/foods/presentation/cubit/food_cubit.dart';

void registerFoodModule(GetIt sl) {
  sl.registerLazySingleton<FoodRemoteDataSource>(() {
    try {
      return FoodRemoteDataSource(sl<FirebaseFirestore>());
    } catch (_) {
      return const FoodRemoteDataSource();
    }
  });

  sl.registerLazySingleton<FoodLocalDataSource>(
    () => const FoodLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<FoodRepository>(
    () => FoodRepositoryImpl(
      sl<FoodRemoteDataSource>(),
      sl<FoodLocalDataSource>(),
    ),
  );

  sl.registerLazySingleton<GetFoodsByRestaurant>(
    () => GetFoodsByRestaurant(sl<FoodRepository>()),
  );

  sl.registerFactory<FoodCubit>(() => FoodCubit(sl<GetFoodsByRestaurant>()));
}
