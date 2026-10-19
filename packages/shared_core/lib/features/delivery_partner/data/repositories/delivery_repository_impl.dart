import '../../domain/entities/delivery_order.dart';
import '../../domain/repositories/delivery_repository.dart';
import '../datasources/delivery_remote_datasource.dart';
import '../models/delivery_order_model.dart';

class DeliveryRepositoryImpl implements DeliveryRepository {
  final DeliveryDataSource dataSource;

  DeliveryRepositoryImpl(this.dataSource);

  @override
  Stream<List<DeliveryOrder>> watchAssignedOrders(String deliveryPartnerId) {
    return dataSource.watchAssignedOrders(deliveryPartnerId).map((list) {
      final orders = list
          .map((map) => DeliveryOrderModel.fromMap(map))
          .toList();
      orders.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return orders;
    });
  }

  @override
  Future<List<DeliveryOrder>> getAssignedOrders(
    String deliveryPartnerId,
  ) async {
    final list = await dataSource.getAssignedOrders(deliveryPartnerId);
    final orders = list.map((map) => DeliveryOrderModel.fromMap(map)).toList();
    orders.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return orders;
  }

  @override
  Future<void> updateStatus(String orderId, DeliveryStatus status) async {
    await dataSource.updateStatus(orderId, status.name);
  }

  @override
  Future<void> updateLocation(
    String orderId,
    double latitude,
    double longitude,
  ) async {
    await dataSource.updateLocation(orderId, latitude, longitude);
  }
}
