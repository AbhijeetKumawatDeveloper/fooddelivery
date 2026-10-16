import '../entities/restaurant.dart';
import '../repositories/restaurant_repository.dart';

class GetRestaurants {
  final RestaurantRepository repository;

  GetRestaurants(this.repository);

  Future<List<Restaurant>> call() {
    return repository.getRestaurants();
  }
}
