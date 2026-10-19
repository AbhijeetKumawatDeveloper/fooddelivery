import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/cart_item.dart';
import '../models/cart_item_model.dart';

abstract interface class CartLocalDataSource {
  List<CartItem> getCartItems();
  Future<void> saveCartItems(List<CartItem> items);
  Future<void> clear();
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  final SharedPreferences? prefs;
  static const String _cartKey = 'saved_cart_items';
  final List<CartItem> _memoryFallback = [];

  CartLocalDataSourceImpl({this.prefs});

  @override
  List<CartItem> getCartItems() {
    if (prefs == null) {
      return List.unmodifiable(_memoryFallback);
    }

    final jsonString = prefs!.getString(_cartKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded
          .map((item) => CartItemModel.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveCartItems(List<CartItem> items) async {
    if (prefs == null) {
      _memoryFallback
        ..clear()
        ..addAll(items);
      return;
    }

    final list = items.map((e) => CartItemModel.fromEntity(e).toMap()).toList();
    await prefs!.setString(_cartKey, jsonEncode(list));
  }

  @override
  Future<void> clear() async {
    if (prefs == null) {
      _memoryFallback.clear();
      return;
    }

    await prefs!.remove(_cartKey);
  }
}
