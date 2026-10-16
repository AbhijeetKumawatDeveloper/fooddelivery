import 'package:equatable/equatable.dart';

class CheckoutSummary extends Equatable {
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double tax;

  const CheckoutSummary({
    required this.subtotal,
    required this.deliveryFee,
    this.discount = 0,
    this.tax = 0,
  });

  double get total => subtotal + deliveryFee + tax - discount;

  @override
  List<Object> get props => [subtotal, deliveryFee, discount, tax];
}
