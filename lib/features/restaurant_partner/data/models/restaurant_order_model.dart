import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/restaurant_order.dart';

class RestaurantOrderModel extends RestaurantOrder {
  RestaurantOrderModel({
    required super.id,
    required super.restaurantId,
    required super.customerId,
    required super.total,
    required super.status,
    super.customerName = 'Customer',
    super.customerAddress = 'Bengaluru',
    super.items = const [],
    super.createdAt,
  });

  factory RestaurantOrderModel.fromEntity(RestaurantOrder entity) {
    return RestaurantOrderModel(
      id: entity.id,
      restaurantId: entity.restaurantId,
      customerId: entity.customerId,
      total: entity.total,
      status: entity.status,
      customerName: entity.customerName,
      customerAddress: entity.customerAddress,
      items: entity.items,
      createdAt: entity.createdAt,
    );
  }

  factory RestaurantOrderModel.fromMap(
    Map<String, dynamic> map, [
    String? docId,
  ]) {
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
    final rawDate = map['createdAt'];
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

    return RestaurantOrderModel(
      id: docId ?? (map['id'] ?? '').toString(),
      restaurantId: (map['restaurantId'] ?? '').toString(),
      customerId: (map['customerId'] ?? map['userId'] ?? '').toString(),
      total: total,
      status: RestaurantOrderStatus.fromString(
        (map['status'] ?? 'pending').toString(),
      ),
      customerName: (map['customerName'] ?? 'Customer').toString(),
      customerAddress:
          (map['deliveryAddress'] ?? map['customerAddress'] ?? 'Bengaluru')
              .toString(),
      items: parsedItems,
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'customerId': customerId,
      'total': total,
      'totalAmount': total,
      'status': status.name,
      'customerName': customerName,
      'customerAddress': customerAddress,
      'deliveryAddress': customerAddress,
      'items': items,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
