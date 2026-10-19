import '../entities/app_order.dart';
import '../repositories/order_repository.dart';

class GetUserOrders {
  final OrderRepository repository;

  const GetUserOrders(this.repository);

  Future<List<AppOrder>> call(String userId) {
    return repository.getUserOrders(userId);
  }
}
