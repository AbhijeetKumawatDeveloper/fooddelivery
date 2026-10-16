import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fooddelivery/core/di/injection.dart';
import 'package:fooddelivery/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:fooddelivery/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:fooddelivery/features/admin/domain/entities/admin_dashboard_stats.dart';
import 'package:fooddelivery/features/admin/domain/usecases/get_dashboard_stats.dart';
import 'package:fooddelivery/features/admin/presentation/cubit/admin_dashboard_cubit.dart';
import 'package:fooddelivery/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AdminDashboardStats Domain Entity Tests', () {
    test('completionRate calculation and props comparison', () {
      const stats = AdminDashboardStats(
        totalUsers: 100,
        totalRestaurants: 10,
        totalOrders: 200,
        completedOrders: 180,
        cancelledOrders: 10,
        totalRevenue: 50000.0,
      );

      expect(stats.completionRate, 90.0);
      expect(stats.totalUsers, 100);
      expect(stats.totalRestaurants, 10);
      expect(stats.totalOrders, 200);
      expect(stats.completedOrders, 180);
      expect(stats.cancelledOrders, 10);
      expect(stats.totalRevenue, 50000.0);

      const zeroOrders = AdminDashboardStats(
        totalUsers: 0,
        totalRestaurants: 0,
        totalOrders: 0,
        completedOrders: 0,
        cancelledOrders: 0,
        totalRevenue: 0.0,
      );
      expect(zeroOrders.completionRate, 0.0);
    });
  });

  group('AdminRepository & DataSource Tests', () {
    late AdminRemoteDataSource dataSource;
    late AdminRepositoryImpl repository;

    setUp(() {
      dataSource = AdminRemoteDataSource();
      repository = AdminRepositoryImpl(dataSource);
    });

    test('getDashboardStats returns mock platform stats', () async {
      final stats = await repository.getDashboardStats();
      expect(stats.totalUsers, greaterThan(0));
      expect(stats.totalRestaurants, greaterThan(0));
      expect(stats.totalOrders, greaterThan(0));
      expect(stats.totalRevenue, greaterThan(0));
    });

    test('getUsers returns mock user directory', () async {
      final users = await repository.getUsers();
      expect(users.isNotEmpty, isTrue);
      expect(users.first['email'], isNotNull);
    });

    test('getRestaurants returns mock restaurants', () async {
      final restaurants = await repository.getRestaurants();
      expect(restaurants.isNotEmpty, isTrue);
      expect(restaurants.first['name'], isNotNull);
    });

    test('toggleUserStatus updates user isActive field', () async {
      await repository.toggleUserStatus('u_01', false);
      final users = await repository.getUsers();
      final user = users.firstWhere((u) => u['id'] == 'u_01');
      expect(user['isActive'], isFalse);

      await repository.toggleUserStatus('u_01', true);
      final restored = (await repository.getUsers()).firstWhere(
        (u) => u['id'] == 'u_01',
      );
      expect(restored['isActive'], isTrue);
    });

    test('toggleRestaurantApproval updates isApproved field', () async {
      await repository.toggleRestaurantApproval('r3', true);
      final restaurants = await repository.getRestaurants();
      final restaurant = restaurants.firstWhere((r) => r['id'] == 'r3');
      expect(restaurant['isApproved'], isTrue);
    });
  });

  group('AdminDashboardCubit Tests', () {
    late AdminRemoteDataSource dataSource;
    late AdminRepositoryImpl repository;
    late AdminDashboardCubit cubit;

    setUp(() {
      dataSource = AdminRemoteDataSource();
      repository = AdminRepositoryImpl(dataSource);
      cubit = AdminDashboardCubit(
        getDashboardStats: GetDashboardStats(repository),
        repository: repository,
      );
    });

    tearDown(() {
      cubit.close();
    });

    test('loadDashboardData loads stats, users, restaurants', () async {
      await cubit.loadDashboardData();
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.stats, isNotNull);
      expect(cubit.state.users.isNotEmpty, isTrue);
      expect(cubit.state.restaurants.isNotEmpty, isTrue);
    });

    test('setTab changes active tab index', () {
      expect(cubit.state.selectedTab, 0);
      cubit.setTab(1);
      expect(cubit.state.selectedTab, 1);
      cubit.setTab(2);
      expect(cubit.state.selectedTab, 2);
    });

    test(
      'toggleRestaurantApproval updates cubit state with success message',
      () async {
        await cubit.loadDashboardData();
        await cubit.toggleRestaurantApproval('r3', true);

        final r3 = cubit.state.restaurants.firstWhere((r) => r['id'] == 'r3');
        expect(r3['isApproved'], isTrue);
        expect(cubit.state.successMessage, 'Restaurant approved successfully');
      },
    );

    test('toggleUserStatus updates cubit state with success message', () async {
      await cubit.loadDashboardData();
      await cubit.toggleUserStatus('u_01', false);

      final u1 = cubit.state.users.firstWhere((u) => u['id'] == 'u_01');
      expect(u1['isActive'], isFalse);
      expect(cubit.state.successMessage, 'User account suspended');
    });
  });

  group('AdminDashboardScreen Widget Tests', () {
    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      await setupDependencies();
    });

    testWidgets(
      'AdminDashboardScreen displays KPIs, tabs, and switches views',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const MaterialApp(home: AdminDashboardScreen()),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Header & Tabs
        expect(find.text('FoodGo Admin Portal'), findsOneWidget);
        expect(find.text('Platform Analytics & Governance'), findsOneWidget);
        expect(find.text('Overview'), findsOneWidget);
        expect(find.text('Restaurants'), findsWidgets);
        expect(find.text('Users'), findsOneWidget);

        // Overview KPI metrics
        expect(find.text('Total Revenue'), findsOneWidget);
        expect(find.text('Total Orders'), findsOneWidget);
        expect(find.text('Active Users'), findsOneWidget);
        expect(find.text('Fulfillment Health'), findsOneWidget);

        // Switch to Restaurants Tab
        await tester.tap(find.byKey(const Key('admin_tab_1')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Burger Hub'), findsOneWidget);
        expect(find.text('Biryani Junction'), findsOneWidget);
        expect(find.byKey(const Key('toggle_restaurant_r1')), findsOneWidget);

        // Switch to Users Tab
        await tester.tap(find.byKey(const Key('admin_tab_2')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Rahul Sharma'), findsOneWidget);
        expect(find.text('Pooja Verma'), findsOneWidget);
        expect(find.byKey(const Key('toggle_user_u_01')), findsOneWidget);
      },
    );
  });
}
