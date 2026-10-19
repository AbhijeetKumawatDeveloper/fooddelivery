import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../features/cart/data/datasources/cart_local_datasource.dart';
import '../../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../../features/cart/domain/repositories/cart_repository.dart';
import '../../../features/cart/domain/usecases/cart_usecases.dart';
import '../../../features/cart/presentation/cubit/cart_cubit.dart';

void registerCartModule(GetIt sl) {
  sl.registerLazySingleton<CartLocalDataSource>(() {
    return CartLocalDataSourceImpl(
      prefs: sl.isRegistered<SharedPreferences>()
          ? sl<SharedPreferences>()
          : null,
    );
  });

  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(sl<CartLocalDataSource>()),
  );

  sl.registerLazySingleton(() => GetCartItems(sl<CartRepository>()));
  sl.registerLazySingleton(() => AddToCart(sl<CartRepository>()));
  sl.registerLazySingleton(() => UpdateCartQuantity(sl<CartRepository>()));
  sl.registerLazySingleton(() => ClearCart(sl<CartRepository>()));

  sl.registerLazySingleton(
    () => CartCubit(
      repository: sl<CartRepository>(),
      getCartItems: sl<GetCartItems>(),
      addToCartUseCase: sl<AddToCart>(),
      updateCartQuantity: sl<UpdateCartQuantity>(),
      clearCartUseCase: sl<ClearCart>(),
    ),
  );
}
