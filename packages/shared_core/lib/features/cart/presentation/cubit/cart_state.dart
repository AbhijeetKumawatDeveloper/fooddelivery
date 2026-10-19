import 'package:equatable/equatable.dart';

import '../../domain/entities/cart_item.dart';

sealed class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {
  const CartInitial();
}

class CartLoading extends CartState {
  const CartLoading();
}

class CartLoaded extends CartState {
  final List<CartItem> items;
  final double deliveryFee;

  const CartLoaded({this.items = const [], this.deliveryFee = 40.0});

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get total => isEmpty ? 0.0 : subtotal + deliveryFee;

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  int get totalQuantity => totalItemCount;

  bool get isEmpty => items.isEmpty;

  @override
  List<Object?> get props => [items, deliveryFee];
}

class CartError extends CartState {
  final String message;

  const CartError(this.message);

  @override
  List<Object?> get props => [message];
}
