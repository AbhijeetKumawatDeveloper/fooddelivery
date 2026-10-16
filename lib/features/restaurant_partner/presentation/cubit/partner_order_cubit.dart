import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/restaurant_order.dart';
import '../../domain/repositories/partner_order_repository.dart';
import '../../domain/usecases/update_order_status.dart';
import '../../domain/usecases/watch_partner_orders.dart';
import 'partner_order_state.dart';

class PartnerOrderCubit extends Cubit<PartnerOrderState> {
  final WatchPartnerOrders watchPartnerOrders;
  final UpdateOrderStatus updateOrderStatus;
  final PartnerOrderRepository repository;

  StreamSubscription<List<RestaurantOrder>>? _ordersSubscription;

  PartnerOrderCubit({
    required this.watchPartnerOrders,
    required this.updateOrderStatus,
    required this.repository,
  }) : super(const PartnerOrderState());

  void listenToOrders(String restaurantId) {
    _ordersSubscription?.cancel();
    emit(
      state.copyWith(
        isLoading: true,
        restaurantId: restaurantId,
        clearError: true,
      ),
    );

    _ordersSubscription = watchPartnerOrders(restaurantId).listen(
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
              errorMessage: 'Failed to load restaurant orders: $e',
            ),
          );
        }
      },
    );
  }

  Future<void> loadOrders(String restaurantId) async {
    emit(
      state.copyWith(
        isLoading: true,
        restaurantId: restaurantId,
        clearError: true,
      ),
    );
    try {
      final orders = await repository.getOrders(restaurantId);
      emit(state.copyWith(orders: orders, isLoading: false, clearError: true));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> updateStatus(
    String orderId,
    RestaurantOrderStatus status,
  ) async {
    try {
      await updateOrderStatus(orderId: orderId, status: status);
      // Optimistic update for responsive partner UI
      final updatedOrders = state.orders.map((o) {
        if (o.id == orderId) {
          return o.copyWith(status: status);
        }
        return o;
      }).toList();
      emit(state.copyWith(orders: updatedOrders, clearError: true));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to update order status: $e'));
    }
  }

  Future<void> acceptOrder(String orderId) =>
      updateStatus(orderId, RestaurantOrderStatus.accepted);

  Future<void> rejectOrder(String orderId) =>
      updateStatus(orderId, RestaurantOrderStatus.rejected);

  Future<void> startPreparing(String orderId) =>
      updateStatus(orderId, RestaurantOrderStatus.preparing);

  Future<void> markReadyForPickup(String orderId) =>
      updateStatus(orderId, RestaurantOrderStatus.readyForPickup);

  Future<void> markPickedUp(String orderId) =>
      updateStatus(orderId, RestaurantOrderStatus.pickedUp);

  Future<void> markDelivered(String orderId) =>
      updateStatus(orderId, RestaurantOrderStatus.delivered);

  Future<void> cancelOrder(String orderId) =>
      updateStatus(orderId, RestaurantOrderStatus.cancelled);

  @override
  Future<void> close() async {
    await _ordersSubscription?.cancel();
    return super.close();
  }
}
