import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../features/checkout/data/repositories/checkout_repository_impl.dart';
import '../../../features/checkout/domain/repositories/checkout_repository.dart';
import '../../../features/checkout/domain/usecases/calculate_checkout.dart';
import '../../../features/checkout/presentation/cubit/checkout_cubit.dart';

void registerCheckoutModule(GetIt sl) {
  sl.registerLazySingleton<CalculateCheckout>(() => CalculateCheckout());

  sl.registerLazySingleton<CheckoutRepository>(
    () => CheckoutRepositoryImpl(
      sl.isRegistered<SharedPreferences>() ? sl<SharedPreferences>() : null,
    ),
  );

  sl.registerFactory<CheckoutCubit>(
    () => CheckoutCubit(
      calculateCheckout: sl<CalculateCheckout>(),
      repository: sl<CheckoutRepository>(),
    ),
  );
}
