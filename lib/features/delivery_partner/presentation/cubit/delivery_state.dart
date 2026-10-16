import 'package:equatable/equatable.dart';

import '../../domain/entities/delivery_order.dart';

class DeliveryState extends Equatable {
  final List<DeliveryOrder> orders;
  final bool isLoading;
  final String? errorMessage;
  final String partnerId;

  const DeliveryState({
    this.orders = const [],
    this.isLoading = false,
    this.errorMessage,
    this.partnerId = 'dp_1',
  });

  DeliveryState copyWith({
    List<DeliveryOrder>? orders,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    String? partnerId,
  }) {
    return DeliveryState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      partnerId: partnerId ?? this.partnerId,
    );
  }

  int get totalAssigned => orders.length;

  int get activeDeliveriesCount => orders
      .where(
        (o) =>
            o.status == DeliveryStatus.accepted ||
            o.status == DeliveryStatus.pickedUp ||
            o.status == DeliveryStatus.onTheWay,
      )
      .length;

  int get activeCount => activeDeliveriesCount;

  int get completedTodayCount =>
      orders.where((o) => o.status == DeliveryStatus.delivered).length;

  int get completedCount => completedTodayCount;

  double get todayEarnings =>
      completedTodayCount * 50.0; // ₹50 delivery pay per trip

  List<DeliveryOrder> get pendingAcceptance =>
      orders.where((o) => o.status == DeliveryStatus.assigned).toList();

  List<DeliveryOrder> get inProgress => orders
      .where(
        (o) =>
            o.status == DeliveryStatus.accepted ||
            o.status == DeliveryStatus.pickedUp ||
            o.status == DeliveryStatus.onTheWay,
      )
      .toList();

  List<DeliveryOrder> get completed =>
      orders.where((o) => o.status == DeliveryStatus.delivered).toList();

  @override
  List<Object?> get props => [orders, isLoading, errorMessage, partnerId];
}
