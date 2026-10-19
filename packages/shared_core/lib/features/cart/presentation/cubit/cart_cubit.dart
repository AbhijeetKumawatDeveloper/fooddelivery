import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/usecases/cart_usecases.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRepository repository;
  final GetCartItems? getCartItems;
  final AddToCart addToCartUseCase;
  final UpdateCartQuantity updateCartQuantity;
  final ClearCart clearCartUseCase;

  CartCubit({
    required this.repository,
    this.getCartItems,
    required this.addToCartUseCase,
    required this.updateCartQuantity,
    required this.clearCartUseCase,
  }) : super(CartLoaded(items: repository.getItems()));

  void loadCart() {
    emit(const CartLoading());
    try {
      final items = getCartItems != null
          ? getCartItems!()
          : repository.getItems();
      emit(CartLoaded(items: items));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  void addToCart(CartItem item) {
    try {
      addToCartUseCase(item);
      _refresh();
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  void add(CartItem item) => addToCart(item);

  void updateQuantity(String foodId, int quantity) {
    try {
      updateCartQuantity(foodId, quantity);
      _refresh();
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  void increaseQuantity(String foodId) {
    final current = state;
    if (current is CartLoaded) {
      final item = current.items.firstWhere(
        (i) => i.foodId == foodId,
        orElse: () => const CartItem(
          foodId: '',
          restaurantId: '',
          name: '',
          price: 0,
          quantity: 0,
        ),
      );
      if (item.foodId.isNotEmpty) {
        updateQuantity(foodId, item.quantity + 1);
      }
    }
  }

  void increase(String foodId) => increaseQuantity(foodId);

  void decreaseQuantity(String foodId) {
    final current = state;
    if (current is CartLoaded) {
      final item = current.items.firstWhere(
        (i) => i.foodId == foodId,
        orElse: () => const CartItem(
          foodId: '',
          restaurantId: '',
          name: '',
          price: 0,
          quantity: 0,
        ),
      );
      if (item.foodId.isNotEmpty) {
        updateQuantity(foodId, item.quantity - 1);
      }
    }
  }

  void decrease(String foodId) => decreaseQuantity(foodId);

  void removeFromCart(String foodId) {
    updateQuantity(foodId, 0);
  }

  void clearCart() {
    try {
      clearCartUseCase();
      _refresh();
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  void clear() => clearCart();

  void _refresh() {
    final items = getCartItems != null
        ? getCartItems!()
        : repository.getItems();
    emit(CartLoaded(items: items));
  }
}
