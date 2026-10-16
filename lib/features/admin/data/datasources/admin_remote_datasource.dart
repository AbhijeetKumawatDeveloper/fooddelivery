import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/admin_dashboard_stats.dart';

abstract interface class AdminDataSource {
  Future<AdminDashboardStats> getDashboardStats();
  Future<List<Map<String, dynamic>>> getUsers();
  Future<List<Map<String, dynamic>>> getRestaurants();
  Future<void> toggleUserStatus(String userId, bool isActive);
  Future<void> toggleRestaurantApproval(String restaurantId, bool isApproved);
}

class AdminRemoteDataSource implements AdminDataSource {
  final FirebaseFirestore? firestore;

  final List<Map<String, dynamic>> _mockUsers = [
    {
      'id': 'u_01',
      'name': 'Rahul Sharma',
      'email': 'rahul@example.com',
      'role': 'customer',
      'isActive': true,
      'createdAt': '2026-10-10',
    },
    {
      'id': 'u_02',
      'name': 'Pooja Verma',
      'email': 'pooja@example.com',
      'role': 'customer',
      'isActive': true,
      'createdAt': '2026-10-12',
    },
    {
      'id': 'u_03',
      'name': 'Suspicious User',
      'email': 'badactor@example.com',
      'role': 'customer',
      'isActive': false,
      'createdAt': '2026-10-15',
    },
  ];

  final List<Map<String, dynamic>> _mockRestaurants = [
    {
      'id': 'r1',
      'name': 'Burger Hub',
      'cuisine': 'American, Fast Food',
      'isApproved': true,
      'rating': 4.5,
    },
    {
      'id': 'r2',
      'name': 'Biryani Junction',
      'cuisine': 'Hyderabadi, Indian',
      'isApproved': true,
      'rating': 4.7,
    },
    {
      'id': 'r3',
      'name': 'New Taco Corner (Pending)',
      'cuisine': 'Mexican',
      'isApproved': false,
      'rating': 0.0,
    },
  ];

  AdminRemoteDataSource([this.firestore]);

  @override
  Future<AdminDashboardStats> getDashboardStats() async {
    final client = firestore;
    if (client != null) {
      try {
        final usersSnap = await client.collection('users').get();
        final restSnap = await client.collection('restaurants').get();
        final ordersSnap = await client.collection('orders').get();

        int completed = 0;
        int cancelled = 0;
        double revenue = 0.0;

        for (final doc in ordersSnap.docs) {
          final data = doc.data();
          final status = (data['status'] ?? '').toString().toLowerCase();
          final total =
              (data['totalAmount'] as num?)?.toDouble() ??
              (data['total'] as num?)?.toDouble() ??
              0.0;

          if (status == 'delivered') {
            completed++;
            revenue += total;
          } else if (status == 'cancelled' || status == 'rejected') {
            cancelled++;
          }
        }

        return AdminDashboardStats(
          totalUsers: usersSnap.docs.length,
          totalRestaurants: restSnap.docs.length,
          totalOrders: ordersSnap.docs.length,
          completedOrders: completed,
          cancelledOrders: cancelled,
          totalRevenue: revenue,
        );
      } catch (_) {
        // Fall back to local mock data
      }
    }

    return const AdminDashboardStats(
      totalUsers: 1420,
      totalRestaurants: 48,
      totalOrders: 3260,
      completedOrders: 3110,
      cancelledOrders: 82,
      totalRevenue: 1245000.0,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getUsers() async {
    final client = firestore;
    if (client != null) {
      try {
        final snap = await client.collection('users').get();
        return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
      } catch (_) {}
    }
    return _mockUsers;
  }

  @override
  Future<List<Map<String, dynamic>>> getRestaurants() async {
    final client = firestore;
    if (client != null) {
      try {
        final snap = await client.collection('restaurants').get();
        return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
      } catch (_) {}
    }
    return _mockRestaurants;
  }

  @override
  Future<void> toggleUserStatus(String userId, bool isActive) async {
    final client = firestore;
    if (client != null) {
      await client.collection('users').doc(userId).update({
        'isActive': isActive,
      });
      return;
    }
    final index = _mockUsers.indexWhere((u) => u['id'] == userId);
    if (index >= 0) {
      _mockUsers[index]['isActive'] = isActive;
    }
  }

  @override
  Future<void> toggleRestaurantApproval(
    String restaurantId,
    bool isApproved,
  ) async {
    final client = firestore;
    if (client != null) {
      await client.collection('restaurants').doc(restaurantId).update({
        'isApproved': isApproved,
      });
      return;
    }
    final index = _mockRestaurants.indexWhere((r) => r['id'] == restaurantId);
    if (index >= 0) {
      _mockRestaurants[index]['isApproved'] = isApproved;
    }
  }
}
