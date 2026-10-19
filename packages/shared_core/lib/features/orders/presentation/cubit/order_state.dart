import 'package:equatable/equatable.dart';

import '../../domain/entities/app_order.dart';

sealed class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {
  const OrderInitial();
}

class OrderLoading extends OrderState {
  const OrderLoading();
}

class OrderCreated extends OrderState {
  final AppOrder order;

  const OrderCreated(this.order);

  @override
  List<Object?> get props => [order];
}

class OrdersLoaded extends OrderState {
  final List<AppOrder> orders;

  const OrdersLoaded(this.orders);

  bool get isEmpty => orders.isEmpty;

  @override
  List<Object?> get props => [orders];
}

class OrderFailure extends OrderState {
  final String message;

  const OrderFailure(this.message);

  @override
  List<Object?> get props => [message];
}
