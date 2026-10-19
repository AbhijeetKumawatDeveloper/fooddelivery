import 'package:equatable/equatable.dart';

class Food extends Equatable {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final double price;
  final String image;
  final String category;
  final bool isAvailable;

  const Food({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
    this.isAvailable = true,
  });

  @override
  List<Object?> get props => [
    id,
    restaurantId,
    name,
    description,
    price,
    image,
    category,
    isAvailable,
  ];
}
