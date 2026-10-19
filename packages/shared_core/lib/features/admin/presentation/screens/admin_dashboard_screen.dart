import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_core/core/di/injection.dart';

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

class _AdminDashboardView extends StatefulWidget {
  const _AdminDashboardView();

  @override
  State<_AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<_AdminDashboardView> {
  String _restaurantSearch = '';
  String _userSearch = '';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

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
        if (state.isLoading && state.stats == null) {
          return const Scaffold(
            backgroundColor: Color(0xFF0F172A),
            body: Center(
              child: CircularProgressIndicator(
                key: Key('admin_loading_indicator'),
                color: Color(0xFFEF4444),
              ),
            ),
          );
        }

        if (isDesktop) {
          return Scaffold(
            backgroundColor: const Color(0xFFF1F5F9),
            body: Row(
              children: [
                // Web/Desktop Sidebar (Zomato Business Style)
                _buildDesktopSidebar(context, state),

                // Main Content Body
                Expanded(
                  child: Column(
                    children: [
                      _buildDesktopTopBar(context, state),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () => context
                              .read<AdminDashboardCubit>()
                              .loadDashboardData(),
                          child: IndexedStack(
                            index: state.selectedTab.clamp(0, 2),
                            children: [
                              _buildOverviewTab(context, state, isDesktop: true),
                              _buildRestaurantsTab(context, state),
                              _buildUsersTab(context, state),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // Mobile Layout
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0F172A),
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
                  style: TextStyle(fontSize: 11, color: Colors.white70),
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
                color: const Color(0xFF1E293B),
                child: Row(
                  children: [
                    _buildMobileTabItem(
                      context,
                      state,
                      0,
                      'Overview',
                      Icons.analytics_outlined,
                    ),
                    _buildMobileTabItem(
                      context,
                      state,
                      1,
                      'Restaurants',
                      Icons.storefront_outlined,
                    ),
                    _buildMobileTabItem(
                      context,
                      state,
                      2,
                      'Users',
                      Icons.people_outline,
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () =>
                context.read<AdminDashboardCubit>().loadDashboardData(),
            child: IndexedStack(
              index: state.selectedTab.clamp(0, 2),
              children: [
                _buildOverviewTab(context, state, isDesktop: false),
                _buildRestaurantsTab(context, state),
                _buildUsersTab(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopSidebar(
    BuildContext context,
    AdminDashboardState state,
  ) {
    return Container(
      width: 250,
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & Brand
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE23744),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.restaurant,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FoodGo Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    'Platform Console',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Live Operations Beacon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'SYSTEM ONLINE',
                  style: TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'MANAGEMENT',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),

          // Sidebar Tab Items
          _buildSidebarNavButton(
            context,
            state,
            0,
            'Dashboard Overview',
            Icons.dashboard_outlined,
          ),
          const SizedBox(height: 6),
          _buildSidebarNavButton(
            context,
            state,
            1,
            'Restaurant Partners',
            Icons.storefront_outlined,
            badge: '${state.restaurants.where((r) => r['isApproved'] == false).length} Pending',
          ),
          const SizedBox(height: 6),
          _buildSidebarNavButton(
            context,
            state,
            2,
            'Users & Customers',
            Icons.people_outline,
            badge: '${state.users.length}',
          ),

          const Spacer(),

          // Admin User Profile Footer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFFE23744),
                  child: Text(
                    'AD',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Super Admin',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'admin@foodgo.com',
                        style: TextStyle(color: Colors.white54, fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarNavButton(
    BuildContext context,
    AdminDashboardState state,
    int index,
    String title,
    IconData icon, {
    String? badge,
  }) {
    final isSelected = state.selectedTab == index;
    return InkWell(
      key: Key('admin_tab_$index'),
      onTap: () => context.read<AdminDashboardCubit>().setTab(index),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE23744) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.white70,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withAlpha(50)
                      : Colors.white.withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopTopBar(
    BuildContext context,
    AdminDashboardState state,
  ) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                state.selectedTab == 0
                    ? 'Platform Overview'
                    : state.selectedTab == 1
                    ? 'Restaurant Partner Management'
                    : 'Customer & User Governance',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Live Sync Active',
                  style: TextStyle(
                    color: Color(0xFF059669),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              FilledButton.icon(
                key: const Key('admin_refresh_button'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                ),
                onPressed: () =>
                    context.read<AdminDashboardCubit>().loadDashboardData(),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh Data', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileTabItem(
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
                    ? const Color(0xFFEF4444)
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

  Widget _buildOverviewTab(
    BuildContext context,
    AdminDashboardState state, {
    required bool isDesktop,
  }) {
    final stats = state.stats;
    if (stats == null) {
      return const Center(child: Text('No analytics data available'));
    }

    return ListView(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      children: [
        // KPI Metric Cards Grid
        if (isDesktop)
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'Gross Revenue',
                  value: '₹${stats.totalRevenue.toStringAsFixed(0)}',
                  subtitle: '+24.5% this month',
                  icon: Icons.currency_rupee,
                  iconColor: const Color(0xFF10B981),
                  bgColor: const Color(0xFFECFDF5),
                ),
              ),
              const SizedBox(width: 16),
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
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  title: 'Active Customers',
                  value: '${stats.totalUsers}',
                  subtitle: 'Registered accounts',
                  icon: Icons.people,
                  iconColor: const Color(0xFF8B5CF6),
                  bgColor: const Color(0xFFF5F3FF),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  title: 'Restaurant Partners',
                  value: '${stats.totalRestaurants}',
                  subtitle:
                      '${state.restaurants.where((r) => r['isApproved'] == true).length} active onboarded',
                  icon: Icons.restaurant,
                  iconColor: const Color(0xFFF59E0B),
                  bgColor: const Color(0xFFFFFBEB),
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Total Revenue',
                      value: '₹${stats.totalRevenue.toStringAsFixed(0)}',
                      subtitle: '+24.5% vs last mo',
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
                          '${stats.completionRate.toStringAsFixed(1)}% fulfilled',
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
                      subtitle: 'Platform users',
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
                          '${state.restaurants.where((r) => r['isApproved'] == true).length} active',
                      icon: Icons.restaurant,
                      iconColor: const Color(0xFFF59E0B),
                      bgColor: const Color(0xFFFFFBEB),
                    ),
                  ),
                ],
              ),
            ],
          ),

        const SizedBox(height: 24),

        // Side-by-side or stacked: Fulfillment Health & System Status
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _buildFulfillmentHealthCard(stats),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: _buildSystemServicesCard(),
              ),
            ],
          )
        else
          Column(
            children: [
              _buildFulfillmentHealthCard(stats),
              const SizedBox(height: 16),
              _buildSystemServicesCard(),
            ],
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
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

  Widget _buildFulfillmentHealthCard(dynamic stats) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.pie_chart, size: 20, color: Color(0xFF0F172A)),
                SizedBox(width: 8),
                Text(
                  'Fulfillment Health',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildHealthRow(
              label: 'Completed & Delivered Orders',
              count: stats.completedOrders,
              percentage: stats.completionRate,
              color: const Color(0xFF10B981),
            ),
            const Divider(height: 28),
            _buildHealthRow(
              label: 'Cancelled / Rejected Orders',
              count: stats.cancelledOrders,
              percentage: stats.totalOrders == 0
                  ? 0.0
                  : (stats.cancelledOrders / stats.totalOrders) * 100,
              color: const Color(0xFFEF4444),
            ),
            const Divider(height: 28),
            _buildHealthRow(
              label: 'In Progress & Active Transit',
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
    );
  }

  Widget _buildSystemServicesCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.shield_outlined, size: 20, color: Color(0xFF10B981)),
                SizedBox(width: 8),
                Text(
                  'Live Infrastructure',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatusIndicator(
              'Cloud Firestore Live DB',
              'Operational',
              const Color(0xFF10B981),
            ),
            const SizedBox(height: 12),
            _buildStatusIndicator(
              'Firebase Auth Gatekeeper',
              'Operational',
              const Color(0xFF10B981),
            ),
            const SizedBox(height: 12),
            _buildStatusIndicator(
              'Razorpay Payment Node',
              'Test Mode Active',
              const Color(0xFF3B82F6),
            ),
            const SizedBox(height: 12),
            _buildStatusIndicator(
              'Geolocator GPS Tracking',
              'Active',
              const Color(0xFF10B981),
            ),
            const SizedBox(height: 12),
            _buildStatusIndicator(
              'Push Dispatch Daemon',
              'Listening',
              const Color(0xFF10B981),
            ),
          ],
        ),
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
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            Text(
              '$count (${percentage.toStringAsFixed(1)}%)',
              style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13),
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
            minHeight: 8,
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
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            service,
            style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
          ),
        ),
        Text(
          status,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildRestaurantsTab(BuildContext context, AdminDashboardState state) {
    final filtered = state.restaurants.where((r) {
      if (_restaurantSearch.isEmpty) return true;
      final q = _restaurantSearch.toLowerCase();
      final name = (r['name'] as String? ?? '').toLowerCase();
      final cuisine = (r['cuisine'] as String? ?? '').toLowerCase();
      return name.contains(q) || cuisine.contains(q);
    }).toList();

    return Column(
      children: [
        // Search & Filter Header
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: TextField(
            onChanged: (val) {
              setState(() {
                _restaurantSearch = val.trim();
              });
            },
            decoration: InputDecoration(
              hintText: 'Search restaurant partners by name, cuisine, city...',
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
            ),
          ),
        ),

        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No restaurant partners found'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final restaurant = filtered[index];
                    final id = restaurant['id'] as String? ?? '';
                    final name = restaurant['name'] as String? ?? 'Unnamed';
                    final cuisine = restaurant['cuisine'] as String? ?? '';
                    final isApproved =
                        restaurant['isApproved'] as bool? ?? false;
                    final rating =
                        (restaurant['rating'] as num?)?.toDouble() ?? 0.0;
                    final city =
                        restaurant['city'] as String? ?? 'Indiranagar, Bengaluru';
                    final commission =
                        restaurant['commission'] as String? ?? '20%';

                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isApproved
                              ? Colors.grey.shade200
                              : Colors.amber.shade400,
                          width: isApproved ? 1 : 1.5,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isApproved
                                    ? const Color(0xFFECFDF5)
                                    : const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.storefront,
                                color: isApproved
                                    ? const Color(0xFF059669)
                                    : const Color(0xFFD97706),
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
                                            color: Color(0xFF0F172A),
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
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          isApproved
                                              ? 'Active'
                                              : 'Pending Approval',
                                          style: TextStyle(
                                            color: isApproved
                                                ? const Color(0xFF059669)
                                                : const Color(0xFFD97706),
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
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
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        size: 14,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        rating.toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'City: $city',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Comm: $commission',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF3B82F6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Switch(
                              key: Key('toggle_restaurant_$id'),
                              value: isApproved,
                              activeThumbColor: const Color(0xFF10B981),
                              onChanged: (val) {
                                context
                                    .read<AdminDashboardCubit>()
                                    .toggleRestaurantApproval(id, val);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildUsersTab(BuildContext context, AdminDashboardState state) {
    final filtered = state.users.where((u) {
      if (_userSearch.isEmpty) return true;
      final q = _userSearch.toLowerCase();
      final name = (u['name'] as String? ?? '').toLowerCase();
      final email = (u['email'] as String? ?? '').toLowerCase();
      return name.contains(q) || email.contains(q);
    }).toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: TextField(
            onChanged: (val) {
              setState(() {
                _userSearch = val.trim();
              });
            },
            decoration: InputDecoration(
              hintText: 'Search users by name, email, phone...',
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
            ),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No users match your query'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final user = filtered[index];
                    final id = user['id'] as String? ?? '';
                    final name = user['name'] as String? ?? 'Unnamed';
                    final email = user['email'] as String? ?? '';
                    final role = user['role'] as String? ?? 'customer';
                    final isActive = user['isActive'] as bool? ?? true;
                    final phone = user['phone'] as String? ?? '+91 98765 00000';
                    final ordersCount = user['ordersCount'] ?? 12;

                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: role == 'partner'
                                  ? const Color(0xFFFFF7ED)
                                  : role == 'rider'
                                  ? const Color(0xFFECFDF5)
                                  : const Color(0xFFEFF6FF),
                              child: Icon(
                                role == 'partner'
                                    ? Icons.storefront
                                    : role == 'rider'
                                    ? Icons.two_wheeler
                                    : Icons.person,
                                color: role == 'partner'
                                    ? const Color(0xFFE65100)
                                    : role == 'rider'
                                    ? const Color(0xFF00897B)
                                    : const Color(0xFF3B82F6),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          role.toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF475569),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    email,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Phone: $phone • Orders: $ordersCount',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              key: Key('toggle_user_$id'),
                              value: isActive,
                              activeThumbColor: const Color(0xFF10B981),
                              onChanged: (val) {
                                context
                                    .read<AdminDashboardCubit>()
                                    .toggleUserStatus(id, val);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
