import 'package:equatable/equatable.dart';

class Restaurant extends Equatable {
  final String id;
  final String name;
  final String cuisine;
  final double rating;
  final int deliveryTime;
  final String image;

  const Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.rating,
    required this.deliveryTime,
    required this.image,
  });

  @override
  List<Object> get props => [id, name, cuisine, rating, deliveryTime, image];
}
