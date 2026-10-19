import 'package:equatable/equatable.dart';

enum RestaurantOrderStatus {
  pending,
  accepted,
  preparing,
  readyForPickup,
  pickedUp,
  delivered,
  rejected,
  cancelled;

  String get label {
    switch (this) {
      case RestaurantOrderStatus.pending:
        return 'Pending';
      case RestaurantOrderStatus.accepted:
        return 'Accepted';
      case RestaurantOrderStatus.preparing:
        return 'Preparing';
      case RestaurantOrderStatus.readyForPickup:
        return 'Ready for Pickup';
      case RestaurantOrderStatus.pickedUp:
        return 'Out for Delivery';
      case RestaurantOrderStatus.delivered:
        return 'Delivered';
      case RestaurantOrderStatus.rejected:
        return 'Rejected';
      case RestaurantOrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  static RestaurantOrderStatus fromString(String val) {
    switch (val.toLowerCase().replaceAll(' ', '').replaceAll('_', '')) {
      case 'accepted':
        return RestaurantOrderStatus.accepted;
      case 'preparing':
        return RestaurantOrderStatus.preparing;
      case 'readyforpickup':
      case 'ready':
        return RestaurantOrderStatus.readyForPickup;
      case 'pickedup':
      case 'outfordelivery':
        return RestaurantOrderStatus.pickedUp;
      case 'delivered':
        return RestaurantOrderStatus.delivered;
      case 'rejected':
        return RestaurantOrderStatus.rejected;
      case 'cancelled':
      case 'canceled':
        return RestaurantOrderStatus.cancelled;
      case 'pending':
      default:
        return RestaurantOrderStatus.pending;
    }
  }
}

class RestaurantOrder extends Equatable {
  final String id;
  final String restaurantId;
  final String customerId;
  final double total;
  final RestaurantOrderStatus status;
  final String customerName;
  final String customerAddress;
  final List<String> items;
  final DateTime createdAt;

  RestaurantOrder({
    required this.id,
    required this.restaurantId,
    required this.customerId,
    required this.total,
    required this.status,
    this.customerName = 'Customer',
    this.customerAddress = 'Bengaluru',
    this.items = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  RestaurantOrder copyWith({
    String? id,
    String? restaurantId,
    String? customerId,
    double? total,
    RestaurantOrderStatus? status,
    String? customerName,
    String? customerAddress,
    List<String>? items,
    DateTime? createdAt,
  }) {
    return RestaurantOrder(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      customerId: customerId ?? this.customerId,
      total: total ?? this.total,
      status: status ?? this.status,
      customerName: customerName ?? this.customerName,
      customerAddress: customerAddress ?? this.customerAddress,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object> get props => [id, restaurantId, customerId, total, status];
}
