abstract interface class RestaurantLocalDataSource {
  Future<List<Map<String, dynamic>>> getRestaurants();
}

class RestaurantLocalDataSourceImpl implements RestaurantLocalDataSource {
  const RestaurantLocalDataSourceImpl();

  @override
  Future<List<Map<String, dynamic>>> getRestaurants() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    return [
      {
        'id': 'r1',
        'name': 'Burger House',
        'cuisine': 'Burgers • Fast Food',
        'rating': 4.5,
        'deliveryTime': 25,
        'image': 'assets/images/Burger.png',
      },
      {
        'id': 'r2',
        'name': 'Pizza Point',
        'cuisine': 'Pizza • Italian',
        'rating': 4.3,
        'deliveryTime': 30,
        'image': 'assets/images/Burger.png',
      },
      {
        'id': 'r3',
        'name': 'Biryani House',
        'cuisine': 'Indian',
        'rating': 4.6,
        'deliveryTime': 35,
        'image': 'assets/images/Biryani.png',
      },
    ];
  }
}
