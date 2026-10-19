import 'package:equatable/equatable.dart';

import '../../domain/entities/restaurant.dart';

sealed class RestaurantState extends Equatable {
  const RestaurantState();

  @override
  List<Object?> get props => [];
}

class RestaurantInitial extends RestaurantState {
  const RestaurantInitial();
}

class RestaurantLoading extends RestaurantState {
  const RestaurantLoading();
}

class RestaurantLoaded extends RestaurantState {
  final List<Restaurant> restaurants;

  const RestaurantLoaded(this.restaurants);

  @override
  List<Object?> get props => [restaurants];
}

class RestaurantFailure extends RestaurantState {
  final String message;

  const RestaurantFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// Backwards-compatible alias if referenced elsewhere
typedef RestaurantError = RestaurantFailure;
