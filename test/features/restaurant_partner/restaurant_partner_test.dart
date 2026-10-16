import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fooddelivery/core/di/injection.dart';
import 'package:fooddelivery/features/restaurant_partner/data/datasources/partner_order_datasource.dart';
import 'package:fooddelivery/features/restaurant_partner/data/models/restaurant_order_model.dart';
import 'package:fooddelivery/features/restaurant_partner/data/repositories/partner_order_repository_impl.dart';
import 'package:fooddelivery/features/restaurant_partner/domain/entities/restaurant_order.dart';
import 'package:fooddelivery/features/restaurant_partner/domain/usecases/update_order_status.dart';
import 'package:fooddelivery/features/restaurant_partner/domain/usecases/watch_partner_orders.dart';
import 'package:fooddelivery/features/restaurant_partner/presentation/cubit/partner_order_cubit.dart';
import 'package:fooddelivery/features/restaurant_partner/presentation/cubit/partner_order_state.dart';
import 'package:fooddelivery/features/restaurant_partner/presentation/screens/partner_dashboard_screen.dart';
import 'package:fooddelivery/features/restaurant_partner/presentation/screens/partner_orders_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('RestaurantOrder Domain & Model Tests', () {
    test('RestaurantOrderStatus string parsing and labels', () {
      expect(
        RestaurantOrderStatus.fromString('pending'),
        RestaurantOrderStatus.pending,
      );
      expect(
        RestaurantOrderStatus.fromString('accepted'),
        RestaurantOrderStatus.accepted,
      );
      expect(
        RestaurantOrderStatus.fromString('preparing'),
        RestaurantOrderStatus.preparing,
      );
      expect(
        RestaurantOrderStatus.fromString('ready_for_pickup'),
        RestaurantOrderStatus.readyForPickup,
      );
      expect(
        RestaurantOrderStatus.fromString('picked_up'),
        RestaurantOrderStatus.pickedUp,
      );
      expect(
        RestaurantOrderStatus.fromString('delivered'),
        RestaurantOrderStatus.delivered,
      );
      expect(
        RestaurantOrderStatus.fromString('rejected'),
        RestaurantOrderStatus.rejected,
      );
      expect(
        RestaurantOrderStatus.fromString('cancelled'),
        RestaurantOrderStatus.cancelled,
      );
      expect(
        RestaurantOrderStatus.fromString('other'),
        RestaurantOrderStatus.pending,
      );

      expect(RestaurantOrderStatus.pending.label, 'Pending');
      expect(RestaurantOrderStatus.accepted.label, 'Accepted');
      expect(RestaurantOrderStatus.preparing.label, 'Preparing');
      expect(RestaurantOrderStatus.readyForPickup.label, 'Ready for Pickup');
      expect(RestaurantOrderStatus.pickedUp.label, 'Out for Delivery');
      expect(RestaurantOrderStatus.delivered.label, 'Delivered');
      expect(RestaurantOrderStatus.rejected.label, 'Rejected');
    });

    test('RestaurantOrderModel toMap and fromMap serialization', () {
      final now = DateTime(2026, 10, 16, 14, 30);
      final model = RestaurantOrderModel(
        id: 'ord_partner_1',
        restaurantId: 'r1',
        customerId: 'c1',
        total: 550.0,
        status: RestaurantOrderStatus.preparing,
        customerName: 'Kavita Rao',
        customerAddress: 'Indiranagar 100ft road',
        items: const ['2 x Burger', '1 x Coke'],
        createdAt: now,
      );

      final map = model.toMap();
      final fromMap = RestaurantOrderModel.fromMap(map, 'ord_partner_1');

      expect(fromMap.id, 'ord_partner_1');
      expect(fromMap.restaurantId, 'r1');
      expect(fromMap.customerId, 'c1');
      expect(fromMap.total, 550.0);
      expect(fromMap.status, RestaurantOrderStatus.preparing);
      expect(fromMap.customerName, 'Kavita Rao');
      expect(fromMap.items.length, 2);
    });
  });

  group('PartnerOrderRepository & DataSource Tests', () {
    late PartnerOrderRemoteDataSource dataSource;
    late PartnerOrderRepositoryImpl repository;

    setUp(() {
      dataSource = PartnerOrderRemoteDataSource();
      repository = PartnerOrderRepositoryImpl(dataSource);
    });

    test('getOrders returns orders for restaurantId', () async {
      final orders = await repository.getOrders('r1');
      expect(orders.isNotEmpty, isTrue);
      expect(orders.first.restaurantId, 'r1');
    });

    test('updateStatus updates status in data source', () async {
      await repository.updateStatus(
        orderId: 'ord_101',
        status: RestaurantOrderStatus.accepted,
      );

      final orders = await repository.getOrders('r1');
      final updated = orders.firstWhere((o) => o.id == 'ord_101');
      expect(updated.status, RestaurantOrderStatus.accepted);
    });

    test('watchOrders streams live order updates', () async {
      final stream = repository.watchOrders('r1');
      final firstBatch = await stream.first;
      expect(firstBatch.isNotEmpty, isTrue);
    });
  });

  group('PartnerOrderCubit & Dashboard Metrics Tests', () {
    late PartnerOrderRemoteDataSource dataSource;
    late PartnerOrderRepositoryImpl repository;
    late PartnerOrderCubit cubit;

    setUp(() {
      dataSource = PartnerOrderRemoteDataSource();
      repository = PartnerOrderRepositoryImpl(dataSource);
      cubit = PartnerOrderCubit(
        watchPartnerOrders: WatchPartnerOrders(repository),
        updateOrderStatus: UpdateOrderStatus(repository),
        repository: repository,
      );
    });

    tearDown(() {
      cubit.close();
    });

    test('calculates correct dashboard metrics on state', () {
      final orders = [
        RestaurantOrder(
          id: 'o1',
          restaurantId: 'r1',
          customerId: 'c1',
          total: 200.0,
          status: RestaurantOrderStatus.pending,
        ),
        RestaurantOrder(
          id: 'o2',
          restaurantId: 'r1',
          customerId: 'c2',
          total: 300.0,
          status: RestaurantOrderStatus.preparing,
        ),
        RestaurantOrder(
          id: 'o3',
          restaurantId: 'r1',
          customerId: 'c3',
          total: 500.0,
          status: RestaurantOrderStatus.delivered,
        ),
        RestaurantOrder(
          id: 'o4',
          restaurantId: 'r1',
          customerId: 'c4',
          total: 150.0,
          status: RestaurantOrderStatus.rejected,
        ),
      ];

      final state = PartnerOrderState(orders: orders);

      expect(state.totalOrdersCount, 4);
      expect(state.pendingCount, 1);
      expect(state.inProgressCount, 1);
      expect(state.completedCount, 1);
      // Total sales excludes rejected (200 + 300 + 500 = 1000)
      expect(state.totalSales, 1000.0);
    });

    test('status transitions update cubit state: accept, startPreparing, markReadyForPickup, markDelivered', () async {
      await cubit.loadOrders('r1');
      expect(cubit.state.orders.isNotEmpty, isTrue);

      // Accept
      await cubit.acceptOrder('ord_101');
      var order = cubit.state.orders.firstWhere((o) => o.id == 'ord_101');
      expect(order.status, RestaurantOrderStatus.accepted);

      // Start preparing
      await cubit.startPreparing('ord_101');
      order = cubit.state.orders.firstWhere((o) => o.id == 'ord_101');
      expect(order.status, RestaurantOrderStatus.preparing);

      // Ready for pickup
      await cubit.markReadyForPickup('ord_101');
      order = cubit.state.orders.firstWhere((o) => o.id == 'ord_101');
      expect(order.status, RestaurantOrderStatus.readyForPickup);

      // Delivered
      await cubit.markDelivered('ord_101');
      order = cubit.state.orders.firstWhere((o) => o.id == 'ord_101');
      expect(order.status, RestaurantOrderStatus.delivered);
    });
  });

  group('Partner Screens Widget Tests', () {
    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      await setupDependencies();
    });

    testWidgets('PartnerDashboardScreen renders revenue and metric cards', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: PartnerDashboardScreen(
            restaurantId: 'r1',
            restaurantName: 'Burger Palace POS',
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Burger Palace POS'), findsOneWidget);
      expect(find.text("Today's Gross Revenue"), findsOneWidget);
      expect(find.text('Pending Orders'), findsOneWidget);
      expect(find.text('In Preparation'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Manage Menu'), findsOneWidget);
    });

    testWidgets('PartnerOrdersScreen displays filter tabs and order list', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(home: PartnerOrdersScreen(restaurantId: 'r1')),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Order Management'), findsOneWidget);
      expect(find.textContaining('All ('), findsOneWidget);
      expect(find.textContaining('Pending ('), findsOneWidget);
      expect(find.textContaining('Active ('), findsOneWidget);
      expect(find.textContaining('Completed ('), findsOneWidget);
    });
  });
}
