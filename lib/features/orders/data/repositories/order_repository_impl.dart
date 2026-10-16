import '../../domain/entities/app_order.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_local_datasource.dart';
import '../datasources/order_remote_datasource.dart';
import '../models/app_order_model.dart';
import '../models/order_item_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;
  final OrderLocalDataSource localDataSource;

  const OrderRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
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
  }) async {
    final now = DateTime.now();
    final tempOrder = AppOrder(
      id: '',
      userId: userId,
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      items: items,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      totalAmount: totalAmount,
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
      status: OrderStatus.pending,
      createdAt: now,
    );

    try {
      final orderMap = {
        'userId': userId,
        'restaurantId': restaurantId,
        'restaurantName': restaurantName,
        'items': items
            .map((item) => OrderItemModel.fromEntity(item).toMap())
            .toList(),
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'totalAmount': totalAmount,
        'deliveryAddress': deliveryAddress,
        'paymentMethod': paymentMethod,
        'status': OrderStatus.pending.name,
      };

      final result = await remoteDataSource.createOrder(orderMap);
      final createdOrder = AppOrderModel.fromMap(result);
      await localDataSource.saveOrder(createdOrder);
      return createdOrder;
    } catch (_) {
      // Offline fallback: save locally
      return localDataSource.saveOrder(tempOrder);
    }
  }

  @override
  Future<List<AppOrder>> getUserOrders(String userId) async {
    try {
      final remoteData = await remoteDataSource.getUserOrders(userId);
      if (remoteData.isNotEmpty) {
        final remoteOrders =
            remoteData.map((map) => AppOrderModel.fromMap(map)).toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return remoteOrders;
      }
    } catch (_) {
      // Fall through to local cache
    }

    return localDataSource.getUserOrders(userId);
  }

  @override
  Stream<List<AppOrder>> streamUserOrders(String userId) {
    if (remoteDataSource.firestore != null) {
      return remoteDataSource
          .streamUserOrders(userId)
          .map((list) {
            if (list.isNotEmpty) {
              final orders =
                  list.map((map) => AppOrderModel.fromMap(map)).toList()
                    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
              return orders;
            }
            return <AppOrder>[];
          })
          .handleError((_) {
            return localDataSource.streamUserOrders(userId);
          });
    }

    return localDataSource.streamUserOrders(userId);
  }
}
