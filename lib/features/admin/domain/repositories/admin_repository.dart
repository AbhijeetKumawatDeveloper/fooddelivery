import '../entities/admin_dashboard_stats.dart';

abstract class AdminRepository {
  Future<AdminDashboardStats> getDashboardStats();
  Future<List<Map<String, dynamic>>> getUsers();
  Future<List<Map<String, dynamic>>> getRestaurants();
  Future<void> toggleUserStatus(String userId, bool isActive);
  Future<void> toggleRestaurantApproval(String restaurantId, bool isApproved);
}
