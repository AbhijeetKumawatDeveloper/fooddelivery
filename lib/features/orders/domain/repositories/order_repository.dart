import '../entities/app_order.dart';
import '../entities/order_item.dart';

abstract interface class OrderRepository {
  Future<AppOrder> createOrder({
    required String userId,
    required String restaurantId,
    required String restaurantName,
    required List<OrderItem> items,
    required double subtotal,
    required double deliveryFee,
    required double totalAmount,
    required String deliveryAddress,
    String paymentMethod = 'Cash on Delivery',
  });

  Future<List<AppOrder>> getUserOrders(String userId);

  Stream<List<AppOrder>> streamUserOrders(String userId);
}
