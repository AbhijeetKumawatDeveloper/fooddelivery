import '../entities/restaurant_order.dart';
import '../repositories/partner_order_repository.dart';

class UpdateOrderStatus {
  final PartnerOrderRepository repository;

  UpdateOrderStatus(this.repository);

  Future<void> call({
    required String orderId,
    required RestaurantOrderStatus status,
  }) {
    return repository.updateStatus(orderId: orderId, status: status);
  }
}
