import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/restaurant.dart';
import '../../domain/repositories/restaurant_repository.dart';
import '../datasources/restaurant_local_datasource.dart';
import '../datasources/restaurant_remote_datasource.dart';
import '../models/restaurant_model.dart';

class RestaurantRepositoryImpl implements RestaurantRepository {
  final RestaurantRemoteDataSource remoteDataSource;
  final RestaurantLocalDataSource? localDataSource;

  const RestaurantRepositoryImpl(this.remoteDataSource, [this.localDataSource]);

  @override
  Future<List<Restaurant>> getRestaurants() async {
    try {
      final records = await remoteDataSource.getRestaurants();

      if (records.isNotEmpty) {
        return records
            .map((record) => RestaurantModel.fromMap(record))
            .toList(growable: false);
      }

      // If remote has no documents yet, fall back to local if available
      if (localDataSource != null) {
        final localRecords = await localDataSource!.getRestaurants();
        return localRecords
            .map((record) => RestaurantModel.fromMap(record))
            .toList(growable: false);
      }

      return const [];
    } on FormatException {
      throw const DataException('Restaurant data has an invalid format.');
    } catch (_) {
      // If remote fetch fails (e.g. offline or uninitialized in local tests), fall back if available
      if (localDataSource != null) {
        try {
          final localRecords = await localDataSource!.getRestaurants();
          return localRecords
              .map((record) => RestaurantModel.fromMap(record))
              .toList(growable: false);
        } catch (_) {}
      }

      throw const DataException('Unable to retrieve restaurants.');
    }
  }
}
