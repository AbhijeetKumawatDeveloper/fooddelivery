import '../entities/cart_item.dart';

abstract interface class CartRepository {
  List<CartItem> getItems();
  void saveItems(List<CartItem> items);
}
