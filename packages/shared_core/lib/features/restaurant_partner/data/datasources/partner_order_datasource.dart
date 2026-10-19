import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

abstract interface class PartnerOrderDataSource {
  Stream<List<Map<String, dynamic>>> watchOrders(String restaurantId);
  Future<List<Map<String, dynamic>>> getOrders(String restaurantId);
  Future<void> updateStatus({required String orderId, required String status});
}

class PartnerOrderRemoteDataSource implements PartnerOrderDataSource {
  final FirebaseFirestore? firestore;

  // In-memory fallback if Firestore is unavailable (offline or unit testing)
  final List<Map<String, dynamic>> _mockOrders = [
    {
      'id': 'ord_101',
      'restaurantId': 'r1',
      'customerId': 'cust_01',
      'customerName': 'Aarav Sharma',
      'customerAddress': '124 Market Road, Indiranagar',
      'total': 480.0,
      'status': 'pending',
      'items': ['2 x Classic Burger', '1 x French Fries'],
      'createdAt': DateTime.now()
          .subtract(const Duration(minutes: 10))
          .toIso8601String(),
    },
    {
      'id': 'ord_102',
      'restaurantId': 'r1',
      'customerId': 'cust_02',
      'customerName': 'Priya Patel',
      'customerAddress': '56 Koramangala 4th Block',
      'total': 650.0,
      'status': 'preparing',
      'items': ['1 x Chicken Biryani', '2 x Cold Drink'],
      'createdAt': DateTime.now()
          .subtract(const Duration(minutes: 25))
          .toIso8601String(),
    },
    {
      'id': 'ord_103',
      'restaurantId': 'r1',
      'customerId': 'cust_03',
      'customerName': 'Rohan Gupta',
      'customerAddress': '89 HSR Layout, Sector 2',
      'total': 340.0,
      'status': 'delivered',
      'items': ['1 x Veggie Delight Burger'],
      'createdAt': DateTime.now()
          .subtract(const Duration(hours: 2))
          .toIso8601String(),
    },
  ];

  final StreamController<List<Map<String, dynamic>>> _streamController =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  PartnerOrderRemoteDataSource([this.firestore]);

  @override
  Stream<List<Map<String, dynamic>>> watchOrders(String restaurantId) {
    final client = firestore;
    if (client != null) {
      return client
          .collection('orders')
          .where('restaurantId', isEqualTo: restaurantId)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              final data = doc.data();
              return {...data, 'id': doc.id};
            }).toList();
          });
    }

    // Offline / Mock Stream
    final filtered = _mockOrders
        .where((o) => o['restaurantId'] == restaurantId)
        .toList();

    return Stream.value(filtered).concatWith([
      _streamController.stream.map(
        (list) => list.where((o) => o['restaurantId'] == restaurantId).toList(),
      ),
    ]);
  }

  @override
  Future<List<Map<String, dynamic>>> getOrders(String restaurantId) async {
    final client = firestore;
    if (client != null) {
      final snapshot = await client
          .collection('orders')
          .where('restaurantId', isEqualTo: restaurantId)
          .get();
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    }

    return _mockOrders.where((o) => o['restaurantId'] == restaurantId).toList();
  }

  @override
  Future<void> updateStatus({
    required String orderId,
    required String status,
  }) async {
    final client = firestore;
    if (client != null) {
      await client.collection('orders').doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    final index = _mockOrders.indexWhere((o) => o['id'] == orderId);
    if (index >= 0) {
      _mockOrders[index]['status'] = status;
      _streamController.add(List.from(_mockOrders));
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
