import 'package:equatable/equatable.dart';

import 'order_item.dart';

enum OrderStatus {
  pending,
  confirmed,
  outForDelivery,
  delivered,
  cancelled;

  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Order Placed';
      case OrderStatus.confirmed:
        return 'Preparing';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  static OrderStatus fromString(String value) {
    switch (value.toLowerCase().replaceAll(' ', '').replaceAll('_', '')) {
      case 'confirmed':
      case 'preparing':
        return OrderStatus.confirmed;
      case 'outfordelivery':
      case 'ontheway':
        return OrderStatus.outForDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
      case 'canceled':
        return OrderStatus.cancelled;
      case 'pending':
      default:
        return OrderStatus.pending;
    }
  }
}

class AppOrder extends Equatable {
  final String id;
  final String userId;
  final String restaurantId;
  final String restaurantName;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double totalAmount;
  final String deliveryAddress;
  final String paymentMethod;
  final OrderStatus status;
  final DateTime createdAt;

  const AppOrder({
    required this.id,
    required this.userId,
    required this.restaurantId,
    this.restaurantName = '',
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.totalAmount,
    required this.deliveryAddress,
    this.paymentMethod = 'Cash on Delivery',
    this.status = OrderStatus.pending,
    required this.createdAt,
  });

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  AppOrder copyWith({
    String? id,
    String? userId,
    String? restaurantId,
    String? restaurantName,
    List<OrderItem>? items,
    double? subtotal,
    double? deliveryFee,
    double? totalAmount,
    String? deliveryAddress,
    String? paymentMethod,
    OrderStatus? status,
    DateTime? createdAt,
  }) {
    return AppOrder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      totalAmount: totalAmount ?? this.totalAmount,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    restaurantId,
    restaurantName,
    items,
    subtotal,
    deliveryFee,
    totalAmount,
    deliveryAddress,
    paymentMethod,
    status,
    createdAt,
  ];
}
