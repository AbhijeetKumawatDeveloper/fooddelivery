import 'package:equatable/equatable.dart';

import '../../domain/entities/restaurant_order.dart';

class PartnerOrderState extends Equatable {
  final List<RestaurantOrder> orders;
  final bool isLoading;
  final String? errorMessage;
  final String restaurantId;

  const PartnerOrderState({
    this.orders = const [],
    this.isLoading = false,
    this.errorMessage,
    this.restaurantId = 'r1',
  });

  PartnerOrderState copyWith({
    List<RestaurantOrder>? orders,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    String? restaurantId,
  }) {
    return PartnerOrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      restaurantId: restaurantId ?? this.restaurantId,
    );
  }

  // Dashboard Metrics
  int get totalOrdersCount => orders.length;

  int get pendingCount =>
      orders.where((o) => o.status == RestaurantOrderStatus.pending).length;

  int get inProgressCount => orders
      .where(
        (o) =>
            o.status == RestaurantOrderStatus.accepted ||
            o.status == RestaurantOrderStatus.preparing ||
            o.status == RestaurantOrderStatus.readyForPickup ||
            o.status == RestaurantOrderStatus.pickedUp,
      )
      .length;

  int get completedCount =>
      orders.where((o) => o.status == RestaurantOrderStatus.delivered).length;

  double get totalSales => orders
      .where(
        (o) =>
            o.status != RestaurantOrderStatus.rejected &&
            o.status != RestaurantOrderStatus.cancelled,
      )
      .fold(0.0, (sum, o) => sum + o.total);

  List<RestaurantOrder> get pendingOrders =>
      orders.where((o) => o.status == RestaurantOrderStatus.pending).toList();

  List<RestaurantOrder> get activeOrders => orders
      .where(
        (o) =>
            o.status == RestaurantOrderStatus.accepted ||
            o.status == RestaurantOrderStatus.preparing ||
            o.status == RestaurantOrderStatus.readyForPickup ||
            o.status == RestaurantOrderStatus.pickedUp,
      )
      .toList();

  List<RestaurantOrder> get completedOrders => orders
      .where(
        (o) =>
            o.status == RestaurantOrderStatus.delivered ||
            o.status == RestaurantOrderStatus.rejected ||
            o.status == RestaurantOrderStatus.cancelled,
      )
      .toList();

  @override
  List<Object?> get props => [orders, isLoading, errorMessage, restaurantId];
}
