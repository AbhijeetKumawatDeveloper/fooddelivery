import 'package:flutter_test/flutter_test.dart';
import 'package:fooddelivery/core/di/injection.dart';
import 'package:fooddelivery/core/logger/app_logger.dart';
import 'package:fooddelivery/features/admin/domain/repositories/admin_repository.dart';
import 'package:fooddelivery/features/auth/domain/repositories/auth_repository.dart';
import 'package:fooddelivery/features/cart/domain/repositories/cart_repository.dart';
import 'package:fooddelivery/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:fooddelivery/features/delivery_partner/domain/repositories/delivery_repository.dart';
import 'package:fooddelivery/features/foods/domain/repositories/food_repository.dart';
import 'package:fooddelivery/features/orders/domain/repositories/order_repository.dart';
import 'package:fooddelivery/features/restaurant_partner/domain/repositories/partner_order_repository.dart';
import 'package:fooddelivery/features/restaurants/domain/repositories/restaurant_repository.dart';

void main() {
  group('Modular Dependency Injection Tests', () {
    setUp(() async {
      await getIt.reset();
      await setupDependencies();
    });

    tearDown(() async {
      await getIt.reset();
    });

    test('All core singletons and feature repositories are registered', () {
      expect(getIt.isRegistered<AppLogger>(), isTrue);
      expect(getIt.isRegistered<AuthRepository>(), isTrue);
      expect(getIt.isRegistered<RestaurantRepository>(), isTrue);
      expect(getIt.isRegistered<FoodRepository>(), isTrue);
      expect(getIt.isRegistered<CartRepository>(), isTrue);
      expect(getIt.isRegistered<CheckoutRepository>(), isTrue);
      expect(getIt.isRegistered<OrderRepository>(), isTrue);
      expect(getIt.isRegistered<PartnerOrderRepository>(), isTrue);
      expect(getIt.isRegistered<DeliveryRepository>(), isTrue);
      expect(getIt.isRegistered<AdminRepository>(), isTrue);
    });

    test('initDependencies alias initializes DI properly', () async {
      await getIt.reset();
      await initDependencies();

      expect(getIt.isRegistered<AuthRepository>(), isTrue);
      expect(getIt.isRegistered<RestaurantRepository>(), isTrue);
    });
  });
}
