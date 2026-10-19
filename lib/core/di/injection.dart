import 'package:get_it/get_it.dart';

import 'modules/admin_module.dart';
import 'modules/auth_module.dart';
import 'modules/cart_module.dart';
import 'modules/checkout_module.dart';
import 'modules/core_module.dart';
import 'modules/delivery_module.dart';
import 'modules/food_module.dart';
import 'modules/order_module.dart';
import 'modules/partner_module.dart';
import 'modules/restaurant_module.dart';

final getIt = GetIt.instance;
final sl = getIt;

/// Initializes all dependency injection modules across Core, Features, and Infrastructure.
Future<void> setupDependencies() async {
  await registerCoreModule(getIt);
  registerAuthModule(getIt);
  registerRestaurantModule(getIt);
  registerFoodModule(getIt);
  registerCartModule(getIt);
  registerCheckoutModule(getIt);
  registerOrderModule(getIt);
  registerPartnerModule(getIt);
  registerDeliveryModule(getIt);
  registerAdminModule(getIt);
}

/// Convenience alias for [setupDependencies]
Future<void> initDependencies() => setupDependencies();
