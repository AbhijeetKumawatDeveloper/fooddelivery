import 'package:equatable/equatable.dart';

class AdminDashboardStats extends Equatable {
  final int totalUsers;
  final int totalRestaurants;
  final int totalOrders;
  final int completedOrders;
  final int cancelledOrders;
  final double totalRevenue;

  const AdminDashboardStats({
    required this.totalUsers,
    required this.totalRestaurants,
    required this.totalOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.totalRevenue,
  });

  double get completionRate =>
      totalOrders == 0 ? 0.0 : (completedOrders / totalOrders) * 100;

  @override
  List<Object?> get props => [
    totalUsers,
    totalRestaurants,
    totalOrders,
    completedOrders,
    cancelledOrders,
    totalRevenue,
  ];
}
