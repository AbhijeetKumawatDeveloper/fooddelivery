import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fooddelivery/core/errors/app_exception.dart';
import 'package:fooddelivery/features/foods/data/datasources/food_local_datasource.dart';
import 'package:fooddelivery/features/foods/data/datasources/food_remote_datasource.dart';
import 'package:fooddelivery/features/foods/data/models/food_model.dart';
import 'package:fooddelivery/features/foods/data/repositories/food_repository_impl.dart';
import 'package:fooddelivery/features/foods/domain/entities/food.dart';
import 'package:fooddelivery/features/foods/domain/repositories/food_repository.dart';
import 'package:fooddelivery/features/foods/domain/usecases/get_foods_by_restaurant.dart';
import 'package:fooddelivery/features/foods/presentation/cubit/food_cubit.dart';
import 'package:fooddelivery/features/foods/presentation/cubit/food_state.dart';
import 'package:mocktail/mocktail.dart';

class MockFoodRemoteDataSource extends Mock implements FoodRemoteDataSource {}

class MockFoodRepository extends Mock implements FoodRepository {}

void main() {
  group('FoodModel Tests', () {
    test('fromMap parses valid food data correctly', () {
      final map = {
        'id': 'f1',
        'restaurantId': 'r1',
        'name': 'Classic Burger',
        'description': 'Chicken patty with fresh vegetables',
        'price': 299,
        'image': 'assets/images/Burger.png',
        'category': 'Burgers',
        'isAvailable': true,
      };

      final model = FoodModel.fromMap(map);

      expect(model.id, 'f1');
      expect(model.restaurantId, 'r1');
      expect(model.name, 'Classic Burger');
      expect(model.description, 'Chicken patty with fresh vegetables');
      expect(model.price, 299.0);
      expect(model.category, 'Burgers');
      expect(model.isAvailable, isTrue);
    });

    test('fromMap throws FormatException when required fields are missing', () {
      final invalidMap = {
        'id': 'f1',
        // missing restaurantId, name, price
      };

      expect(
        () => FoodModel.fromMap(invalidMap),
        throwsA(isA<FormatException>()),
      );
    });

    test('toMap produces serializable map', () {
      const model = FoodModel(
        id: 'f1',
        restaurantId: 'r1',
        name: 'Burger',
        description: 'Juicy burger',
        price: 249.0,
        image: 'assets/images/Burger.png',
        category: 'Burgers',
      );

      final map = model.toMap();
      expect(map['id'], 'f1');
      expect(map['name'], 'Burger');
      expect(map['price'], 249.0);
    });
  });

  group('FoodRepositoryImpl Tests', () {
    late MockFoodRemoteDataSource remoteDataSource;
    late FoodRepositoryImpl repository;

    setUp(() {
      remoteDataSource = MockFoodRemoteDataSource();
      repository = FoodRepositoryImpl(remoteDataSource);
    });

    test(
      'getFoodsByRestaurant returns mapped foods from remote data source',
      () async {
        when(() => remoteDataSource.getFoodsByRestaurant('r1')).thenAnswer(
          (_) async => [
            {
              'id': 'f1',
              'restaurantId': 'r1',
              'name': 'Cheeseburger',
              'description': 'Melted cheddar on grilled beef',
              'price': 279,
              'image': 'assets/images/Burger.png',
              'category': 'Burgers',
              'isAvailable': true,
            },
          ],
        );

        final foods = await repository.getFoodsByRestaurant('r1');

        expect(foods, hasLength(1));
        expect(foods.first.name, 'Cheeseburger');
        expect(foods.first.price, 279.0);
      },
    );

    test(
      'getFoodsByRestaurant falls back to local data source if remote is empty',
      () async {
        when(() => remoteDataSource.getFoodsByRestaurant('r1'))
            .thenAnswer((_) async => []);

        final repoWithLocal = FoodRepositoryImpl(
          remoteDataSource,
          const FoodLocalDataSourceImpl(),
        );

        final foods = await repoWithLocal.getFoodsByRestaurant('r1');

        expect(foods, isNotEmpty);
        expect(foods.length, 3);
        expect(foods.first.name, 'Burger House Special');
      },
    );

    test(
      'getFoodsByRestaurant throws DataException on malformed data',
      () async {
        when(() => remoteDataSource.getFoodsByRestaurant('r1')).thenAnswer(
          (_) async => [
            {'id': 'f1'}, // invalid schema
          ],
        );

        expect(
          () => repository.getFoodsByRestaurant('r1'),
          throwsA(isA<DataException>()),
        );
      },
    );
  });

  group('FoodCubit Tests', () {
    late MockFoodRepository repository;
    late FoodCubit cubit;

    setUp(() {
      repository = MockFoodRepository();
      cubit = FoodCubit(GetFoodsByRestaurant(repository));
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is FoodInitial', () {
      expect(cubit.state, const FoodInitial());
    });

    test(
      'loadFoods emits [FoodLoading, FoodLoaded] on success with categories',
      () async {
        final sampleFoods = [
          const Food(
            id: 'f1',
            restaurantId: 'r1',
            name: 'Burger',
            description: 'Classic',
            price: 200,
            image: '',
            category: 'Burgers',
          ),
          const Food(
            id: 'f2',
            restaurantId: 'r1',
            name: 'Fries',
            description: 'Crispy',
            price: 99,
            image: '',
            category: 'Sides',
          ),
        ];

        when(() => repository.getFoodsByRestaurant('r1'))
            .thenAnswer((_) async => sampleFoods);

        unawaited(
          expectLater(
            cubit.stream,
            emitsInOrder([
              const FoodLoading(),
              predicate<FoodState>((state) {
                return state is FoodLoaded &&
                    state.foods.length == 2 &&
                    state.categories.contains('Burgers') &&
                    state.categories.contains('Sides');
              }),
            ]),
          ),
        );

        await cubit.loadFoods('r1');
        expect(cubit.state, isA<FoodLoaded>());
      },
    );

    test('loadFoods emits [FoodLoading, FoodFailure] when empty', () async {
      when(() => repository.getFoodsByRestaurant('r1'))
          .thenAnswer((_) async => []);

      unawaited(
        expectLater(
          cubit.stream,
          emitsInOrder([
            const FoodLoading(),
            const FoodFailure('No items available for this restaurant.'),
          ]),
        ),
      );

      await cubit.loadFoods('r1');
    });

    test(
      'loadFoods emits [FoodLoading, FoodFailure] on DataException',
      () async {
        when(() => repository.getFoodsByRestaurant('r1'))
            .thenThrow(const DataException('Server error occurred'));

        unawaited(
          expectLater(
            cubit.stream,
            emitsInOrder([
              const FoodLoading(),
              const FoodFailure('Server error occurred'),
            ]),
          ),
        );

        await cubit.loadFoods('r1');
      },
    );
  });
}
