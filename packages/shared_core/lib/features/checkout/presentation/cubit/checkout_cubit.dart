import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/delivery_address.dart';
import '../../domain/repositories/checkout_repository.dart';
import '../../domain/usecases/calculate_checkout.dart';
import 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  final CalculateCheckout calculateCheckout;
  final CheckoutRepository repository;

  CheckoutCubit({required this.calculateCheckout, required this.repository})
    : super(const CheckoutState());

  void init({
    required double subtotal,
    double deliveryFee = 40,
    double discount = 0,
    double tax = 0,
  }) {
    final summary = calculateCheckout(
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      discount: discount,
      tax: tax,
    );

    final addresses = repository.getAddresses();
    final selected = repository.getSelectedAddress();

    emit(
      state.copyWith(
        summary: summary,
        addresses: addresses,
        selectedAddress: selected,
        clearError: true,
      ),
    );
  }

  void applyDiscount(double discount) {
    try {
      final updated = calculateCheckout(
        subtotal: state.summary.subtotal,
        deliveryFee: state.summary.deliveryFee,
        discount: discount,
        tax: state.summary.tax,
      );
      emit(state.copyWith(summary: updated, clearError: true));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  void selectAddress(String addressId) {
    repository.setSelectedAddress(addressId);
    final selected = repository.getSelectedAddress();
    emit(state.copyWith(selectedAddress: selected));
  }

  Future<void> addAddress(DeliveryAddress address) async {
    await repository.saveAddress(address);
    final addresses = repository.getAddresses();
    final selected = repository.getSelectedAddress();
    emit(state.copyWith(addresses: addresses, selectedAddress: selected));
  }

  Future<void> deleteAddress(String addressId) async {
    await repository.deleteAddress(addressId);
    final addresses = repository.getAddresses();
    final selected = repository.getSelectedAddress();
    emit(state.copyWith(addresses: addresses, selectedAddress: selected));
  }

  void selectPaymentMethod(String method) {
    emit(state.copyWith(paymentMethod: method));
  }

  Future<bool> processPayment() async {
    if (state.summary.subtotal <= 0) {
      emit(state.copyWith(errorMessage: 'Empty carts cannot be submitted.'));
      return false;
    }

    if (state.selectedAddress == null) {
      emit(state.copyWith(errorMessage: 'Please select a delivery address.'));
      return false;
    }

    emit(state.copyWith(isProcessing: true, clearError: true));

    try {
      // Simulate Razorpay/Online payment gateway or COD verification
      await Future.delayed(const Duration(milliseconds: 300));
      emit(
        state.copyWith(
          isProcessing: false,
          isPaymentSuccessful: true,
          clearError: true,
        ),
      );
      return true;
    } catch (e) {
      emit(
        state.copyWith(
          isProcessing: false,
          isPaymentSuccessful: false,
          errorMessage:
              'Payment failed. Please try again or choose another method.',
        ),
      );
      return false;
    }
  }
}
