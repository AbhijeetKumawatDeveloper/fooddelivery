import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fooddelivery/core/errors/app_exception.dart';
import 'package:fooddelivery/features/restaurants/data/datasources/restaurant_remote_datasource.dart';
import 'package:fooddelivery/features/restaurants/data/repositories/restaurant_repository_impl.dart';

class MockRestaurantRemoteDataSource extends Mock
    implements RestaurantRemoteDataSource {}

void main() {
  late MockRestaurantRemoteDataSource dataSource;
  late RestaurantRepositoryImpl repository;

  setUp(() {
    dataSource = MockRestaurantRemoteDataSource();
    repository = RestaurantRepositoryImpl(dataSource);
  });

  test('converts raw records into restaurant entities', () async {
    when(() => dataSource.getRestaurants()).thenAnswer(
      (_) async => [
        {
          'id': 'r1',
          'name': 'Burger House',
          'cuisine': 'Fast Food',
          'rating': 4.5,
          'deliveryTime': 25,
          'image': 'assets/images/Burger.png',
        },
      ],
    );

    final result = await repository.getRestaurants();

    expect(result, hasLength(1));
    expect(result.first.name, 'Burger House');
    expect(result.first.rating, 4.5);
  });

  test('reports invalid data as a controlled exception', () async {
    when(() => dataSource.getRestaurants()).thenAnswer(
      (_) async => [
        {'id': 'r1'},
      ],
    );

    expect(() => repository.getRestaurants(), throwsA(isA<DataException>()));
  });
}
