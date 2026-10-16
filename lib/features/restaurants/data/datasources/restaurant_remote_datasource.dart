import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantRemoteDataSource {
  final FirebaseFirestore? firestore;

  const RestaurantRemoteDataSource([this.firestore]);

  Future<List<Map<String, dynamic>>> getRestaurants() async {
    final client = firestore;
    if (client == null) {
      return const [];
    }

    final snapshot = await client.collection('restaurants').get();

    return snapshot.docs.map((doc) {
      return {...doc.data(), 'id': doc.id};
    }).toList();
  }
}
