import 'package:equatable/equatable.dart';

import '../../domain/entities/food.dart';

sealed class FoodState extends Equatable {
  const FoodState();

  @override
  List<Object?> get props => [];
}

class FoodInitial extends FoodState {
  const FoodInitial();
}

class FoodLoading extends FoodState {
  const FoodLoading();
}

class FoodLoaded extends FoodState {
  final List<Food> foods;

  const FoodLoaded(this.foods);

  List<String> get categories {
    final set = <String>{};
    for (final food in foods) {
      if (food.category.isNotEmpty) {
        set.add(food.category);
      }
    }
    return set.toList();
  }

  List<Food> getFoodsByCategory(String category) {
    return foods.where((f) => f.category == category).toList();
  }

  @override
  List<Object?> get props => [foods];
}

class FoodFailure extends FoodState {
  final String message;

  const FoodFailure(this.message);

  @override
  List<Object?> get props => [message];
}
