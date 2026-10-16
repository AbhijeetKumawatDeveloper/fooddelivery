import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/delivery_order.dart';

class DeliveryOrderModel extends DeliveryOrder {
  DeliveryOrderModel({
    required super.id,
    required super.customerId,
    required super.restaurantId,
    required super.deliveryPartnerId,
    required super.deliveryAddress,
    required super.status,
    super.customerName = 'Customer',
    super.restaurantName = 'Restaurant',
    super.totalAmount = 0.0,
    super.latitude = 12.9716,
    super.longitude = 77.5946,
    super.items = const [],
    super.updatedAt,
  });

  factory DeliveryOrderModel.fromEntity(DeliveryOrder entity) {
    return DeliveryOrderModel(
      id: entity.id,
      customerId: entity.customerId,
      restaurantId: entity.restaurantId,
      deliveryPartnerId: entity.deliveryPartnerId,
      deliveryAddress: entity.deliveryAddress,
      status: entity.status,
      customerName: entity.customerName,
      restaurantName: entity.restaurantName,
      totalAmount: entity.totalAmount,
      latitude: entity.latitude,
      longitude: entity.longitude,
      items: entity.items,
      updatedAt: entity.updatedAt,
    );
  }

  factory DeliveryOrderModel.fromMap(
    Map<String, dynamic> map, [
    String? docId,
  ]) {
    final rawLoc = map['deliveryLocation'];
    double lat = 12.9716;
    double lng = 77.5946;
    if (rawLoc is Map) {
      lat = (rawLoc['latitude'] as num?)?.toDouble() ?? 12.9716;
      lng = (rawLoc['longitude'] as num?)?.toDouble() ?? 77.5946;
    } else {
      lat = (map['latitude'] as num?)?.toDouble() ?? 12.9716;
      lng = (map['longitude'] as num?)?.toDouble() ?? 77.5946;
    }

    final rawItems = map['items'];
    List<String> parsedItems = [];
    if (rawItems is List) {
      parsedItems = rawItems.map((e) {
        if (e is Map) {
          final qty = e['quantity'] ?? 1;
          final name = e['name'] ?? 'Item';
          return '$qty x $name';
        }
        return e.toString();
      }).toList();
    }

    DateTime parsedDate;
    final rawDate = map['updatedAt'] ?? map['createdAt'];
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    final total =
        (map['totalAmount'] as num?)?.toDouble() ??
        (map['total'] as num?)?.toDouble() ??
        0.0;

    return DeliveryOrderModel(
      id: docId ?? (map['id'] ?? '').toString(),
      customerId: (map['customerId'] ?? map['userId'] ?? '').toString(),
      restaurantId: (map['restaurantId'] ?? '').toString(),
      deliveryPartnerId: (map['deliveryPartnerId'] ?? '').toString(),
      deliveryAddress: (map['deliveryAddress'] ?? 'Indiranagar, Bengaluru')
          .toString(),
      status: DeliveryStatus.fromString(
        (map['deliveryStatus'] ?? map['status'] ?? 'assigned').toString(),
      ),
      customerName: (map['customerName'] ?? 'Customer').toString(),
      restaurantName: (map['restaurantName'] ?? 'Burger Hub').toString(),
      totalAmount: total,
      latitude: lat,
      longitude: lng,
      items: parsedItems,
      updatedAt: parsedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'restaurantId': restaurantId,
      'deliveryPartnerId': deliveryPartnerId,
      'deliveryAddress': deliveryAddress,
      'deliveryStatus': status.name,
      'status': status.name,
      'customerName': customerName,
      'restaurantName': restaurantName,
      'totalAmount': totalAmount,
      'deliveryLocation': {'latitude': latitude, 'longitude': longitude},
      'latitude': latitude,
      'longitude': longitude,
      'items': items,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
