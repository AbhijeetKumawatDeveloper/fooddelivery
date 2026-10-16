import '../entities/delivery_order.dart';
import '../repositories/delivery_repository.dart';

class WatchAssignedOrders {
  final DeliveryRepository repository;

  WatchAssignedOrders(this.repository);

  Stream<List<DeliveryOrder>> call(String deliveryPartnerId) {
    return repository.watchAssignedOrders(deliveryPartnerId);
  }
}
