import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_order.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/usecases/create_order.dart';
import '../../domain/usecases/get_user_orders.dart';
import '../../domain/usecases/stream_user_orders.dart';
import 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final CreateOrder createOrderUseCase;
  final GetUserOrders getUserOrdersUseCase;
  final StreamUserOrders streamUserOrdersUseCase;

  StreamSubscription<List<AppOrder>>? _ordersSubscription;

  OrderCubit({
    required this.createOrderUseCase,
    required this.getUserOrdersUseCase,
    required this.streamUserOrdersUseCase,
  }) : super(const OrderInitial());

  Future<AppOrder?> placeOrder({
    required String userId,
    required String restaurantId,
    required String restaurantName,
    required List<OrderItem> items,
    required double subtotal,
    required double deliveryFee,
    required double totalAmount,
    required String deliveryAddress,
    String paymentMethod = 'Cash on Delivery',
  }) async {
    if (items.isEmpty) {
      emit(const OrderFailure('Cannot place an empty order.'));
      return null;
    }

    if (deliveryAddress.trim().isEmpty) {
      emit(const OrderFailure('Please provide a valid delivery address.'));
      return null;
    }

    emit(const OrderLoading());

    try {
      final order = await createOrderUseCase(
        userId: userId,
        restaurantId: restaurantId,
        restaurantName: restaurantName,
        items: items,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        totalAmount: totalAmount,
        deliveryAddress: deliveryAddress.trim(),
        paymentMethod: paymentMethod,
      );

      emit(OrderCreated(order));
      return order;
    } catch (e) {
      emit(OrderFailure('Failed to place order: ${e.toString()}'));
      return null;
    }
  }

  Future<void> loadUserOrders(String userId) async {
    emit(const OrderLoading());
    try {
      final orders = await getUserOrdersUseCase(userId);
      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(OrderFailure('Failed to load orders: ${e.toString()}'));
    }
  }

  void listenToUserOrders(String userId) {
    _ordersSubscription?.cancel();
    emit(const OrderLoading());

    _ordersSubscription = streamUserOrdersUseCase(userId).listen(
      (orders) {
        if (!isClosed) {
          emit(OrdersLoaded(orders));
        }
      },
      onError: (error) {
        if (!isClosed) {
          emit(OrderFailure('Error tracking orders: $error'));
        }
      },
    );
  }

  @override
  Future<void> close() async {
    await _ordersSubscription?.cancel();
    return super.close();
  }
}
