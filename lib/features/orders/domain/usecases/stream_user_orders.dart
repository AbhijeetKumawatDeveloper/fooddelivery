import '../entities/app_order.dart';
import '../repositories/order_repository.dart';

class StreamUserOrders {
  final OrderRepository repository;

  const StreamUserOrders(this.repository);

  Stream<List<AppOrder>> call(String userId) {
    return repository.streamUserOrders(userId);
  }
}
