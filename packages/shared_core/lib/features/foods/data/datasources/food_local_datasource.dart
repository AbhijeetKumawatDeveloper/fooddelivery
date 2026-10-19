abstract interface class FoodLocalDataSource {
  Future<List<Map<String, dynamic>>> getFoodsByRestaurant(String restaurantId);
}

class FoodLocalDataSourceImpl implements FoodLocalDataSource {
  const FoodLocalDataSourceImpl();

  @override
  Future<List<Map<String, dynamic>>> getFoodsByRestaurant(
    String restaurantId,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    final isBurger = restaurantId == 'r1';

    return [
      {
        'id': '${restaurantId}_special',
        'restaurantId': restaurantId,
        'name': isBurger ? 'Burger House Special' : 'Special Signature Delight',
        'description':
            'Delicious chef-crafted meal prepared with fresh ingredients',
        'price': 249,
        'image': 'assets/images/Burger.png',
        'category': 'Specials',
        'isAvailable': true,
      },
      {
        'id': '${restaurantId}_combo',
        'restaurantId': restaurantId,
        'name': 'Deluxe Combo Platter',
        'description': 'Main dish served with sides and a refreshing dip',
        'price': 349,
        'image': 'assets/images/Biryani.png',
        'category': 'Combos',
        'isAvailable': true,
      },
      {
        'id': '${restaurantId}_drink',
        'restaurantId': restaurantId,
        'name': 'Chilled Beverage Can',
        'description': 'Refreshing chilled soda to complement your meal',
        'price': 79,
        'image': 'assets/images/Cola.png',
        'category': 'Beverages',
        'isAvailable': true,
      },
    ];
  }
}
