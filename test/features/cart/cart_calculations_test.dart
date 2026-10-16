import 'package:flutter_test/flutter_test.dart';
import 'package:fooddelivery/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:fooddelivery/features/cart/domain/entities/cart_item.dart';
import 'package:fooddelivery/features/cart/domain/repositories/cart_repository.dart';
import 'package:fooddelivery/features/cart/domain/usecases/cart_usecases.dart';
import 'package:fooddelivery/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:fooddelivery/features/cart/presentation/cubit/cart_state.dart';

void main() {
  group('CartItem Entity Tests', () {
    test('calculates totalPrice correctly', () {
      const item = CartItem(
        foodId: 'f1',
        restaurantId: 'r1',
        name: 'Veggie Burger',
        price: 150.0,
        quantity: 3,
      );

      expect(item.totalPrice, 450.0);
      expect(item.id, 'f1');
    });

    test('copyWith updates fields correctly', () {
      const item = CartItem(
        foodId: 'f1',
        restaurantId: 'r1',
        name: 'Veggie Burger',
        price: 150.0,
        quantity: 1,
      );

      final updated = item.copyWith(quantity: 4);
      expect(updated.quantity, 4);
      expect(updated.foodId, 'f1');
      expect(updated.price, 150.0);
      expect(updated.totalPrice, 600.0);
    });
  });

  group('CartState Calculations Tests', () {
    test('empty CartLoaded has 0 subtotal, 0 total, and isEmpty is true', () {
      const state = CartLoaded(items: []);

      expect(state.isEmpty, isTrue);
      expect(state.subtotal, 0.0);
      expect(state.total, 0.0);
      expect(state.totalItemCount, 0);
    });

    test('calculates subtotal and total with delivery fee correctly', () {
      const item1 = CartItem(
        foodId: 'f1',
        restaurantId: 'r1',
        name: 'Burger',
        price: 200.0,
        quantity: 2,
      ); // 400.0
      const item2 = CartItem(
        foodId: 'f2',
        restaurantId: 'r1',
        name: 'Fries',
        price: 100.0,
        quantity: 1,
      ); // 100.0

      const state = CartLoaded(items: [item1, item2], deliveryFee: 40.0);

      expect(state.isEmpty, isFalse);
      expect(state.subtotal, 500.0);
      expect(state.deliveryFee, 40.0);
      expect(state.total, 540.0);
      expect(state.totalItemCount, 3);
    });
  });

  group('Cart Use Cases Tests', () {
    late CartRepository repository;
    late AddToCart addToCart;
    late UpdateCartQuantity updateQuantity;
    late ClearCart clearCart;

    setUp(() {
      repository = CartRepositoryImpl();
      addToCart = AddToCart(repository);
      updateQuantity = UpdateCartQuantity(repository);
      clearCart = ClearCart(repository);
    });

    test('adds new food item to cart', () {
      const item = CartItem(
        foodId: 'f1',
        restaurantId: 'r1',
        name: 'Burger',
        price: 250.0,
        quantity: 1,
      );

      addToCart(item);

      final items = repository.getItems();
      expect(items.length, 1);
      expect(items.first.foodId, 'f1');
      expect(items.first.quantity, 1);
    });

    test('adding the same food twice increments quantity', () {
      const item1 = CartItem(
        foodId: 'f1',
        restaurantId: 'r1',
        name: 'Burger',
        price: 250.0,
        quantity: 1,
      );
      const item2 = CartItem(
        foodId: 'f1',
        restaurantId: 'r1',
        name: 'Burger',
        price: 250.0,
        quantity: 2,
      );

      addToCart(item1);
      addToCart(item2);

      final items = repository.getItems();
      expect(items.length, 1);
      expect(items.first.foodId, 'f1');
      expect(items.first.quantity, 3);
      expect(items.first.totalPrice, 750.0);
    });

    test('updateQuantity updates existing item quantity', () {
      const item = CartItem(
        foodId: 'f1',
        restaurantId: 'r1',
        name: 'Burger',
        price: 200.0,
        quantity: 2,
      );
      addToCart(item);

      updateQuantity('f1', 5);

      final items = repository.getItems();
      expect(items.first.quantity, 5);
      expect(items.first.totalPrice, 1000.0);
    });

    test('updateQuantity with 0 or negative removes item from cart', () {
      const item = CartItem(
        foodId: 'f1',
        restaurantId: 'r1',
        name: 'Burger',
        price: 200.0,
        quantity: 2,
      );
      addToCart(item);

      updateQuantity('f1', 0);

      expect(repository.getItems(), isEmpty);
    });

    test('clearCart empties all items in the repository', () {
      addToCart(
        const CartItem(
          foodId: 'f1',
          restaurantId: 'r1',
          name: 'Burger',
          price: 200.0,
        ),
      );
      addToCart(
        const CartItem(
          foodId: 'f2',
          restaurantId: 'r1',
          name: 'Pizza',
          price: 350.0,
        ),
      );

      expect(repository.getItems().length, 2);

      clearCart();

      expect(repository.getItems(), isEmpty);
    });
  });

  group('CartCubit Tests', () {
    late CartRepository repository;
    late CartCubit cartCubit;

    setUp(() {
      repository = CartRepositoryImpl();
      cartCubit = CartCubit(
        repository: repository,
        getCartItems: GetCartItems(repository),
        addToCartUseCase: AddToCart(repository),
        updateCartQuantity: UpdateCartQuantity(repository),
        clearCartUseCase: ClearCart(repository),
      );
    });

    tearDown(() {
      cartCubit.close();
    });

    test('initial state has empty items', () {
      expect(cartCubit.state, isA<CartLoaded>());
      final loaded = cartCubit.state as CartLoaded;
      expect(loaded.isEmpty, isTrue);
    });

    test('addToCart adds item and immediately updates subtotal and total', () {
      const item = CartItem(
        foodId: 'f1',
        restaurantId: 'r1',
        name: 'Biryani',
        price: 300.0,
        quantity: 2,
      );

      cartCubit.addToCart(item);

      expect(cartCubit.state, isA<CartLoaded>());
      final loaded = cartCubit.state as CartLoaded;
      expect(loaded.items.length, 1);
      expect(loaded.items.first.quantity, 2);
      expect(loaded.subtotal, 600.0);
      expect(loaded.total, 640.0); // 600 + 40 delivery fee
      expect(loaded.totalItemCount, 2);
    });

    test('increase and decrease quantity changes item quantity in cubit', () {
      const item = CartItem(
        foodId: 'f1',
        restaurantId: 'r1',
        name: 'Biryani',
        price: 300.0,
        quantity: 2,
      );
      cartCubit.addToCart(item);

      cartCubit.increaseQuantity('f1');
      var loaded = cartCubit.state as CartLoaded;
      expect(loaded.items.first.quantity, 3);
      expect(loaded.subtotal, 900.0);

      cartCubit.decreaseQuantity('f1');
      loaded = cartCubit.state as CartLoaded;
      expect(loaded.items.first.quantity, 2);
      expect(loaded.subtotal, 600.0);
    });

    test('clearCart empties the cart', () {
      cartCubit.addToCart(
        const CartItem(
          foodId: 'f1',
          restaurantId: 'r1',
          name: 'Biryani',
          price: 300.0,
        ),
      );

      cartCubit.clearCart();

      final loaded = cartCubit.state as CartLoaded;
      expect(loaded.isEmpty, isTrue);
      expect(loaded.subtotal, 0.0);
      expect(loaded.total, 0.0);
    });
  });
}
