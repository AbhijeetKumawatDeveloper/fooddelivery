import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fooddelivery/core/di/injection.dart';

import '../cubit/admin_dashboard_cubit.dart';
import '../cubit/admin_dashboard_state.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminDashboardCubit>()..loadDashboardData(),
      child: const _AdminDashboardView(),
    );
  }
}

class _AdminDashboardView extends StatelessWidget {
  const _AdminDashboardView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminDashboardCubit, AdminDashboardState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red.shade700,
            ),
          );
        } else if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: Colors.green.shade700,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1E293B),
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FoodGo Admin Portal',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  'Platform Analytics & Governance',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
            actions: [
              IconButton(
                key: const Key('admin_refresh_button'),
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh metrics',
                onPressed: () =>
                    context.read<AdminDashboardCubit>().loadDashboardData(),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: const Color(0xFF0F172A),
                child: Row(
                  children: [
                    _buildTabItem(
                      context,
                      state,
                      0,
                      'Overview',
                      Icons.analytics,
                    ),
                    _buildTabItem(
                      context,
                      state,
                      1,
                      'Restaurants',
                      Icons.storefront,
                    ),
                    _buildTabItem(context, state, 2, 'Users', Icons.people_alt),
                  ],
                ),
              ),
            ),
          ),
          body: state.isLoading && state.stats == null
              ? const Center(
                  child: CircularProgressIndicator(
                    key: Key('admin_loading_indicator'),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      context.read<AdminDashboardCubit>().loadDashboardData(),
                  child: IndexedStack(
                    index: state.selectedTab,
                    children: [
                      _buildOverviewTab(context, state),
                      _buildRestaurantsTab(context, state),
                      _buildUsersTab(context, state),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildTabItem(
    BuildContext context,
    AdminDashboardState state,
    int index,
    String title,
    IconData icon,
  ) {
    final isSelected = state.selectedTab == index;
    return Expanded(
      child: InkWell(
        key: Key('admin_tab_$index'),
        onTap: () => context.read<AdminDashboardCubit>().setTab(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? const Color(0xFFEF4F5F)
                    : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.white60,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white60,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, AdminDashboardState state) {
    final stats = state.stats;
    if (stats == null) {
      return const Center(child: Text('No analytics data available'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // KPI Grid
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Total Revenue',
                value: '₹${stats.totalRevenue.toStringAsFixed(0)}',
                subtitle: '+18.4% this month',
                icon: Icons.currency_rupee,
                iconColor: const Color(0xFF10B981),
                bgColor: const Color(0xFFECFDF5),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Total Orders',
                value: '${stats.totalOrders}',
                subtitle:
                    '${stats.completionRate.toStringAsFixed(1)}% fulfillment',
                icon: Icons.receipt_long,
                iconColor: const Color(0xFF3B82F6),
                bgColor: const Color(0xFFEFF6FF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Active Users',
                value: '${stats.totalUsers}',
                subtitle: 'Platform customers',
                icon: Icons.people,
                iconColor: const Color(0xFF8B5CF6),
                bgColor: const Color(0xFFF5F3FF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Restaurants',
                value: '${stats.totalRestaurants}',
                subtitle:
                    '${state.restaurants.where((r) => r['isApproved'] == true).length} active partners',
                icon: Icons.restaurant,
                iconColor: const Color(0xFFF59E0B),
                bgColor: const Color(0xFFFFFBEB),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Order Health Breakdown
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.pie_chart, size: 20, color: Color(0xFF1E293B)),
                    SizedBox(width: 8),
                    Text(
                      'Fulfillment Health',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildHealthRow(
                  label: 'Completed & Delivered',
                  count: stats.completedOrders,
                  percentage: stats.completionRate,
                  color: const Color(0xFF10B981),
                ),
                const Divider(height: 24),
                _buildHealthRow(
                  label: 'Cancelled / Rejected',
                  count: stats.cancelledOrders,
                  percentage: stats.totalOrders == 0
                      ? 0.0
                      : (stats.cancelledOrders / stats.totalOrders) * 100,
                  color: const Color(0xFFEF4444),
                ),
                const Divider(height: 24),
                _buildHealthRow(
                  label: 'In Progress / Transit',
                  count:
                      stats.totalOrders -
                      (stats.completedOrders + stats.cancelledOrders),
                  percentage: stats.totalOrders == 0
                      ? 0.0
                      : ((stats.totalOrders -
                                    (stats.completedOrders +
                                        stats.cancelledOrders)) /
                                stats.totalOrders) *
                            100,
                  color: const Color(0xFF3B82F6),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // System Health & Infrastructure
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.shield, size: 20, color: Color(0xFF10B981)),
                    SizedBox(width: 8),
                    Text(
                      'System Security & Service Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildStatusIndicator(
                  'Cloud Firestore Engine',
                  'Operational',
                  Colors.green,
                ),
                const SizedBox(height: 8),
                _buildStatusIndicator(
                  'Firebase Auth Gatekeeper',
                  'Operational',
                  Colors.green,
                ),
                const SizedBox(height: 8),
                _buildStatusIndicator(
                  'Razorpay Payment Gateway',
                  'Test Mode Active',
                  Colors.blue,
                ),
                const SizedBox(height: 8),
                _buildStatusIndicator(
                  'Geolocator GPS Dispatcher',
                  'Ready',
                  Colors.green,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthRow({
    required String label,
    required int count,
    required double percentage,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(
              '$count (${percentage.toStringAsFixed(1)}%)',
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (percentage / 100).clamp(0.0, 1.0),
            backgroundColor: color.withAlpha(40),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(String service, String status, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            service,
            style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
          ),
        ),
        Text(
          status,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildRestaurantsTab(BuildContext context, AdminDashboardState state) {
    if (state.restaurants.isEmpty) {
      return const Center(child: Text('No restaurant partners registered'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.restaurants.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final restaurant = state.restaurants[index];
        final id = restaurant['id'] as String? ?? '';
        final name = restaurant['name'] as String? ?? 'Unnamed';
        final cuisine = restaurant['cuisine'] as String? ?? '';
        final isApproved = restaurant['isApproved'] as bool? ?? false;
        final rating = (restaurant['rating'] as num?)?.toDouble() ?? 0.0;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isApproved ? Colors.grey.shade200 : Colors.amber.shade300,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: isApproved
                      ? const Color(0xFF10B981).withAlpha(30)
                      : Colors.amber.shade100,
                  child: Icon(
                    Icons.restaurant,
                    color: isApproved
                        ? const Color(0xFF10B981)
                        : Colors.amber.shade800,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isApproved
                                  ? const Color(0xFFECFDF5)
                                  : const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isApproved ? 'Approved' : 'Pending',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isApproved
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFD97706),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cuisine,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  key: Key('toggle_restaurant_$id'),
                  value: isApproved,
                  activeThumbColor: const Color(0xFF10B981),
                  onChanged: (value) {
                    context
                        .read<AdminDashboardCubit>()
                        .toggleRestaurantApproval(id, value);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUsersTab(BuildContext context, AdminDashboardState state) {
    if (state.users.isEmpty) {
      return const Center(child: Text('No users found in directory'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.users.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = state.users[index];
        final id = user['id'] as String? ?? '';
        final name = user['name'] as String? ?? 'User';
        final email = user['email'] as String? ?? '';
        final role = user['role'] as String? ?? 'customer';
        final isActive = user['isActive'] as bool? ?? true;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isActive ? Colors.grey.shade200 : Colors.red.shade200,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: isActive
                      ? Colors.blue.shade50
                      : Colors.red.shade50,
                  child: Icon(
                    role == 'admin'
                        ? Icons.security
                        : role == 'delivery'
                        ? Icons.two_wheeler
                        : Icons.person,
                    color: isActive
                        ? Colors.blue.shade700
                        : Colors.red.shade700,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFFECFDF5)
                                  : const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isActive ? 'Active' : 'Suspended',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isActive
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Role: ${role.toUpperCase()}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  key: Key('toggle_user_$id'),
                  icon: Icon(
                    isActive ? Icons.block : Icons.check_circle_outline,
                    color: isActive
                        ? Colors.red.shade600
                        : Colors.green.shade600,
                  ),
                  tooltip: isActive ? 'Suspend Account' : 'Activate Account',
                  onPressed: () {
                    context.read<AdminDashboardCubit>().toggleUserStatus(
                      id,
                      !isActive,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
