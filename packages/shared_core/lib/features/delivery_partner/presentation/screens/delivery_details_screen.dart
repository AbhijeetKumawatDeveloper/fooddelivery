import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_core/core/di/injection.dart';

import '../../domain/entities/delivery_order.dart';
import '../cubit/delivery_cubit.dart';
import '../cubit/delivery_state.dart';

class DeliveryDetailsScreen extends StatelessWidget {
  final DeliveryOrder order;

  const DeliveryDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    Widget content = _DeliveryDetailsView(order: order);
    try {
      context.read<DeliveryCubit>();
    } catch (_) {
      content = BlocProvider(
        create: (_) => getIt<DeliveryCubit>(),
        child: content,
      );
    }
    return content;
  }
}

class _DeliveryDetailsView extends StatefulWidget {
  final DeliveryOrder order;

  const _DeliveryDetailsView({required this.order});

  @override
  State<_DeliveryDetailsView> createState() => _DeliveryDetailsViewState();
}

class _DeliveryDetailsViewState extends State<_DeliveryDetailsView> {
  late double _currentLat;
  late double _currentLng;

  @override
  void initState() {
    super.initState();
    _currentLat = widget.order.latitude;
    _currentLng = widget.order.longitude;
  }

  void _simulateGpsStep(BuildContext context, String orderId) {
    setState(() {
      _currentLat += 0.0015;
      _currentLng += 0.0012;
    });

    context.read<DeliveryCubit>().broadcastLocation(
      orderId,
      _currentLat,
      _currentLng,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Live GPS Broadcast: ${_currentLat.toStringAsFixed(4)}, ${_currentLng.toStringAsFixed(4)} sent to customer map',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  int _getStepIndex(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.assigned:
        return 0;
      case DeliveryStatus.accepted:
        return 1;
      case DeliveryStatus.pickedUp:
        return 2;
      case DeliveryStatus.onTheWay:
        return 3;
      case DeliveryStatus.delivered:
        return 4;
      case DeliveryStatus.cancelled:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Delivery #${widget.order.id.substring(0, widget.order.id.length > 8 ? 8 : widget.order.id.length).toUpperCase()}',
        ),
      ),
      body: BlocBuilder<DeliveryCubit, DeliveryState>(
        builder: (context, state) {
          final liveOrder = state.orders.firstWhere(
            (o) => o.id == widget.order.id,
            orElse: () => widget.order,
          );
          final currentStep = _getStepIndex(liveOrder.status);
          final cubit = context.read<DeliveryCubit>();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Order Progress Stepper Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Delivery Status',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              liveOrder.status.label,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Stepper progress indicator
                      Row(
                        children: [
                          _buildStepDot('Assigned', currentStep >= 0, theme),
                          _buildStepLine(currentStep >= 1, theme),
                          _buildStepDot('Accepted', currentStep >= 1, theme),
                          _buildStepLine(currentStep >= 2, theme),
                          _buildStepDot('Picked Up', currentStep >= 2, theme),
                          _buildStepLine(currentStep >= 3, theme),
                          _buildStepDot('On Way', currentStep >= 3, theme),
                          _buildStepLine(currentStep >= 4, theme),
                          _buildStepDot('Delivered', currentStep >= 4, theme),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Route & Addresses Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Route Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.store, color: Colors.blue, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'PICKUP FROM',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  liveOrder.restaurantName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const Text(
                                  'Indiranagar Kitchen Outlet, Bengaluru',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: SizedBox(
                          height: 24,
                          child: VerticalDivider(thickness: 2),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.navigation,
                            color: Colors.red,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'DELIVER TO',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  liveOrder.customerName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  liveOrder.deliveryAddress,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Live GPS Location Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.gps_fixed, color: Colors.green),
                              SizedBox(width: 8),
                              Text(
                                'Live GPS Tracking Beacon',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'TRANSMITTING',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                const Text(
                                  'Latitude',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _currentLat.toStringAsFixed(4),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 24,
                              child: VerticalDivider(),
                            ),
                            Column(
                              children: [
                                const Text(
                                  'Longitude',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _currentLng.toStringAsFixed(4),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () =>
                            _simulateGpsStep(context, liveOrder.id),
                        icon: const Icon(Icons.share_location),
                        label: const Text('Simulate Route Movement / Ping GPS'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Dynamic Progression Button
              _buildActionButton(liveOrder, cubit),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStepDot(String title, bool isCompleted, ThemeData theme) {
    return Column(
      children: [
        CircleAvatar(
          radius: 10,
          backgroundColor: isCompleted
              ? theme.colorScheme.primary
              : Colors.grey.shade300,
          child: isCompleted
              ? const Icon(Icons.check, size: 12, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 9,
            fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
            color: isCompleted ? Colors.black87 : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isCompleted, ThemeData theme) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Divider(
          thickness: 2,
          color: isCompleted ? theme.colorScheme.primary : Colors.grey.shade300,
        ),
      ),
    );
  }

  Widget _buildActionButton(DeliveryOrder order, DeliveryCubit cubit) {
    switch (order.status) {
      case DeliveryStatus.assigned:
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => cubit.acceptDelivery(order.id),
            icon: const Icon(Icons.check_circle),
            label: const Text(
              'Accept Delivery Assignment',
              style: TextStyle(fontSize: 16),
            ),
          ),
        );

      case DeliveryStatus.accepted:
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => cubit.confirmPickup(order.id),
            icon: const Icon(Icons.takeout_dining),
            label: const Text(
              'Confirm Pickup from Kitchen',
              style: TextStyle(fontSize: 16),
            ),
          ),
        );

      case DeliveryStatus.pickedUp:
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () => cubit.startDelivery(order.id),
            icon: const Icon(Icons.two_wheeler),
            label: const Text(
              'Start Delivery Route (On The Way)',
              style: TextStyle(fontSize: 16),
            ),
          ),
        );

      case DeliveryStatus.onTheWay:
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => cubit.completeDelivery(order.id),
            icon: const Icon(Icons.done_all),
            label: const Text(
              'Mark Delivered to Customer',
              style: TextStyle(fontSize: 16),
            ),
          ),
        );

      case DeliveryStatus.delivered:
        return Card(
          color: Colors.green.shade50,
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Order Successfully Delivered!',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );

      case DeliveryStatus.cancelled:
        return const SizedBox.shrink();
    }
  }
}
