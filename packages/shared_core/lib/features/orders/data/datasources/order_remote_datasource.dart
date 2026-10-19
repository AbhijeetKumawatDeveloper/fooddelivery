import 'package:cloud_firestore/cloud_firestore.dart';

class OrderRemoteDataSource {
  final FirebaseFirestore? firestore;

  const OrderRemoteDataSource([this.firestore]);

  Future<Map<String, dynamic>> createOrder(
    Map<String, dynamic> orderData,
  ) async {
    final client = firestore;
    if (client == null) {
      throw StateError('Firestore is not initialized');
    }

    final collection = client.collection('orders');
    final docRef = await collection.add({
      ...orderData,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final snapshot = await docRef.get();
    final data = snapshot.data() ?? orderData;
    return {
      ...data,
      'id': docRef.id,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  Future<List<Map<String, dynamic>>> getUserOrders(String userId) async {
    final client = firestore;
    if (client == null) {
      return [];
    }

    final snapshot = await client
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {...data, 'id': doc.id};
    }).toList();
  }

  Stream<List<Map<String, dynamic>>> streamUserOrders(String userId) {
    final client = firestore;
    if (client == null) {
      return const Stream.empty();
    }

    return client
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return {...data, 'id': doc.id};
          }).toList();
        });
  }
}
