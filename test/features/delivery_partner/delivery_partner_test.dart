import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fooddelivery/core/di/injection.dart';
import 'package:fooddelivery/features/delivery_partner/data/datasources/delivery_remote_datasource.dart';
import 'package:fooddelivery/features/delivery_partner/data/models/delivery_order_model.dart';
import 'package:fooddelivery/features/delivery_partner/data/repositories/delivery_repository_impl.dart';
import 'package:fooddelivery/features/delivery_partner/domain/entities/delivery_order.dart';
import 'package:fooddelivery/features/delivery_partner/domain/usecases/update_delivery_location.dart';
import 'package:fooddelivery/features/delivery_partner/domain/usecases/update_delivery_status.dart';
import 'package:fooddelivery/features/delivery_partner/domain/usecases/watch_assigned_orders.dart';
import 'package:fooddelivery/features/delivery_partner/presentation/cubit/delivery_cubit.dart';
import 'package:fooddelivery/features/delivery_partner/presentation/cubit/delivery_state.dart';
import 'package:fooddelivery/features/delivery_partner/presentation/screens/delivery_dashboard_screen.dart';
import 'package:fooddelivery/features/delivery_partner/presentation/screens/delivery_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('DeliveryOrder Domain & Model Tests', () {
    test('DeliveryOrderModel toMap and fromMap serialization', () {
      final now = DateTime(2026, 10, 16, 12, 0, 0);
      final model = DeliveryOrderModel(
        id: 'del_001',
        customerId: 'cust_001',
        customerName: 'Ananya Sharma',
        restaurantId: 'r1',
        restaurantName: 'Burger Hub',
        deliveryPartnerId: 'dp_1',
        deliveryAddress: '12th Cross, Indiranagar, Bengaluru',
        status: DeliveryStatus.pickedUp,
        totalAmount: 650.0,
        latitude: 12.9716,
        longitude: 77.5946,
        items: const ['2 x Cheeseburger', '1 x Coke'],
        updatedAt: now,
      );

      final map = model.toMap();
      final fromMap = DeliveryOrderModel.fromMap(map);

      expect(fromMap.id, 'del_001');
      expect(fromMap.customerId, 'cust_001');
      expect(fromMap.customerName, 'Ananya Sharma');
      expect(fromMap.restaurantName, 'Burger Hub');
      expect(fromMap.deliveryPartnerId, 'dp_1');
      expect(fromMap.status, DeliveryStatus.pickedUp);
      expect(fromMap.totalAmount, 650.0);
      expect(fromMap.latitude, 12.9716);
      expect(fromMap.longitude, 77.5946);
      expect(fromMap.items.length, 2);
    });

    test('DeliveryOrder copyWith modifies requested properties', () {
      final order = DeliveryOrder(
        id: 'del_001',
        customerId: 'cust_001',
        customerName: 'Ananya Sharma',
        restaurantId: 'r1',
        restaurantName: 'Burger Hub',
        deliveryPartnerId: 'dp_1',
        deliveryAddress: '12th Cross, Indiranagar',
        status: DeliveryStatus.assigned,
        totalAmount: 650.0,
        latitude: 12.9716,
        longitude: 77.5946,
        items: const ['2 x Cheeseburger'],
        updatedAt: DateTime.now(),
      );

      final updated = order.copyWith(
        status: DeliveryStatus.delivered,
        latitude: 12.9800,
        longitude: 77.6000,
      );

      expect(updated.status, DeliveryStatus.delivered);
      expect(updated.latitude, 12.9800);
      expect(updated.longitude, 77.6000);
      expect(updated.id, 'del_001');
      expect(updated.customerName, 'Ananya Sharma');
    });
  });

  group('DeliveryRepository & DataSource Tests', () {
    late DeliveryRemoteDataSource dataSource;
    late DeliveryRepositoryImpl repository;

    setUp(() {
      dataSource = DeliveryRemoteDataSource();
      repository = DeliveryRepositoryImpl(dataSource);
    });

    test('getAssignedOrders returns mock deliveries for dp_1', () async {
      final orders = await repository.getAssignedOrders('dp_1');
      expect(orders.isNotEmpty, isTrue);
      expect(orders.first.deliveryPartnerId, 'dp_1');
    });

    test('updateStatus updates order status in datasource', () async {
      await repository.updateStatus('del_ord_01', DeliveryStatus.accepted);
      final orders = await repository.getAssignedOrders('dp_1');
      final updated = orders.firstWhere((o) => o.id == 'del_ord_01');
      expect(updated.status, DeliveryStatus.accepted);
    });

    test('updateLocation updates coordinates in datasource', () async {
      await repository.updateLocation('del_ord_01', 13.0827, 80.2707);
      final orders = await repository.getAssignedOrders('dp_1');
      final updated = orders.firstWhere((o) => o.id == 'del_ord_01');
      expect(updated.latitude, 13.0827);
      expect(updated.longitude, 80.2707);
    });

    test('watchAssignedOrders streams order updates', () async {
      final stream = repository.watchAssignedOrders('dp_1');
      final firstBatch = await stream.first;
      expect(firstBatch.isNotEmpty, isTrue);
    });
  });

  group('DeliveryCubit & State Tests', () {
    late DeliveryRemoteDataSource dataSource;
    late DeliveryRepositoryImpl repository;
    late DeliveryCubit cubit;

    setUp(() {
      dataSource = DeliveryRemoteDataSource();
      repository = DeliveryRepositoryImpl(dataSource);
      cubit = DeliveryCubit(
        watchAssignedOrders: WatchAssignedOrders(repository),
        updateDeliveryStatus: UpdateDeliveryStatus(repository),
        updateDeliveryLocation: UpdateDeliveryLocation(repository),
        repository: repository,
      );
    });

    tearDown(() {
      cubit.close();
    });

    test('DeliveryState calculates activeCount, completedCount, earnings', () {
      final orders = [
        DeliveryOrder(
          id: 'o1',
          customerId: 'c1',
          customerName: 'User 1',
          restaurantId: 'r1',
          restaurantName: 'R1',
          deliveryPartnerId: 'dp_1',
          deliveryAddress: 'Address 1',
          status: DeliveryStatus.assigned,
          totalAmount: 500.0,
          latitude: 12.0,
          longitude: 77.0,
          items: const ['Burger'],
          updatedAt: DateTime.now(),
        ),
        DeliveryOrder(
          id: 'o2',
          customerId: 'c2',
          customerName: 'User 2',
          restaurantId: 'r1',
          restaurantName: 'R1',
          deliveryPartnerId: 'dp_1',
          deliveryAddress: 'Address 2',
          status: DeliveryStatus.onTheWay,
          totalAmount: 300.0,
          latitude: 12.0,
          longitude: 77.0,
          items: const ['Pizza'],
          updatedAt: DateTime.now(),
        ),
        DeliveryOrder(
          id: 'o3',
          customerId: 'c3',
          customerName: 'User 3',
          restaurantId: 'r1',
          restaurantName: 'R1',
          deliveryPartnerId: 'dp_1',
          deliveryAddress: 'Address 3',
          status: DeliveryStatus.delivered,
          totalAmount: 400.0,
          latitude: 12.0,
          longitude: 77.0,
          items: const ['Pasta'],
          updatedAt: DateTime.now(),
        ),
      ];

      final state = DeliveryState(orders: orders);
      expect(state.activeDeliveriesCount, 1);
      expect(state.completedCount, 1);
      // Earnings formula: completedCount * 50.0 (50 * 1 = 50.0)
      expect(state.todayEarnings, 50.0);
    });

    test('loadAssignedOrders loads orders into state', () async {
      await cubit.loadAssignedOrders('dp_1');
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.orders.isNotEmpty, isTrue);
    });

    test('updateStatus transitions: accept, pickup, startDelivery, completeDelivery', () async {
      await cubit.loadAssignedOrders('dp_1');
      expect(cubit.state.orders.isNotEmpty, isTrue);

      await cubit.acceptDelivery('del_ord_01');
      var order = cubit.state.orders.firstWhere((o) => o.id == 'del_ord_01');
      expect(order.status, DeliveryStatus.accepted);

      await cubit.confirmPickup('del_ord_01');
      order = cubit.state.orders.firstWhere((o) => o.id == 'del_ord_01');
      expect(order.status, DeliveryStatus.pickedUp);

      await cubit.startDelivery('del_ord_01');
      order = cubit.state.orders.firstWhere((o) => o.id == 'del_ord_01');
      expect(order.status, DeliveryStatus.onTheWay);

      await cubit.completeDelivery('del_ord_01');
      order = cubit.state.orders.firstWhere((o) => o.id == 'del_ord_01');
      expect(order.status, DeliveryStatus.delivered);
    });

    test(
      'broadcastLocation updates delivery order coordinates in state',
      () async {
        await cubit.loadAssignedOrders('dp_1');
        await cubit.broadcastLocation('del_ord_01', 12.9352, 77.6245);

        final order = cubit.state.orders.firstWhere(
          (o) => o.id == 'del_ord_01',
        );
        expect(order.latitude, 12.9352);
        expect(order.longitude, 77.6245);
      },
    );
  });

  group('DeliveryPartner Screens Widget Tests', () {
    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      await setupDependencies();
    });

    testWidgets(
      'DeliveryDashboardScreen displays earnings and assigned orders',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const MaterialApp(
            home: DeliveryDashboardScreen(
              partnerId: 'dp_1',
              partnerName: 'Vikram Singh (Delivery Hero)',
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Vikram Singh (Delivery Hero)'), findsOneWidget);
        expect(find.text('Active On Duty'), findsOneWidget);
        expect(find.text("Today's Delivery Earnings"), findsOneWidget);
        expect(find.text('Assigned'), findsWidgets);
        expect(find.text('Active Trips'), findsOneWidget);
        expect(find.text('Delivered'), findsOneWidget);
        expect(find.text('Assigned Deliveries Queue'), findsOneWidget);
      },
    );

    testWidgets(
      'DeliveryDetailsScreen renders order info, stepper, and actions',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final testOrder = DeliveryOrder(
          id: 'del_ord_test',
          customerId: 'cust_01',
          customerName: 'Sanya Malhotra',
          restaurantId: 'r1',
          restaurantName: 'Burger Hub Indiranagar',
          deliveryPartnerId: 'dp_1',
          deliveryAddress: 'Flat 304, Green Glen Layout, Bellandur, Bengaluru',
          status: DeliveryStatus.assigned,
          totalAmount: 540.0,
          latitude: 12.9352,
          longitude: 77.6245,
          items: const ['2 x Double Cheese Burger', '1 x Peri Peri Fries'],
          updatedAt: DateTime.now(),
        );

        await tester.pumpWidget(
          MaterialApp(home: DeliveryDetailsScreen(order: testOrder)),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.textContaining('DEL_ORD_'), findsWidgets);
        expect(find.text('Sanya Malhotra'), findsOneWidget);
        expect(find.text('Burger Hub Indiranagar'), findsOneWidget);
        expect(
          find.text('Flat 304, Green Glen Layout, Bellandur, Bengaluru'),
          findsOneWidget,
        );
        expect(find.text('Delivery Status'), findsOneWidget);
        expect(find.text('Accept Delivery Assignment'), findsOneWidget);
      },
    );
  });
}
