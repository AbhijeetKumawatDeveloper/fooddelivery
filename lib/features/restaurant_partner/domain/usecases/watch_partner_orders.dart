import '../entities/restaurant_order.dart';
import '../repositories/partner_order_repository.dart';

class WatchPartnerOrders {
  final PartnerOrderRepository repository;

  WatchPartnerOrders(this.repository);

  Stream<List<RestaurantOrder>> call(String restaurantId) {
    return repository.watchOrders(restaurantId);
  }
}
