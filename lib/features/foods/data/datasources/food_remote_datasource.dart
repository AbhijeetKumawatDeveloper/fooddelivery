import 'package:cloud_firestore/cloud_firestore.dart';

class FoodRemoteDataSource {
  final FirebaseFirestore? firestore;

  const FoodRemoteDataSource([this.firestore]);

  Future<List<Map<String, dynamic>>> getFoodsByRestaurant(
    String restaurantId,
  ) async {
    final client = firestore;
    if (client == null) {
      return const [];
    }

    final snapshot = await client
        .collection('foods')
        .where('restaurantId', isEqualTo: restaurantId)
        .get();

    return snapshot.docs.map((doc) {
      return {...doc.data(), 'id': doc.id};
    }).toList();
  }
}
