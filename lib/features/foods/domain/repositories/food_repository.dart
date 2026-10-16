import '../entities/food.dart';

abstract interface class FoodRepository {
  Future<List<Food>> getFoodsByRestaurant(String restaurantId);
}
