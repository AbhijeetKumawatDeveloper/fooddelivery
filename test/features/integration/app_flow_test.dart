import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fooddelivery/core/di/injection.dart' as di;
import 'package:fooddelivery/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:fooddelivery/features/cart/presentation/cubit/cart_state.dart';
import 'package:fooddelivery/main.dart';

void main() {
  setUp(() async {
    await di.getIt.reset();
    await di.setupDependencies();
  });

  tearDown(() async {
    await di.getIt.reset();
  });

  testWidgets(
    'Integration Flow: Restaurants load, cart adds items with quantity, preserves state across navigation',
    (WidgetTester tester) async {
      // 1. Launch App
      await tester.pumpWidget(const FoodGoApp());

      expect(find.text('FoodGo'), findsOneWidget);

      // Let async restaurant load finish (300ms delayed in local datasource)
      await tester.pumpAndSettle();

      // Verify restaurants loaded through data -> domain -> presentation layers
      expect(find.text('Burger House'), findsOneWidget);
      expect(find.text('Pizza Point'), findsOneWidget);
      expect(find.text('Biryani House'), findsOneWidget);

      // 2. Open food details / menu for 'Burger House'
      await tester.tap(find.text('Burger House'));
      await tester.pumpAndSettle();

      // Verify menu items exist in the bottom sheet
      expect(find.text('Burger House Special'), findsOneWidget);

      // 3. Add 1st item (qty: 1)
      final addButtons = find.widgetWithText(FilledButton, 'Add');
      expect(addButtons, findsWidgets);
      await tester.tap(addButtons.first);
      await tester.pumpAndSettle();

      // Hide any active snackbar so it doesn't obstruct subsequent taps
      final scaffoldMessenger = ScaffoldMessenger.of(
        tester.element(find.text('FoodGo')),
      );
      scaffoldMessenger.hideCurrentSnackBar();
      await tester.pumpAndSettle();

      // Cart badge should now show 1
      final cartCubit = di.getIt<CartCubit>();
      expect(cartCubit.state, isA<CartLoaded>());
      var loaded = cartCubit.state as CartLoaded;
      expect(loaded.totalItemCount, 1);
      expect(loaded.subtotal, 249.0);
      expect(loaded.total, 289.0); // 249 + 40

      // 4. Open 'Burger House' again and add the same item with quantity 2
      await tester.tap(find.text('Burger House'));
      await tester.pumpAndSettle();

      // Find the '+' button to increase quantity before adding
      final plusButtons = find.byIcon(Icons.add);
      await tester.tap(plusButtons.first); // qty becomes 2
      await tester.pumpAndSettle();

      // Tap 'Add' to add 2 more of the same item
      await tester.tap(find.widgetWithText(FilledButton, 'Add').first);
      await tester.pumpAndSettle();

      scaffoldMessenger.hideCurrentSnackBar();
      await tester.pumpAndSettle();

      // Verify adding the same food twice increments quantity (1 + 2 = 3)
      loaded = cartCubit.state as CartLoaded;
      expect(loaded.totalItemCount, 3);
      expect(loaded.items.length, 1);
      expect(loaded.items.first.quantity, 3);
      expect(loaded.subtotal, 747.0); // 249 * 3
      expect(loaded.total, 787.0); // 747 + 40

      // 5. Navigate to CartScreen via Cart icon
      await tester.tap(find.byIcon(Icons.shopping_cart_outlined));
      await tester.pumpAndSettle();

      // Verify on CartScreen
      expect(find.text('My Cart'), findsOneWidget);
      expect(find.text('Burger House Special'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('₹747'), findsWidgets);

      // 6. Navigate back to Home and verify cart state is preserved
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Burger House'), findsOneWidget);
      expect(cartCubit.state, isA<CartLoaded>());
      expect((cartCubit.state as CartLoaded).totalItemCount, 3);

      // 7. Test empty cart state
      await tester.tap(find.byIcon(Icons.shopping_cart_outlined));
      await tester.pumpAndSettle();

      // Tap clear button in AppBar
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      // Empty state should be visible
      expect(find.text('Your cart is empty'), findsOneWidget);
      expect(find.text('Explore Food'), findsOneWidget);
    },
  );
}
