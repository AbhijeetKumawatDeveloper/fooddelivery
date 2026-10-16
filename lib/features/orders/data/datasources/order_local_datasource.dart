import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/app_order.dart';
import '../models/app_order_model.dart';

abstract interface class OrderLocalDataSource {
  Future<AppOrder> saveOrder(AppOrder order);
  Future<List<AppOrder>> getUserOrders(String userId);
  Stream<List<AppOrder>> streamUserOrders(String userId);
  Future<void> clear();
}

class OrderLocalDataSourceImpl implements OrderLocalDataSource {
  final SharedPreferences? prefs;
  static const String _ordersKey = 'saved_user_orders';
  final List<AppOrder> _memoryOrders = [];
  final StreamController<List<AppOrder>> _ordersStreamController =
      StreamController<List<AppOrder>>.broadcast();

  OrderLocalDataSourceImpl({this.prefs}) {
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    if (prefs == null) return;
    final jsonString = prefs!.getString(_ordersKey);
    if (jsonString == null || jsonString.isEmpty) return;

    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      _memoryOrders.clear();
      _memoryOrders.addAll(
        decoded.map(
          (item) => AppOrderModel.fromMap(item as Map<String, dynamic>),
        ),
      );
    } catch (_) {
      // Ignore corrupted cache
    }
  }

  Future<void> _persistToPrefs() async {
    if (prefs == null) return;
    final list = _memoryOrders
        .map((order) => AppOrderModel.fromEntity(order).toMap())
        .toList();
    await prefs!.setString(_ordersKey, jsonEncode(list));
  }

  @override
  Future<AppOrder> saveOrder(AppOrder order) async {
    final newOrder = order.id.isEmpty
        ? order.copyWith(id: 'ord_${DateTime.now().millisecondsSinceEpoch}')
        : order;

    _memoryOrders.insert(0, newOrder);
    await _persistToPrefs();
    _ordersStreamController.add(List.unmodifiable(_memoryOrders));
    return newOrder;
  }

  @override
  Future<List<AppOrder>> getUserOrders(String userId) async {
    final filtered = _memoryOrders
        .where((o) => userId.isEmpty || o.userId == userId)
        .toList();
    return List.unmodifiable(filtered);
  }

  @override
  Stream<List<AppOrder>> streamUserOrders(String userId) {
    // Emit current list first, then listen to subsequent changes
    final initialList = _memoryOrders
        .where((o) => userId.isEmpty || o.userId == userId)
        .toList();

    return Stream.value(initialList).concatWith([
      _ordersStreamController.stream.map(
        (orders) =>
            orders.where((o) => userId.isEmpty || o.userId == userId).toList(),
      ),
    ]);
  }

  @override
  Future<void> clear() async {
    _memoryOrders.clear();
    if (prefs != null) {
      await prefs!.remove(_ordersKey);
    }
    _ordersStreamController.add([]);
  }
}

extension _StreamConcat<T> on Stream<T> {
  Stream<T> concatWith(Iterable<Stream<T>> others) async* {
    yield* this;
    for (final s in others) {
      yield* s;
    }
  }
}
