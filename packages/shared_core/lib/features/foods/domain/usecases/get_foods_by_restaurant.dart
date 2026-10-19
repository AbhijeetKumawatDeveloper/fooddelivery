import '../entities/food.dart';
import '../repositories/food_repository.dart';

class GetFoodsByRestaurant {
  final FoodRepository repository;

  const GetFoodsByRestaurant(this.repository);

  Future<List<Food>> call(String restaurantId) {
    return repository.getFoodsByRestaurant(restaurantId);
  }
}
