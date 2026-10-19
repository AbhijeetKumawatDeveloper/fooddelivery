import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/usecases/get_restaurants.dart';
import 'restaurant_state.dart';

class RestaurantCubit extends Cubit<RestaurantState> {
  final GetRestaurants getRestaurants;

  RestaurantCubit(this.getRestaurants) : super(const RestaurantInitial());

  Future<void> loadRestaurants() async {
    emit(const RestaurantLoading());

    try {
      final restaurants = await getRestaurants();

      if (isClosed) return;

      if (restaurants.isEmpty) {
        emit(
          const RestaurantFailure('No restaurants are available right now.'),
        );
        return;
      }

      emit(RestaurantLoaded(restaurants));
    } on DataException catch (error) {
      if (!isClosed) {
        emit(RestaurantFailure(error.message));
      }
    } catch (_) {
      if (!isClosed) {
        emit(
          const RestaurantFailure('Something went wrong. Please try again.'),
        );
      }
    }
  }
}
