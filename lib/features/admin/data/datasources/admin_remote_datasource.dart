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
      'email': 'rahul.sharma@example.com',
      'phone': '+91 98765 43210',
      'role': 'customer',
      'isActive': true,
      'ordersCount': 18,
      'totalSpent': '₹4,890',
      'createdAt': '2026-10-10',
    },
    {
      'id': 'u_02',
      'name': 'Pooja Verma',
      'email': 'pooja.verma@example.com',
      'phone': '+91 98234 56789',
      'role': 'customer',
      'isActive': true,
      'ordersCount': 24,
      'totalSpent': '₹7,420',
      'createdAt': '2026-10-12',
    },
    {
      'id': 'u_03',
      'name': 'Vikram Singh (Rider)',
      'email': 'vikram.delivery@foodgo.com',
      'phone': '+91 91234 56789',
      'role': 'rider',
      'isActive': true,
      'ordersCount': 142,
      'totalSpent': 'N/A',
      'createdAt': '2026-10-01',
    },
    {
      'id': 'u_04',
      'name': 'Chef Rajesh (Domino\'s Partner)',
      'email': 'partner.dominos@foodgo.com',
      'phone': '+91 98888 77777',
      'role': 'partner',
      'isActive': true,
      'ordersCount': 310,
      'totalSpent': 'N/A',
      'createdAt': '2026-09-15',
    },
    {
      'id': 'u_05',
      'name': 'Ananya Roy',
      'email': 'ananya.roy@example.com',
      'phone': '+91 97777 66666',
      'role': 'customer',
      'isActive': true,
      'ordersCount': 9,
      'totalSpent': '₹2,650',
      'createdAt': '2026-10-14',
    },
    {
      'id': 'u_03',
      'name': 'Suspicious User',
      'email': 'badactor@example.com',
      'phone': '+91 90000 00000',
      'role': 'customer',
      'isActive': false,
      'ordersCount': 1,
      'totalSpent': '₹120',
      'createdAt': '2026-10-15',
    },
    {
      'id': 'u_04',
      'name': 'Vikram Singh (Rider)',
      'email': 'vikram.delivery@foodgo.com',
      'phone': '+91 91234 56789',
      'role': 'rider',
      'isActive': true,
      'ordersCount': 142,
      'totalSpent': 'N/A',
      'createdAt': '2026-10-01',
    },
    {
      'id': 'u_05',
      'name': 'Chef Rajesh (Domino\'s Partner)',
      'email': 'partner.dominos@foodgo.com',
      'phone': '+91 98888 77777',
      'role': 'partner',
      'isActive': true,
      'ordersCount': 310,
      'totalSpent': 'N/A',
      'createdAt': '2026-09-15',
    },
    {
      'id': 'u_06',
      'name': 'Ananya Roy',
      'email': 'ananya.roy@example.com',
      'phone': '+91 97777 66666',
      'role': 'customer',
      'isActive': true,
      'ordersCount': 9,
      'totalSpent': '₹2,650',
      'createdAt': '2026-10-14',
    },
  ];

  final List<Map<String, dynamic>> _mockRestaurants = [
    {
      'id': 'r1',
      'name': 'Burger Hub',
      'cuisine': 'Burgers, American, Fast Food',
      'isApproved': true,
      'rating': 4.5,
      'ordersCount': 248,
      'commission': '20%',
      'city': 'Indiranagar, Bengaluru',
    },
    {
      'id': 'r2',
      'name': 'Biryani Junction',
      'cuisine': 'Hyderabadi, Biryani, Mughlai',
      'isApproved': true,
      'rating': 4.7,
      'ordersCount': 512,
      'commission': '20%',
      'city': 'HSR Layout, Bengaluru',
    },
    {
      'id': 'r3',
      'name': 'New Taco Corner (Pending)',
      'cuisine': 'Mexican, Fast Food',
      'isApproved': false,
      'rating': 0.0,
      'ordersCount': 0,
      'commission': '15%',
      'city': 'Koramangala, Bengaluru',
    },
    {
      'id': 'r4',
      'name': 'Domino\'s Gourmet Pizza',
      'cuisine': 'Pizza, Italian, Fast Food',
      'isApproved': true,
      'rating': 4.4,
      'ordersCount': 420,
      'commission': '18%',
      'city': 'Koramangala, Bengaluru',
    },
    {
      'id': 'r5',
      'name': 'Bawarchi Dum Biryani',
      'cuisine': 'Hyderabadi, Biryani, Mughlai',
      'isApproved': true,
      'rating': 4.7,
      'ordersCount': 512,
      'commission': '20%',
      'city': 'HSR Layout, Bengaluru',
    },
    {
      'id': 'r4',
      'name': 'Haldiram\'s Sweets & Thali',
      'cuisine': 'North Indian, Pure Veg, Mithai',
      'isApproved': true,
      'rating': 4.6,
      'ordersCount': 340,
      'commission': '15%',
      'city': 'Whitefield, Bengaluru',
    },
    {
      'id': 'r5',
      'name': 'KFC Crispy Chicken',
      'cuisine': 'Fried Chicken, Fast Food, Wings',
      'isApproved': true,
      'rating': 4.3,
      'ordersCount': 290,
      'commission': '18%',
      'city': 'MG Road, Bengaluru',
    },
    {
      'id': 'r6',
      'name': 'China Town Wok Express',
      'cuisine': 'Chinese, Noodles, Dim Sums',
      'isApproved': true,
      'rating': 4.4,
      'ordersCount': 195,
      'commission': '20%',
      'city': 'Jayanagar, Bengaluru',
    },
    {
      'id': 'r7',
      'name': 'The Belgian Waffle Co.',
      'cuisine': 'Desserts, Waffles, Shakes',
      'isApproved': true,
      'rating': 4.8,
      'ordersCount': 160,
      'commission': '22%',
      'city': 'Church Street, Bengaluru',
    },
    {
      'id': 'r8',
      'name': 'New Taco Corner & Burrito Bar (Pending)',
      'cuisine': 'Mexican, Burritos, Quesadillas',
      'isApproved': false,
      'rating': 0.0,
      'ordersCount': 0,
      'commission': '20%',
      'city': 'Kalyan Nagar, Bengaluru',
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
