import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  final String foodId;
  final String restaurantId;
  final String name;
  final double price;
  final int quantity;
  final String image;

  const CartItem({
    String? id,
    String? foodId,
    required this.restaurantId,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.image = '',
  }) : foodId = foodId ?? id ?? '';

  String get id => foodId;

  double get totalPrice => price * quantity;

  CartItem copyWith({
    String? foodId,
    String? restaurantId,
    String? name,
    double? price,
    int? quantity,
    String? image,
  }) {
    return CartItem(
      foodId: foodId ?? this.foodId,
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      image: image ?? this.image,
    );
  }

  @override
  List<Object?> get props => [
    foodId,
    restaurantId,
    name,
    price,
    quantity,
    image,
  ];
}
