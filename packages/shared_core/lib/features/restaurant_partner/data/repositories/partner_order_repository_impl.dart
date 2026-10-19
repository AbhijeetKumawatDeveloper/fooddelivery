import '../../domain/entities/restaurant_order.dart';
import '../../domain/repositories/partner_order_repository.dart';
import '../datasources/partner_order_datasource.dart';
import '../models/restaurant_order_model.dart';

class PartnerOrderRepositoryImpl implements PartnerOrderRepository {
  final PartnerOrderDataSource dataSource;

  PartnerOrderRepositoryImpl(this.dataSource);

  @override
  Stream<List<RestaurantOrder>> watchOrders(String restaurantId) {
    return dataSource.watchOrders(restaurantId).map((list) {
      final orders = list
          .map((map) => RestaurantOrderModel.fromMap(map))
          .toList();
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    });
  }

  @override
  Future<List<RestaurantOrder>> getOrders(String restaurantId) async {
    final list = await dataSource.getOrders(restaurantId);
    final orders = list
        .map((map) => RestaurantOrderModel.fromMap(map))
        .toList();
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  }

  @override
  Future<void> updateStatus({
    required String orderId,
    required RestaurantOrderStatus status,
  }) async {
    await dataSource.updateStatus(orderId: orderId, status: status.name);
  }
}
