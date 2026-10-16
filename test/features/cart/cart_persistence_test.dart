import 'package:flutter_test/flutter_test.dart';
import 'package:fooddelivery/features/cart/data/datasources/cart_local_datasource.dart';
import 'package:fooddelivery/features/cart/data/models/cart_item_model.dart';
import 'package:fooddelivery/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:fooddelivery/features/cart/domain/entities/cart_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('CartItemModel Tests', () {
    test('toMap and fromMap serialize and deserialize correctly', () {
      const model = CartItemModel(
        foodId: 'f1',
        restaurantId: 'r1',
        name: 'Burger Deluxe',
        price: 250.0,
        quantity: 2,
        image: 'assets/images/Burger.png',
      );

      final map = model.toMap();
      final fromMap = CartItemModel.fromMap(map);

      expect(fromMap.foodId, 'f1');
      expect(fromMap.restaurantId, 'r1');
      expect(fromMap.name, 'Burger Deluxe');
      expect(fromMap.price, 250.0);
      expect(fromMap.quantity, 2);
      expect(fromMap.image, 'assets/images/Burger.png');
      expect(fromMap.totalPrice, 500.0);
    });

    test('fromEntity converts CartItem correctly', () {
      const entity = CartItem(
        foodId: 'f2',
        restaurantId: 'r1',
        name: 'Biryani Special',
        price: 320.0,
        quantity: 3,
      );

      final model = CartItemModel.fromEntity(entity);
      expect(model.foodId, 'f2');
      expect(model.name, 'Biryani Special');
      expect(model.price, 320.0);
      expect(model.quantity, 3);
    });
  });

  group('CartLocalDataSource Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('in-memory fallback works when SharedPreferences is null', () async {
      final dataSource = CartLocalDataSourceImpl();

      expect(dataSource.getCartItems(), isEmpty);

      const item = CartItem(
        foodId: 'f1',
        restaurantId: 'r1',
        name: 'Veg Burger',
        price: 150.0,
        quantity: 1,
      );

      await dataSource.saveCartItems([item]);

      final items = dataSource.getCartItems();
      expect(items.length, 1);
      expect(items.first.name, 'Veg Burger');

      await dataSource.clear();
      expect(dataSource.getCartItems(), isEmpty);
    });

    test('persists items to SharedPreferences across instances', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final ds1 = CartLocalDataSourceImpl(prefs: prefs);
      const item1 = CartItem(
        foodId: 'f1',
        restaurantId: 'r1',
        name: 'Paneer Wrap',
        price: 180.0,
        quantity: 2,
      );

      await ds1.saveCartItems([item1]);

      // Recreate data source to simulate app restart
      final ds2 = CartLocalDataSourceImpl(prefs: prefs);
      final loaded = ds2.getCartItems();

      expect(loaded.length, 1);
      expect(loaded.first.foodId, 'f1');
      expect(loaded.first.name, 'Paneer Wrap');
      expect(loaded.first.price, 180.0);
      expect(loaded.first.quantity, 2);

      await ds2.clear();
      final ds3 = CartLocalDataSourceImpl(prefs: prefs);
      expect(ds3.getCartItems(), isEmpty);
    });
  });

  group('CartRepositoryImpl Persistence Integration Tests', () {
    test('hydrates items from local data source at construction', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final localDataSource = CartLocalDataSourceImpl(prefs: prefs);

      const item = CartItem(
        foodId: 'f99',
        restaurantId: 'r1',
        name: 'Cold Drink',
        price: 60.0,
        quantity: 4,
      );
      await localDataSource.saveCartItems([item]);

      final repository = CartRepositoryImpl(localDataSource);
      final items = repository.getItems();

      expect(items.length, 1);
      expect(items.first.foodId, 'f99');
      expect(items.first.name, 'Cold Drink');
    });

    test(
      'saveItems updates cache and writes through to localDataSource',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final localDataSource = CartLocalDataSourceImpl(prefs: prefs);
        final repository = CartRepositoryImpl(localDataSource);

        const item = CartItem(
          foodId: 'f10',
          restaurantId: 'r2',
          name: 'Pasta Alfredo',
          price: 290.0,
          quantity: 1,
        );

        repository.saveItems([item]);

        expect(repository.getItems().length, 1);

        // Verify written to storage
        final reloadedFromStorage = localDataSource.getCartItems();
        expect(reloadedFromStorage.length, 1);
        expect(reloadedFromStorage.first.name, 'Pasta Alfredo');
      },
    );
  });
}
