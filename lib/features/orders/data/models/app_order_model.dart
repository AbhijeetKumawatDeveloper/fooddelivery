import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/app_order.dart';
import 'order_item_model.dart';

class AppOrderModel extends AppOrder {
  const AppOrderModel({
    required super.id,
    required super.userId,
    required super.restaurantId,
    super.restaurantName = '',
    required super.items,
    required super.subtotal,
    required super.deliveryFee,
    required super.totalAmount,
    required super.deliveryAddress,
    super.paymentMethod = 'Cash on Delivery',
    super.status = OrderStatus.pending,
    required super.createdAt,
  });

  factory AppOrderModel.fromEntity(AppOrder entity) {
    return AppOrderModel(
      id: entity.id,
      userId: entity.userId,
      restaurantId: entity.restaurantId,
      restaurantName: entity.restaurantName,
      items: entity.items,
      subtotal: entity.subtotal,
      deliveryFee: entity.deliveryFee,
      totalAmount: entity.totalAmount,
      deliveryAddress: entity.deliveryAddress,
      paymentMethod: entity.paymentMethod,
      status: entity.status,
      createdAt: entity.createdAt,
    );
  }

  factory AppOrderModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    final rawItems = map['items'];
    final itemsList = (rawItems is List)
        ? rawItems
              .map(
                (item) => OrderItemModel.fromMap(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList()
        : <OrderItemModel>[];

    DateTime parsedDate;
    final rawDate = map['createdAt'];
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else if (rawDate is int) {
      parsedDate = DateTime.fromMillisecondsSinceEpoch(rawDate);
    } else {
      parsedDate = DateTime.now();
    }

    return AppOrderModel(
      id: docId ?? (map['id'] ?? '').toString(),
      userId: (map['userId'] ?? '').toString(),
      restaurantId: (map['restaurantId'] ?? '').toString(),
      restaurantName: (map['restaurantName'] ?? '').toString(),
      items: itemsList,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (map['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      deliveryAddress: (map['deliveryAddress'] ?? '').toString(),
      paymentMethod: (map['paymentMethod'] ?? 'Cash on Delivery').toString(),
      status: OrderStatus.fromString((map['status'] ?? 'pending').toString()),
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
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
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
