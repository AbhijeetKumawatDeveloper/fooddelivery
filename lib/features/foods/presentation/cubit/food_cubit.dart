import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/usecases/get_foods_by_restaurant.dart';
import 'food_state.dart';

class FoodCubit extends Cubit<FoodState> {
  final GetFoodsByRestaurant getFoodsByRestaurant;

  FoodCubit(this.getFoodsByRestaurant) : super(const FoodInitial());

  Future<void> loadFoods(String restaurantId) async {
    emit(const FoodLoading());

    try {
      final foods = await getFoodsByRestaurant(restaurantId);

      if (isClosed) return;

      if (foods.isEmpty) {
        emit(const FoodFailure('No items available for this restaurant.'));
        return;
      }

      emit(FoodLoaded(foods));
    } on DataException catch (e) {
      if (!isClosed) {
        emit(FoodFailure(e.message));
      }
    } catch (_) {
      if (!isClosed) {
        emit(const FoodFailure('Unable to load menu. Please try again.'));
      }
    }
  }
}
