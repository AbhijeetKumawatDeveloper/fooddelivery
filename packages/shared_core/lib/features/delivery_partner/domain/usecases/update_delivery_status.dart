import '../entities/delivery_order.dart';
import '../repositories/delivery_repository.dart';

class UpdateDeliveryStatus {
  final DeliveryRepository repository;

  UpdateDeliveryStatus(this.repository);

  Future<void> call({required String orderId, required DeliveryStatus status}) {
    return repository.updateStatus(orderId, status);
  }
}
