import '../entities/cart_item.dart';
import '../repositories/cart_repository.dart';

class GetCartItems {
  final CartRepository repository;

  const GetCartItems(this.repository);

  List<CartItem> call() => repository.getItems();
}

class AddToCart {
  final CartRepository repository;

  const AddToCart(this.repository);

  void call(CartItem newItem) {
    final items = List<CartItem>.from(repository.getItems());

    final index = items.indexWhere((item) => item.foodId == newItem.foodId);

    if (index >= 0) {
      items[index] = items[index].copyWith(
        quantity: items[index].quantity + newItem.quantity,
      );
    } else {
      items.add(newItem);
    }

    repository.saveItems(items);
  }
}

class UpdateCartQuantity {
  final CartRepository repository;

  const UpdateCartQuantity(this.repository);

  void call(String foodId, int quantity) {
    final items = repository.getItems();

    if (quantity <= 0) {
      repository.saveItems(
        items.where((item) => item.foodId != foodId).toList(),
      );
      return;
    }

    repository.saveItems(
      items.map((item) {
        return item.foodId == foodId ? item.copyWith(quantity: quantity) : item;
      }).toList(),
    );
  }
}

class ClearCart {
  final CartRepository repository;

  const ClearCart(this.repository);

  void call() => repository.saveItems([]);
}
