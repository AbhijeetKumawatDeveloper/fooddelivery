import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/food.dart';
import '../../domain/repositories/food_repository.dart';
import '../datasources/food_local_datasource.dart';
import '../datasources/food_remote_datasource.dart';
import '../models/food_model.dart';

class FoodRepositoryImpl implements FoodRepository {
  final FoodRemoteDataSource remoteDataSource;
  final FoodLocalDataSource? localDataSource;

  const FoodRepositoryImpl(this.remoteDataSource, [this.localDataSource]);

  @override
  Future<List<Food>> getFoodsByRestaurant(String restaurantId) async {
    try {
      final records = await remoteDataSource.getFoodsByRestaurant(restaurantId);

      if (records.isNotEmpty) {
        return records
            .map((record) => FoodModel.fromMap(record))
            .toList(growable: false);
      }

      if (localDataSource != null) {
        final localRecords = await localDataSource!.getFoodsByRestaurant(
          restaurantId,
        );
        return localRecords
            .map((record) => FoodModel.fromMap(record))
            .toList(growable: false);
      }

      return const [];
    } on FormatException {
      throw const DataException('Food data has an invalid format.');
    } catch (_) {
      if (localDataSource != null) {
        try {
          final localRecords = await localDataSource!.getFoodsByRestaurant(
            restaurantId,
          );
          return localRecords
              .map((record) => FoodModel.fromMap(record))
              .toList(growable: false);
        } catch (_) {}
      }

      throw const DataException('Unable to retrieve food menu.');
    }
  }
}
