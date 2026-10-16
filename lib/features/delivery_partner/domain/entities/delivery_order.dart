import 'package:equatable/equatable.dart';

enum DeliveryStatus {
  assigned,
  accepted,
  pickedUp,
  onTheWay,
  delivered,
  cancelled;

  String get label {
    switch (this) {
      case DeliveryStatus.assigned:
        return 'Assigned';
      case DeliveryStatus.accepted:
        return 'Accepted';
      case DeliveryStatus.pickedUp:
        return 'Picked Up';
      case DeliveryStatus.onTheWay:
        return 'On The Way';
      case DeliveryStatus.delivered:
        return 'Delivered';
      case DeliveryStatus.cancelled:
        return 'Cancelled';
    }
  }

  static DeliveryStatus fromString(String val) {
    switch (val.toLowerCase().replaceAll(' ', '').replaceAll('_', '')) {
      case 'accepted':
        return DeliveryStatus.accepted;
      case 'pickedup':
        return DeliveryStatus.pickedUp;
      case 'ontheway':
      case 'outfordelivery':
        return DeliveryStatus.onTheWay;
      case 'delivered':
        return DeliveryStatus.delivered;
      case 'cancelled':
      case 'canceled':
        return DeliveryStatus.cancelled;
      case 'assigned':
      default:
        return DeliveryStatus.assigned;
    }
  }
}

class DeliveryOrder extends Equatable {
  final String id;
  final String customerId;
  final String restaurantId;
  final String deliveryPartnerId;
  final String deliveryAddress;
  final DeliveryStatus status;
  final String customerName;
  final String restaurantName;
  final double totalAmount;
  final double latitude;
  final double longitude;
  final List<String> items;
  final DateTime updatedAt;

  DeliveryOrder({
    required this.id,
    required this.customerId,
    required this.restaurantId,
    required this.deliveryPartnerId,
    required this.deliveryAddress,
    required this.status,
    this.customerName = 'Customer',
    this.restaurantName = 'Restaurant',
    this.totalAmount = 0.0,
    this.latitude = 12.9716,
    this.longitude = 77.5946,
    this.items = const [],
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  DeliveryOrder copyWith({
    String? id,
    String? customerId,
    String? restaurantId,
    String? deliveryPartnerId,
    String? deliveryAddress,
    DeliveryStatus? status,
    String? customerName,
    String? restaurantName,
    double? totalAmount,
    double? latitude,
    double? longitude,
    List<String>? items,
    DateTime? updatedAt,
  }) {
    return DeliveryOrder(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      restaurantId: restaurantId ?? this.restaurantId,
      deliveryPartnerId: deliveryPartnerId ?? this.deliveryPartnerId,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      status: status ?? this.status,
      customerName: customerName ?? this.customerName,
      restaurantName: restaurantName ?? this.restaurantName,
      totalAmount: totalAmount ?? this.totalAmount,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      items: items ?? this.items,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    customerId,
    restaurantId,
    deliveryPartnerId,
    deliveryAddress,
    status,
    latitude,
    longitude,
  ];
}
