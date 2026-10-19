import '../entities/app_order.dart';
import '../entities/order_item.dart';
import '../repositories/order_repository.dart';

class CreateOrder {
  final OrderRepository repository;

  const CreateOrder(this.repository);

  Future<AppOrder> call({
    required String userId,
    required String restaurantId,
    required String restaurantName,
    required List<OrderItem> items,
    required double subtotal,
    required double deliveryFee,
    required double totalAmount,
    required String deliveryAddress,
    String paymentMethod = 'Cash on Delivery',
  }) {
    return repository.createOrder(
      userId: userId,
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      items: items,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      totalAmount: totalAmount,
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
    );
  }
}
