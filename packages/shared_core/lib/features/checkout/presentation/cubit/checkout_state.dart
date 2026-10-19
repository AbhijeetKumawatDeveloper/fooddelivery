import 'package:equatable/equatable.dart';

import '../../domain/entities/checkout_summary.dart';
import '../../domain/entities/delivery_address.dart';

class CheckoutState extends Equatable {
  final CheckoutSummary summary;
  final List<DeliveryAddress> addresses;
  final DeliveryAddress? selectedAddress;
  final String paymentMethod;
  final bool isProcessing;
  final String? errorMessage;
  final bool isPaymentSuccessful;

  const CheckoutState({
    this.summary = const CheckoutSummary(subtotal: 0, deliveryFee: 40),
    this.addresses = const [],
    this.selectedAddress,
    this.paymentMethod = 'Cash on Delivery',
    this.isProcessing = false,
    this.errorMessage,
    this.isPaymentSuccessful = false,
  });

  CheckoutState copyWith({
    CheckoutSummary? summary,
    List<DeliveryAddress>? addresses,
    DeliveryAddress? selectedAddress,
    String? paymentMethod,
    bool? isProcessing,
    String? errorMessage,
    bool clearError = false,
    bool? isPaymentSuccessful,
  }) {
    return CheckoutState(
      summary: summary ?? this.summary,
      addresses: addresses ?? this.addresses,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isPaymentSuccessful: isPaymentSuccessful ?? this.isPaymentSuccessful,
    );
  }

  @override
  List<Object?> get props => [
    summary,
    addresses,
    selectedAddress,
    paymentMethod,
    isProcessing,
    errorMessage,
    isPaymentSuccessful,
  ];
}
