import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fooddelivery/core/errors/app_exception.dart';
import 'package:fooddelivery/features/restaurants/data/datasources/restaurant_local_datasource.dart';
import 'package:fooddelivery/features/restaurants/data/datasources/restaurant_remote_datasource.dart';
import 'package:fooddelivery/features/restaurants/data/models/restaurant_model.dart';
import 'package:fooddelivery/features/restaurants/data/repositories/restaurant_repository_impl.dart';
import 'package:fooddelivery/features/restaurants/domain/entities/restaurant.dart';
import 'package:fooddelivery/features/restaurants/domain/repositories/restaurant_repository.dart';
import 'package:fooddelivery/features/restaurants/domain/usecases/get_restaurants.dart';
import 'package:fooddelivery/features/restaurants/presentation/cubit/restaurant_cubit.dart';
import 'package:fooddelivery/features/restaurants/presentation/cubit/restaurant_state.dart';

class MockRestaurantRemoteDataSource extends Mock
    implements RestaurantRemoteDataSource {}

class MockFailingRestaurantRepository implements RestaurantRepository {
  final Exception? exception;

  MockFailingRestaurantRepository([this.exception]);

  @override
  Future<List<Restaurant>> getRestaurants() async {
    throw exception ?? const DataException('Unable to retrieve restaurants.');
  }
}

class MockEmptyRestaurantRepository implements RestaurantRepository {
  @override
  Future<List<Restaurant>> getRestaurants() async => [];
}

