import '../../domain/entities/admin_dashboard_stats.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminDataSource dataSource;

  AdminRepositoryImpl(this.dataSource);

  @override
  Future<AdminDashboardStats> getDashboardStats() =>
      dataSource.getDashboardStats();

  @override
  Future<List<Map<String, dynamic>>> getUsers() => dataSource.getUsers();

  @override
  Future<List<Map<String, dynamic>>> getRestaurants() =>
      dataSource.getRestaurants();

  @override
  Future<void> toggleUserStatus(String userId, bool isActive) =>
      dataSource.toggleUserStatus(userId, isActive);

  @override
  Future<void> toggleRestaurantApproval(String restaurantId, bool isApproved) =>
      dataSource.toggleRestaurantApproval(restaurantId, isApproved);
}
