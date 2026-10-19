import '../entities/delivery_order.dart';

abstract class DeliveryRepository {
  Stream<List<DeliveryOrder>> watchAssignedOrders(String deliveryPartnerId);

  Future<List<DeliveryOrder>> getAssignedOrders(String deliveryPartnerId);

  Future<void> updateStatus(String orderId, DeliveryStatus status);

  Future<void> updateLocation(
    String orderId,
    double latitude,
    double longitude,
  );
}
