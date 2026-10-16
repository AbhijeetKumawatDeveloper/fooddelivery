import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/delivery_order.dart';
import '../../domain/repositories/delivery_repository.dart';
import '../../domain/usecases/update_delivery_location.dart';
import '../../domain/usecases/update_delivery_status.dart';
import '../../domain/usecases/watch_assigned_orders.dart';
import 'delivery_state.dart';

class DeliveryCubit extends Cubit<DeliveryState> {
  final WatchAssignedOrders watchAssignedOrders;
  final UpdateDeliveryStatus updateDeliveryStatus;
  final UpdateDeliveryLocation updateDeliveryLocation;
  final DeliveryRepository repository;

  StreamSubscription<List<DeliveryOrder>>? _subscription;

  DeliveryCubit({
    required this.watchAssignedOrders,
    required this.updateDeliveryStatus,
    required this.updateDeliveryLocation,
    required this.repository,
  }) : super(const DeliveryState());

  void listenToAssignedOrders(String partnerId) {
    _subscription?.cancel();
    emit(
      state.copyWith(isLoading: true, partnerId: partnerId, clearError: true),
    );

    _subscription = watchAssignedOrders(partnerId).listen(
      (orders) {
        if (!isClosed) {
          emit(
            state.copyWith(orders: orders, isLoading: false, clearError: true),
          );
        }
      },
      onError: (e) {
        if (!isClosed) {
          emit(
            state.copyWith(
              isLoading: false,
              errorMessage: 'Failed to load delivery orders: $e',
            ),
          );
        }
      },
    );
  }

  Future<void> loadAssignedOrders(String partnerId) async {
    emit(
      state.copyWith(isLoading: true, partnerId: partnerId, clearError: true),
    );
    try {
      final orders = await repository.getAssignedOrders(partnerId);
      emit(state.copyWith(orders: orders, isLoading: false, clearError: true));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> updateStatus(String orderId, DeliveryStatus status) async {
    try {
      await updateDeliveryStatus(orderId: orderId, status: status);
      final updated = state.orders.map((o) {
        if (o.id == orderId) {
          return o.copyWith(status: status);
        }
        return o;
      }).toList();
      emit(state.copyWith(orders: updated, clearError: true));
    } catch (e) {
      emit(
        state.copyWith(errorMessage: 'Failed to update delivery status: $e'),
      );
    }
  }

  Future<void> acceptDelivery(String orderId) =>
      updateStatus(orderId, DeliveryStatus.accepted);

  Future<void> confirmPickup(String orderId) =>
      updateStatus(orderId, DeliveryStatus.pickedUp);

  Future<void> startDelivery(String orderId) =>
      updateStatus(orderId, DeliveryStatus.onTheWay);

  Future<void> completeDelivery(String orderId) =>
      updateStatus(orderId, DeliveryStatus.delivered);

  Future<void> cancelDelivery(String orderId) =>
      updateStatus(orderId, DeliveryStatus.cancelled);

  Future<void> broadcastLocation(
    String orderId,
    double latitude,
    double longitude,
  ) async {
    try {
      await updateDeliveryLocation(
        orderId: orderId,
        latitude: latitude,
        longitude: longitude,
      );
      final updated = state.orders.map((o) {
        if (o.id == orderId) {
          return o.copyWith(
            latitude: latitude,
            longitude: longitude,
            updatedAt: DateTime.now(),
          );
        }
        return o;
      }).toList();
      emit(state.copyWith(orders: updated));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Location broadcast error: $e'));
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
