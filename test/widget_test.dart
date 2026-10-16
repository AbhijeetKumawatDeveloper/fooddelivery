import 'package:flutter_test/flutter_test.dart';
import 'package:fooddelivery/core/di/injection.dart' as di;
import 'package:fooddelivery/main.dart';

void main() {
  setUp(() async {
    await di.sl.reset();
    await di.initDependencies();
  });

  tearDown(() async {
    await di.sl.reset();
  });

  testWidgets('FoodGo App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FoodGoApp());
    await tester.pumpAndSettle();
    expect(find.text('FoodGo'), findsOneWidget);
  });
}
