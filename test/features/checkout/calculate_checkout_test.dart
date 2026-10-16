import 'package:flutter_test/flutter_test.dart';
import 'package:fooddelivery/features/checkout/data/repositories/checkout_repository_impl.dart';
import 'package:fooddelivery/features/checkout/domain/entities/delivery_address.dart';
import 'package:fooddelivery/features/checkout/domain/usecases/calculate_checkout.dart';
import 'package:fooddelivery/features/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('CalculateCheckout UseCase Tests', () {
    late CalculateCheckout useCase;

    setUp(() {
      useCase = CalculateCheckout();
    });

    test(
      'calculates correct total with subtotal, deliveryFee, tax, and discount',
      () {
        final summary = useCase(
          subtotal: 500.0,
          deliveryFee: 40.0,
          tax: 25.0,
          discount: 50.0,
        );

        // 500 + 40 + 25 - 50 = 515.0
        expect(summary.total, 515.0);
        expect(summary.subtotal, 500.0);
        expect(summary.deliveryFee, 40.0);
        expect(summary.tax, 25.0);
        expect(summary.discount, 50.0);
      },
    );

    test('throws ArgumentError when any amount is negative', () {
      expect(
        () => useCase(subtotal: -10, deliveryFee: 40),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => useCase(subtotal: 100, deliveryFee: -5),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => useCase(subtotal: 100, deliveryFee: 40, discount: -10),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => useCase(subtotal: 100, deliveryFee: 40, tax: -2),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError when discount exceeds the order total', () {
      expect(
        () => useCase(
          subtotal: 200,
          deliveryFee: 40,
          tax: 10,
          discount: 300, // 300 > 250
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('CheckoutRepository & Address Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('default addresses are present and selectable', () async {
      final repo = CheckoutRepositoryImpl();
      final addresses = repo.getAddresses();

      expect(addresses.length, greaterThanOrEqualTo(2));
      expect(repo.getSelectedAddress(), isNotNull);

      await repo.setSelectedAddress('addr_2');
      expect(repo.getSelectedAddress()?.id, 'addr_2');
    });

    test('addAddress and deleteAddress update repository', () async {
      final repo = CheckoutRepositoryImpl();
      const newAddress = DeliveryAddress(
        id: 'addr_new',
        label: 'Friends Place',
        fullAddress: 'Apartment 12, Koramangala',
        city: 'Bengaluru',
        pincode: '560034',
        phone: '+91 99887 76655',
      );

      await repo.saveAddress(newAddress);
      expect(repo.getAddresses().any((a) => a.id == 'addr_new'), isTrue);

      await repo.deleteAddress('addr_new');
      expect(repo.getAddresses().any((a) => a.id == 'addr_new'), isFalse);
    });
  });

  group('CheckoutCubit Tests', () {
    late CheckoutCubit cubit;
    late CalculateCheckout useCase;
    late CheckoutRepositoryImpl repository;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      useCase = CalculateCheckout();
      repository = CheckoutRepositoryImpl();
      cubit = CheckoutCubit(calculateCheckout: useCase, repository: repository);
    });

    tearDown(() {
      cubit.close();
    });

    test('init sets initial summary and selected address', () {
      cubit.init(subtotal: 400.0, deliveryFee: 40.0, tax: 20.0, discount: 20.0);
      expect(cubit.state.summary.total, 440.0);
      expect(cubit.state.selectedAddress, isNotNull);
    });

    test('processPayment fails when subtotal is 0', () async {
      cubit.init(subtotal: 0.0);
      final success = await cubit.processPayment();
      expect(success, isFalse);
      expect(cubit.state.errorMessage, 'Empty carts cannot be submitted.');
    });

    test('processPayment succeeds for valid cart and address', () async {
      cubit.init(subtotal: 300.0, deliveryFee: 40.0);
      final success = await cubit.processPayment();
      expect(success, isTrue);
      expect(cubit.state.isPaymentSuccessful, isTrue);
    });
  });
}