void main() {
  group('RestaurantModel Tests', () {
    test('fromMap parses map into RestaurantModel correctly', () {
      final map = {
        'id': 'r1',
        'name': 'Burger House',
        'cuisine': 'Burgers',
        'rating': 4.5,
        'deliveryTime': 25,
        'image': 'assets/images/Burger.png',
      };

      final model = RestaurantModel.fromMap(map);

      expect(model.id, 'r1');
      expect(model.name, 'Burger House');
      expect(model.cuisine, 'Burgers');
      expect(model.rating, 4.5);
      expect(model.deliveryTime, 25);
      expect(model.image, 'assets/images/Burger.png');
    });

    test('fromMap throws FormatException when fields are invalid', () {
      final invalidMap = {
        'id': 'r1',
        // missing required fields
      };

      expect(
        () => RestaurantModel.fromMap(invalidMap),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('Restaurant Data Source and Repository Tests', () {
    test('RestaurantLocalDataSourceImpl returns raw restaurant records after delay', () async {
      const dataSource = RestaurantLocalDataSourceImpl();
      final records = await dataSource.getRestaurants();

      expect(records, isNotEmpty);
      expect(records.length, 3);
      expect(records.first['name'], 'Burger House');
    });

    test('RestaurantRepositoryImpl forwards call to remote data source and maps to entities', () async {
      final remoteDataSource = MockRestaurantRemoteDataSource();
      when(() => remoteDataSource.getRestaurants()).thenAnswer(
        (_) async => [
          {
            'id': 'r1',
            'name': 'Burger House',
            'cuisine': 'Burgers',
            'rating': 4.5,
            'deliveryTime': 25,
            'image': 'assets/images/Burger.png',
          },
        ],
      );

      final repository = RestaurantRepositoryImpl(remoteDataSource);
      final restaurants = await repository.getRestaurants();

      expect(restaurants, isNotEmpty);
      expect(restaurants.first, isA<Restaurant>());
      expect(restaurants.first.name, 'Burger House');
    });

    test('RestaurantRepositoryImpl falls back to local data source when remote is empty', () async {
      final remoteDataSource = MockRestaurantRemoteDataSource();
      when(() => remoteDataSource.getRestaurants()).thenAnswer((_) async => []);

      const localDataSource = RestaurantLocalDataSourceImpl();
      final repository = RestaurantRepositoryImpl(
        remoteDataSource,
        localDataSource,
      );
      final restaurants = await repository.getRestaurants();

      expect(restaurants, isNotEmpty);
      expect(restaurants.length, 3);
      expect(restaurants.first.name, 'Burger House');
    });

    test('GetRestaurants use case calls repository', () async {
      final remoteDataSource = MockRestaurantRemoteDataSource();
      when(() => remoteDataSource.getRestaurants()).thenAnswer(
        (_) async => [
          {
            'id': 'r1',
            'name': 'Burger House',
            'cuisine': 'Burgers',
            'rating': 4.5,
            'deliveryTime': 25,
            'image': 'assets/images/Burger.png',
          },
        ],
      );

      final repository = RestaurantRepositoryImpl(remoteDataSource);
      final useCase = GetRestaurants(repository);

      final result = await useCase();

      expect(result.length, 1);
      expect(result.first.id, 'r1');
    });
  });

  group('RestaurantCubit Tests', () {
    test('initial state is RestaurantInitial', () {
      final remoteDataSource = MockRestaurantRemoteDataSource();
      final repository = RestaurantRepositoryImpl(remoteDataSource);
      final cubit = RestaurantCubit(GetRestaurants(repository));

      expect(cubit.state, const RestaurantInitial());
      cubit.close();
    });

    test(
      'loadRestaurants emits [RestaurantLoading, RestaurantLoaded] on success',
      () async {
        final remoteDataSource = MockRestaurantRemoteDataSource();
        when(() => remoteDataSource.getRestaurants()).thenAnswer(
          (_) async => [
            {
              'id': 'r1',
              'name': 'Burger House',
              'cuisine': 'Burgers',
              'rating': 4.5,
              'deliveryTime': 25,
              'image': 'assets/images/Burger.png',
            },
            {
              'id': 'r2',
              'name': 'Pizza Point',
              'cuisine': 'Pizza',
              'rating': 4.3,
              'deliveryTime': 30,
              'image': 'assets/images/Burger.png',
            },
            {
              'id': 'r3',
              'name': 'Biryani House',
              'cuisine': 'Indian',
              'rating': 4.6,
              'deliveryTime': 35,
              'image': 'assets/images/Biryani.png',
            },
          ],
        );

        final repository = RestaurantRepositoryImpl(remoteDataSource);
        final cubit = RestaurantCubit(GetRestaurants(repository));

        expectLater(
          cubit.stream,
          emitsInOrder([
            const RestaurantLoading(),
            predicate<RestaurantState>((state) {
              return state is RestaurantLoaded &&
                  state.restaurants.length == 3 &&
                  state.restaurants.first.name == 'Burger House';
            }),
          ]),
        );

        await cubit.loadRestaurants();

        expect(cubit.state, isA<RestaurantLoaded>());
        await cubit.close();
      },
    );

    test('loadRestaurants emits [RestaurantLoading, RestaurantFailure] on DataException', () async {
      final repository = MockFailingRestaurantRepository(
        const DataException('Unable to retrieve restaurants.'),
      );
      final cubit = RestaurantCubit(GetRestaurants(repository));

      expectLater(
        cubit.stream,
        emitsInOrder([
          const RestaurantLoading(),
          const RestaurantFailure('Unable to retrieve restaurants.'),
        ]),
      );

      await cubit.loadRestaurants();

      expect(cubit.state, isA<RestaurantFailure>());
      await cubit.close();
    });

    test('loadRestaurants emits [RestaurantLoading, RestaurantFailure] on empty list', () async {
      final repository = MockEmptyRestaurantRepository();
      final cubit = RestaurantCubit(GetRestaurants(repository));

      expectLater(
        cubit.stream,
        emitsInOrder([
          const RestaurantLoading(),
          const RestaurantFailure('No restaurants are available right now.'),
        ]),
      );

      await cubit.loadRestaurants();

      expect(cubit.state, isA<RestaurantFailure>());
      await cubit.close();
    });
  });
}
