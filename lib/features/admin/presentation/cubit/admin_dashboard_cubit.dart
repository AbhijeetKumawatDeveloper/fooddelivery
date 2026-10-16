import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/admin_repository.dart';
import '../../domain/usecases/get_dashboard_stats.dart';
import 'admin_dashboard_state.dart';

class AdminDashboardCubit extends Cubit<AdminDashboardState> {
  final GetDashboardStats getDashboardStats;
  final AdminRepository repository;

  AdminDashboardCubit({
    required this.getDashboardStats,
    required this.repository,
  }) : super(const AdminDashboardState());

  Future<void> loadDashboardData() async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    try {
      final results = await Future.wait([
        getDashboardStats(),
        repository.getUsers(),
        repository.getRestaurants(),
      ]);

      emit(
        state.copyWith(
          isLoading: false,
          stats: results[0] as dynamic,
          users: (results[1] as List).cast<Map<String, dynamic>>(),
          restaurants: (results[2] as List).cast<Map<String, dynamic>>(),
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load dashboard data: $e',
        ),
      );
    }
  }

  void setTab(int index) {
    emit(state.copyWith(selectedTab: index));
  }

  Future<void> toggleRestaurantApproval(
    String restaurantId,
    bool isApproved,
  ) async {
    try {
      await repository.toggleRestaurantApproval(restaurantId, isApproved);
      final updatedRestaurants = state.restaurants.map((r) {
        if (r['id'] == restaurantId) {
          final updated = Map<String, dynamic>.from(r);
          updated['isApproved'] = isApproved;
          return updated;
        }
        return r;
      }).toList();

      emit(
        state.copyWith(
          restaurants: updatedRestaurants,
          successMessage: isApproved
              ? 'Restaurant approved successfully'
              : 'Restaurant revoked',
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Failed to update restaurant status: $e',
          clearSuccess: true,
        ),
      );
    }
  }

  Future<void> toggleUserStatus(String userId, bool isActive) async {
    try {
      await repository.toggleUserStatus(userId, isActive);
      final updatedUsers = state.users.map((u) {
        if (u['id'] == userId) {
          final updated = Map<String, dynamic>.from(u);
          updated['isActive'] = isActive;
          return updated;
        }
        return u;
      }).toList();

      emit(
        state.copyWith(
          users: updatedUsers,
          successMessage: isActive
              ? 'User account activated'
              : 'User account suspended',
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Failed to update user status: $e',
          clearSuccess: true,
        ),
      );
    }
  }
}
