import '../entities/restaurant_order.dart';

abstract interface class PartnerOrderRepository {
  Stream<List<RestaurantOrder>> watchOrders(String restaurantId);

  Future<List<RestaurantOrder>> getOrders(String restaurantId);

  Future<void> updateStatus({
    required String orderId,
    required RestaurantOrderStatus status,
  });
}
