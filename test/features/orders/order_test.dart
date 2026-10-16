import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fooddelivery/core/di/injection.dart';
import 'package:fooddelivery/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:fooddelivery/features/cart/domain/entities/cart_item.dart';
import 'package:fooddelivery/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:fooddelivery/features/orders/data/datasources/order_local_datasource.dart';
import 'package:fooddelivery/features/orders/data/datasources/order_remote_datasource.dart';
import 'package:fooddelivery/features/orders/data/models/app_order_model.dart';
import 'package:fooddelivery/features/orders/data/models/order_item_model.dart';
import 'package:fooddelivery/features/orders/data/repositories/order_repository_impl.dart';
import 'package:fooddelivery/features/orders/domain/entities/app_order.dart';
import 'package:fooddelivery/features/orders/domain/entities/order_item.dart';
import 'package:fooddelivery/features/orders/domain/repositories/order_repository.dart';
import 'package:fooddelivery/features/orders/domain/usecases/create_order.dart';
import 'package:fooddelivery/features/orders/domain/usecases/get_user_orders.dart';
import 'package:fooddelivery/features/orders/domain/usecases/stream_user_orders.dart';
import 'package:fooddelivery/features/orders/presentation/cubit/order_cubit.dart';
import 'package:fooddelivery/features/orders/presentation/cubit/order_state.dart';
import 'package:fooddelivery/features/orders/presentation/screens/checkout_screen.dart';
import 'package:fooddelivery/features/orders/presentation/screens/order_history_screen.dart';
import 'package:fooddelivery/features/orders/presentation/screens/order_success_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Order Domain Entities & Models Tests', () {
    test('OrderItem calculates totalPrice correctly', () {
      const item = OrderItem(
        foodId: 'f1',
        name: 'Veg Supreme Burger',
        price: 220.0,
        quantity: 3,
      );

      expect(item.totalPrice, 660.0);
    });

    test('OrderItemModel toMap and fromMap serialization', () {
      const itemModel = OrderItemModel(
        foodId: 'f1',
        name: 'Veg Supreme Burger',
        price: 220.0,
        quantity: 3,
        image: 'assets/images/Burger.png',
      );

      final map = itemModel.toMap();
      final fromMap = OrderItemModel.fromMap(map);

      expect(fromMap.foodId, 'f1');
      expect(fromMap.name, 'Veg Supreme Burger');
      expect(fromMap.price, 220.0);
      expect(fromMap.quantity, 3);
      expect(fromMap.image, 'assets/images/Burger.png');
      expect(fromMap.totalPrice, 660.0);
    });

    test('OrderStatus labels and parsing from string', () {
      expect(OrderStatus.fromString('pending'), OrderStatus.pending);
      expect(OrderStatus.fromString('confirmed'), OrderStatus.confirmed);
      expect(OrderStatus.fromString('preparing'), OrderStatus.confirmed);
      expect(
        OrderStatus.fromString('out_for_delivery'),
        OrderStatus.outForDelivery,
      );
      expect(OrderStatus.fromString('delivered'), OrderStatus.delivered);
      expect(OrderStatus.fromString('cancelled'), OrderStatus.cancelled);
      expect(OrderStatus.fromString('unknown_value'), OrderStatus.pending);

      expect(OrderStatus.pending.label, 'Order Placed');
      expect(OrderStatus.confirmed.label, 'Preparing');
      expect(OrderStatus.outForDelivery.label, 'Out for Delivery');
      expect(OrderStatus.delivered.label, 'Delivered');
      expect(OrderStatus.cancelled.label, 'Cancelled');
    });

    test('AppOrder totalItemCount sums all item quantities', () {
      final order = AppOrder(
        id: 'o1',
        userId: 'u1',
        restaurantId: 'r1',
        restaurantName: 'Burger Palace',
        items: const [
          OrderItem(foodId: 'f1', name: 'Burger', price: 100, quantity: 2),
          OrderItem(foodId: 'f2', name: 'Fries', price: 50, quantity: 1),
        ],
        subtotal: 250.0,
        deliveryFee: 40.0,
        totalAmount: 290.0,
        deliveryAddress: '221B Baker Street',
        createdAt: DateTime.now(),
      );

      expect(order.totalItemCount, 3);
    });

    test('AppOrderModel toMap and fromMap serialization', () {
      final now = DateTime(2026, 10, 16, 12, 0, 0);
      final model = AppOrderModel(
        id: 'ord_123',
        userId: 'user_456',
        restaurantId: 'rest_789',
        restaurantName: 'Biryani Express',
        items: const [
          OrderItem(
            foodId: 'f1',
            name: 'Mutton Biryani',
            price: 350,
            quantity: 1,
          ),
        ],
        subtotal: 350.0,
        deliveryFee: 50.0,
        totalAmount: 400.0,
        deliveryAddress: '10MG Road',
        paymentMethod: 'UPI / Online Payment',
        status: OrderStatus.confirmed,
        createdAt: now,
      );

      final map = model.toMap();
      final reloaded = AppOrderModel.fromMap(map, 'ord_123');

      expect(reloaded.id, 'ord_123');
      expect(reloaded.userId, 'user_456');
      expect(reloaded.restaurantName, 'Biryani Express');
      expect(reloaded.items.length, 1);
      expect(reloaded.items.first.name, 'Mutton Biryani');
      expect(reloaded.subtotal, 350.0);
      expect(reloaded.deliveryFee, 50.0);
      expect(reloaded.totalAmount, 400.0);
      expect(reloaded.deliveryAddress, '10MG Road');
      expect(reloaded.paymentMethod, 'UPI / Online Payment');
      expect(reloaded.status, OrderStatus.confirmed);
    });
  });

  group('OrderLocalDataSource Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('saves and retrieves orders from memory and prefs', () async {
      final dataSource = OrderLocalDataSourceImpl();

      final order = AppOrder(
        id: 'o_test',
        userId: 'u_test',
        restaurantId: 'r1',
        restaurantName: 'Test Diner',
        items: const [
          OrderItem(foodId: 'f1', name: 'Coffee', price: 80, quantity: 2),
        ],
        subtotal: 160.0,
        deliveryFee: 30.0,
        totalAmount: 190.0,
        deliveryAddress: 'Test Lane 5',
        createdAt: DateTime.now(),
      );

      final saved = await dataSource.saveOrder(order);
      expect(saved.id, 'o_test');

      final userOrders = await dataSource.getUserOrders('u_test');
      expect(userOrders.length, 1);
      expect(userOrders.first.totalAmount, 190.0);

      // Verify stream emits the order
      final streamOrder = await dataSource.streamUserOrders('u_test').first;
      expect(streamOrder.length, 1);
      expect(streamOrder.first.restaurantName, 'Test Diner');
    });
  });

  group('OrderRepositoryImpl Tests', () {
    late OrderRepository repository;
    late OrderLocalDataSource localDataSource;
    late OrderRemoteDataSource remoteDataSource;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      localDataSource = OrderLocalDataSourceImpl();
      remoteDataSource = const OrderRemoteDataSource(null);
      repository = OrderRepositoryImpl(remoteDataSource, localDataSource);
    });

    test(
      'createOrder falls back to localDataSource when remote has no firestore',
      () async {
        final order = await repository.createOrder(
          userId: 'u1',
          restaurantId: 'r1',
          restaurantName: 'Taco Bar',
          items: const [
            OrderItem(foodId: 'f1', name: 'Taco', price: 120, quantity: 2),
          ],
          subtotal: 240.0,
          deliveryFee: 40.0,
          totalAmount: 280.0,
          deliveryAddress: '42 Wallaby Way',
        );

        expect(order.id.isNotEmpty, isTrue);
        expect(order.userId, 'u1');
        expect(order.totalAmount, 280.0);

        final fetched = await repository.getUserOrders('u1');
        expect(fetched.length, 1);
        expect(fetched.first.restaurantName, 'Taco Bar');
      },
    );

    test('streamUserOrders emits saved orders', () async {
      await repository.createOrder(
        userId: 'u2',
        restaurantId: 'r1',
        restaurantName: 'Sushi Spot',
        items: const [
          OrderItem(foodId: 'f3', name: 'Rolls', price: 300, quantity: 1),
        ],
        subtotal: 300.0,
        deliveryFee: 40.0,
        totalAmount: 340.0,
        deliveryAddress: 'Tokyo Garden',
      );

      final orders = await repository.streamUserOrders('u2').first;
      expect(orders.length, 1);
      expect(orders.first.restaurantName, 'Sushi Spot');
    });
  });

  group('OrderCubit Tests', () {
    late OrderRepository repository;
    late CreateOrder createOrder;
    late GetUserOrders getUserOrders;
    late StreamUserOrders streamUserOrders;
    late OrderCubit orderCubit;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      final localDataSource = OrderLocalDataSourceImpl();
      repository = OrderRepositoryImpl(
        const OrderRemoteDataSource(null),
        localDataSource,
      );
      createOrder = CreateOrder(repository);
      getUserOrders = GetUserOrders(repository);
      streamUserOrders = StreamUserOrders(repository);

      orderCubit = OrderCubit(
        createOrderUseCase: createOrder,
        getUserOrdersUseCase: getUserOrders,
        streamUserOrdersUseCase: streamUserOrders,
      );
    });

    tearDown(() {
      orderCubit.close();
    });

    test('initial state is OrderInitial', () {
      expect(orderCubit.state, isA<OrderInitial>());
    });

    test('placeOrder emits OrderFailure when items are empty', () async {
      final result = await orderCubit.placeOrder(
        userId: 'u1',
        restaurantId: 'r1',
        restaurantName: 'Pizza Inn',
        items: [],
        subtotal: 0,
        deliveryFee: 40,
        totalAmount: 40,
        deliveryAddress: '123 Street',
      );

      expect(result, isNull);
      expect(orderCubit.state, isA<OrderFailure>());
      expect(
        (orderCubit.state as OrderFailure).message,
        'Cannot place an empty order.',
      );
    });

    test('placeOrder emits OrderFailure when address is empty', () async {
      final result = await orderCubit.placeOrder(
        userId: 'u1',
        restaurantId: 'r1',
        restaurantName: 'Pizza Inn',
        items: const [
          OrderItem(foodId: 'f1', name: 'Pizza', price: 299, quantity: 1),
        ],
        subtotal: 299,
        deliveryFee: 40,
        totalAmount: 339,
        deliveryAddress: '   ',
      );

      expect(result, isNull);
      expect(orderCubit.state, isA<OrderFailure>());
      expect(
        (orderCubit.state as OrderFailure).message,
        'Please provide a valid delivery address.',
      );
    });

    test(
      'placeOrder successfully places order and emits OrderCreated',
      () async {
        final result = await orderCubit.placeOrder(
          userId: 'u1',
          restaurantId: 'r1',
          restaurantName: 'Burger Hub',
          items: const [
            OrderItem(
              foodId: 'f1',
              name: 'Cheeseburger',
              price: 199,
              quantity: 2,
            ),
          ],
          subtotal: 398.0,
          deliveryFee: 40.0,
          totalAmount: 438.0,
          deliveryAddress: '123 Elm Street',
        );

        expect(result, isNotNull);
        expect(result!.restaurantName, 'Burger Hub');
        expect(orderCubit.state, isA<OrderCreated>());
        final createdState = orderCubit.state as OrderCreated;
        expect(createdState.order.totalAmount, 438.0);
      },
    );

    test('loadUserOrders loads orders into OrdersLoaded', () async {
      // Place an order first
      await orderCubit.placeOrder(
        userId: 'u_load',
        restaurantId: 'r1',
        restaurantName: 'Dosa Plaza',
        items: const [
          OrderItem(foodId: 'f1', name: 'Masala Dosa', price: 120, quantity: 1),
        ],
        subtotal: 120.0,
        deliveryFee: 30.0,
        totalAmount: 150.0,
        deliveryAddress: 'South Extension',
      );

      await orderCubit.loadUserOrders('u_load');

      expect(orderCubit.state, isA<OrdersLoaded>());
      final loaded = orderCubit.state as OrdersLoaded;
      expect(loaded.orders.length, 1);
      expect(loaded.orders.first.restaurantName, 'Dosa Plaza');
    });
  });

  group('Order Screens Widget Tests', () {
    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      await setupDependencies();
    });

    testWidgets('OrderSuccessScreen displays order details correctly', (
      tester,
    ) async {
      final order = AppOrder(
        id: 'ord_987654',
        userId: 'u1',
        restaurantId: 'r1',
        restaurantName: 'Gourmet Pizza',
        items: const [
          OrderItem(foodId: 'f1', name: 'Margherita', price: 350, quantity: 1),
        ],
        subtotal: 350.0,
        deliveryFee: 40.0,
        totalAmount: 390.0,
        deliveryAddress: '742 Evergreen Terrace',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(home: OrderSuccessScreen(order: order)),
      );

      expect(find.text('Order Placed!'), findsOneWidget);
      expect(find.text('Thank You!'), findsOneWidget);
      expect(find.text('₹390'), findsOneWidget);
      expect(find.text('742 Evergreen Terrace'), findsOneWidget);
      expect(find.text('View All Orders'), findsOneWidget);
      expect(find.text('Back to Home'), findsOneWidget);
    });

    testWidgets('CheckoutScreen renders address, payment method, and summary', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const cartItems = [
        CartItem(
          foodId: 'f1',
          restaurantId: 'r1',
          name: 'Crispy Wings',
          price: 250.0,
          quantity: 2,
        ),
      ];

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<CartCubit>(create: (_) => getIt<CartCubit>()),
            BlocProvider<AuthCubit>(create: (_) => getIt<AuthCubit>()),
          ],
          child: const MaterialApp(
            home: CheckoutScreen(
              cartItems: cartItems,
              subtotal: 500.0,
              deliveryFee: 40.0,
              total: 540.0,
            ),
          ),
        ),
      );

      expect(find.text('Checkout'), findsOneWidget);
      expect(find.text('Delivery Address'), findsOneWidget);
      expect(find.text('Payment Method'), findsOneWidget);
      expect(find.text('Cash on Delivery'), findsOneWidget);
      expect(find.text('Crispy Wings'), findsOneWidget);
      expect(find.text('2x'), findsOneWidget);
      expect(find.text('₹540'), findsWidgets);
      expect(find.text('Confirm & Place Order'), findsOneWidget);
    });

    testWidgets('OrderHistoryScreen renders with orders or empty state', (
      tester,
    ) async {
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>(create: (_) => getIt<AuthCubit>()),
          ],
          child: const MaterialApp(home: OrderHistoryScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('My Orders'), findsOneWidget);
    });
  });
}
