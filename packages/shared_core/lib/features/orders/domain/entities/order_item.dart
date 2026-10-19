import 'package:equatable/equatable.dart';

class OrderItem extends Equatable {
  final String foodId;
  final String name;
  final double price;
  final int quantity;
  final String image;

  const OrderItem({
    required this.foodId,
    required this.name,
    required this.price,
    required this.quantity,
    this.image = '',
  });

  double get totalPrice => price * quantity;

  @override
  List<Object?> get props => [foodId, name, price, quantity, image];
}
