import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_core/core/di/injection.dart';

import '../../domain/entities/restaurant_order.dart';
import '../cubit/partner_order_cubit.dart';
import '../cubit/partner_order_state.dart';

class PartnerOrdersScreen extends StatelessWidget {
  final String restaurantId;
  final String initialFilter;

  const PartnerOrdersScreen({
    super.key,
    this.restaurantId = 'r1',
    this.initialFilter = 'All',
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PartnerOrderCubit>()..listenToOrders(restaurantId),
      child: _PartnerOrdersView(
        restaurantId: restaurantId,
        initialFilter: initialFilter,
      ),
    );
  }
}

class _PartnerOrdersView extends StatefulWidget {
  final String restaurantId;
  final String initialFilter;

  const _PartnerOrdersView({
    required this.restaurantId,
    required this.initialFilter,
  });

  @override
  State<_PartnerOrdersView> createState() => _PartnerOrdersViewState();
}

class _PartnerOrdersViewState extends State<_PartnerOrdersView> {
  late String _currentFilter;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.initialFilter;
  }

  Color _getStatusColor(RestaurantOrderStatus status) {
    switch (status) {
      case RestaurantOrderStatus.pending:
        return Colors.orange;
      case RestaurantOrderStatus.accepted:
        return Colors.blue;
      case RestaurantOrderStatus.preparing:
        return Colors.deepPurple;
      case RestaurantOrderStatus.readyForPickup:
        return Colors.indigo;
      case RestaurantOrderStatus.pickedUp:
        return Colors.teal;
      case RestaurantOrderStatus.delivered:
        return Colors.green;
      case RestaurantOrderStatus.rejected:
      case RestaurantOrderStatus.cancelled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Management')),
      body: BlocConsumer<PartnerOrderCubit, PartnerOrderState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          List<RestaurantOrder> displayedOrders;
          if (_currentFilter == 'Pending') {
            displayedOrders = state.pendingOrders;
          } else if (_currentFilter == 'Active') {
            displayedOrders = state.activeOrders;
          } else if (_currentFilter == 'Completed') {
            displayedOrders = state.completedOrders;
          } else {
            displayedOrders = state.orders;
          }

          return Column(
            children: [
              // Filter Chips Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    _buildFilterChip('All (${state.totalOrdersCount})', 'All'),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Pending (${state.pendingCount})',
                      'Pending',
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Active (${state.inProgressCount})',
                      'Active',
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Completed (${state.completedCount})',
                      'Completed',
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Orders List
              Expanded(
                child: displayedOrders.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.assignment_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No $_currentFilter orders found',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await context.read<PartnerOrderCubit>().loadOrders(
                            widget.restaurantId,
                          );
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: displayedOrders.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final order = displayedOrders[index];
                            final color = _getStatusColor(order.status);
                            final cubit = context.read<PartnerOrderCubit>();

                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Order Header
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Order #${order.id.substring(0, order.id.length > 8 ? 8 : order.id.length).toUpperCase()}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: color.withAlpha(25),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            order.status.label,
                                            style: TextStyle(
                                              color: color,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Customer: ${order.customerName}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      'Delivery to: ${order.customerAddress}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const Divider(height: 18),

                                    // Items List
                                    ...order.items.map(
                                      (item) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 2,
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.circle,
                                              size: 6,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                item,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const Divider(height: 18),

                                    // Order Footer & Total
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Order Total',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          '₹${order.total.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),

                                    // Action Buttons based on status
                                    _buildOrderActions(order, cubit),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String filterValue) {
    final isSelected = _currentFilter == filterValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _currentFilter = filterValue);
        }
      },
    );
  }

  Widget _buildOrderActions(RestaurantOrder order, PartnerOrderCubit cubit) {
    switch (order.status) {
      case RestaurantOrderStatus.pending:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () => cubit.rejectOrder(order.id),
                child: const Text('Reject'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () => cubit.acceptOrder(order.id),
                child: const Text('Accept Order'),
              ),
            ),
          ],
        );

      case RestaurantOrderStatus.accepted:
        return SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.deepPurple),
            onPressed: () => cubit.startPreparing(order.id),
            icon: const Icon(Icons.soup_kitchen),
            label: const Text('Start Preparing Food'),
          ),
        );

      case RestaurantOrderStatus.preparing:
        return SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.indigo),
            onPressed: () => cubit.markReadyForPickup(order.id),
            icon: const Icon(Icons.takeout_dining),
            label: const Text('Mark Ready for Pickup'),
          ),
        );

      case RestaurantOrderStatus.readyForPickup:
        return SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () => cubit.markPickedUp(order.id),
            icon: const Icon(Icons.delivery_dining),
            label: const Text('Handover / Out for Delivery'),
          ),
        );

      case RestaurantOrderStatus.pickedUp:
        return SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => cubit.markDelivered(order.id),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Mark as Delivered'),
          ),
        );

      case RestaurantOrderStatus.delivered:
      case RestaurantOrderStatus.rejected:
      case RestaurantOrderStatus.cancelled:
        return const SizedBox.shrink();
    }
  }
}
