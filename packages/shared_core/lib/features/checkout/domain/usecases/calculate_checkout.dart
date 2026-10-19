import '../entities/checkout_summary.dart';

class CalculateCheckout {
  CheckoutSummary call({
    required double subtotal,
    required double deliveryFee,
    double discount = 0,
    double tax = 0,
  }) {
    if (subtotal < 0 || deliveryFee < 0 || discount < 0 || tax < 0) {
      throw ArgumentError('Amounts cannot be negative.');
    }

    if (discount > subtotal + deliveryFee + tax) {
      throw ArgumentError('Discount exceeds the order total.');
    }

    return CheckoutSummary(
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      discount: discount,
      tax: tax,
    );
  }
}
