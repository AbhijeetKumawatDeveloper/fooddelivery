import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_datasource.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource? localDataSource;
  List<CartItem> _items = [];

  CartRepositoryImpl([this.localDataSource]) {
    if (localDataSource != null) {
      _items = List<CartItem>.from(localDataSource!.getCartItems());
    }
  }

  @override
  List<CartItem> getItems() => List.unmodifiable(_items);

  @override
  void saveItems(List<CartItem> items) {
    _items = List<CartItem>.from(items);
    localDataSource?.saveCartItems(_items);
  }
}
