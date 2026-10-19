import '../repositories/delivery_repository.dart';

class UpdateDeliveryLocation {
  final DeliveryRepository repository;

  UpdateDeliveryLocation(this.repository);

  Future<void> call({
    required String orderId,
    required double latitude,
    required double longitude,
  }) {
    return repository.updateLocation(orderId, latitude, longitude);
  }
}
