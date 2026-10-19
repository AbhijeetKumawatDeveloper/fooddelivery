import 'package:equatable/equatable.dart';

import '../../domain/entities/admin_dashboard_stats.dart';

class AdminDashboardState extends Equatable {
  final bool isLoading;
  final AdminDashboardStats? stats;
  final List<Map<String, dynamic>> users;
  final List<Map<String, dynamic>> restaurants;
  final int selectedTab;
  final String? errorMessage;
  final String? successMessage;

  const AdminDashboardState({
    this.isLoading = false,
    this.stats,
    this.users = const [],
    this.restaurants = const [],
    this.selectedTab = 0,
    this.errorMessage,
    this.successMessage,
  });

  AdminDashboardState copyWith({
    bool? isLoading,
    AdminDashboardStats? stats,
    List<Map<String, dynamic>>? users,
    List<Map<String, dynamic>>? restaurants,
    int? selectedTab,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AdminDashboardState(
      isLoading: isLoading ?? this.isLoading,
      stats: stats ?? this.stats,
      users: users ?? this.users,
      restaurants: restaurants ?? this.restaurants,
      selectedTab: selectedTab ?? this.selectedTab,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    stats,
    users,
    restaurants,
    selectedTab,
    errorMessage,
    successMessage,
  ];
}
