import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

abstract interface class DeliveryDataSource {
  Stream<List<Map<String, dynamic>>> watchAssignedOrders(
    String deliveryPartnerId,
  );
  Future<List<Map<String, dynamic>>> getAssignedOrders(
    String deliveryPartnerId,
  );
  Future<void> updateStatus(String orderId, String status);
  Future<void> updateLocation(
    String orderId,
    double latitude,
    double longitude,
  );
}

class DeliveryRemoteDataSource implements DeliveryDataSource {
  final FirebaseFirestore? firestore;

  final List<Map<String, dynamic>> _mockDeliveries = [
    {
      'id': 'del_ord_01',
      'customerId': 'cust_01',
      'customerName': 'Sanya Malhotra',
      'restaurantId': 'r1',
      'restaurantName': 'Burger Hub Indiranagar',
      'deliveryPartnerId': 'dp_1',
      'deliveryAddress': 'Flat 304, Green Glen Layout, Bellandur, Bengaluru',
      'deliveryStatus': 'assigned',
      'status': 'assigned',
      'totalAmount': 540.0,
      'latitude': 12.9352,
      'longitude': 77.6245,
      'items': ['2 x Double Cheese Burger', '1 x Peri Peri Fries', '2 x Coke'],
      'updatedAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'del_ord_02',
      'customerId': 'cust_02',
      'customerName': 'Vikram Rathore',
      'restaurantId': 'r1',
      'restaurantName': 'Burger Hub Indiranagar',
      'deliveryPartnerId': 'dp_1',
      'deliveryAddress': 'Villa 18, Palm Meadows, Whitefield, Bengaluru',
      'deliveryStatus': 'onTheWay',
      'status': 'onTheWay',
      'totalAmount': 890.0,
      'latitude': 12.9698,
      'longitude': 77.7499,
      'items': ['3 x Chicken Zinger', '1 x Large Popcorn Chicken'],
      'updatedAt': DateTime.now().toIso8601String(),
    },
  ];

  final StreamController<List<Map<String, dynamic>>> _streamController =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  DeliveryRemoteDataSource([this.firestore]);

  @override
  Stream<List<Map<String, dynamic>>> watchAssignedOrders(
    String deliveryPartnerId,
  ) {
    final client = firestore;
    if (client != null) {
      return client
          .collection('orders')
          .where('deliveryPartnerId', isEqualTo: deliveryPartnerId)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => {'id': doc.id, ...doc.data()})
                .toList();
          });
    }

    final filtered = _mockDeliveries
        .where(
          (o) =>
              deliveryPartnerId.isEmpty ||
              o['deliveryPartnerId'] == deliveryPartnerId,
        )
        .toList();

    return Stream.value(filtered).concatWith([
      _streamController.stream.map(
        (list) => list
            .where(
              (o) =>
                  deliveryPartnerId.isEmpty ||
                  o['deliveryPartnerId'] == deliveryPartnerId,
            )
            .toList(),
      ),
    ]);
  }

  @override
  Future<List<Map<String, dynamic>>> getAssignedOrders(
    String deliveryPartnerId,
  ) async {
    final client = firestore;
    if (client != null) {
      final snapshot = await client
          .collection('orders')
          .where('deliveryPartnerId', isEqualTo: deliveryPartnerId)
          .get();
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    }

    return _mockDeliveries
        .where(
          (o) =>
              deliveryPartnerId.isEmpty ||
              o['deliveryPartnerId'] == deliveryPartnerId,
        )
        .toList();
  }

  @override
  Future<void> updateStatus(String orderId, String status) async {
    final client = firestore;
    if (client != null) {
      await client.collection('orders').doc(orderId).update({
        'deliveryStatus': status,
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    final index = _mockDeliveries.indexWhere((o) => o['id'] == orderId);
    if (index >= 0) {
      _mockDeliveries[index]['deliveryStatus'] = status;
      _mockDeliveries[index]['status'] = status;
      _mockDeliveries[index]['updatedAt'] = DateTime.now().toIso8601String();
      _streamController.add(List.from(_mockDeliveries));
    }
  }

  @override
  Future<void> updateLocation(
    String orderId,
    double latitude,
    double longitude,
  ) async {
    final client = firestore;
    if (client != null) {
      await client.collection('orders').doc(orderId).update({
        'deliveryLocation': {'latitude': latitude, 'longitude': longitude},
        'latitude': latitude,
        'longitude': longitude,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    final index = _mockDeliveries.indexWhere((o) => o['id'] == orderId);
    if (index >= 0) {
      _mockDeliveries[index]['latitude'] = latitude;
      _mockDeliveries[index]['longitude'] = longitude;
      _mockDeliveries[index]['deliveryLocation'] = {
        'latitude': latitude,
        'longitude': longitude,
      };
      _mockDeliveries[index]['updatedAt'] = DateTime.now().toIso8601String();
      _streamController.add(List.from(_mockDeliveries));
    }
  }
}

extension _StreamConcat<T> on Stream<T> {
  Stream<T> concatWith(Iterable<Stream<T>> others) async* {
    yield* this;
    for (final s in others) {
      yield* s;
    }
  }
}
