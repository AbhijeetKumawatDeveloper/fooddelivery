import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/delivery_address.dart';
import '../../domain/repositories/checkout_repository.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  final SharedPreferences? prefs;
  static const String _addressesKey = 'saved_delivery_addresses';
  static const String _selectedAddressKey = 'selected_delivery_address_id';

  final List<DeliveryAddress> _addresses = [
    const DeliveryAddress(
      id: 'addr_1',
      label: 'Home',
      fullAddress: 'Flat 402, Lotus Palms, Indiranagar',
      city: 'Bengaluru',
      pincode: '560038',
      phone: '+91 98765 43210',
      isDefault: true,
    ),
    const DeliveryAddress(
      id: 'addr_2',
      label: 'Work',
      fullAddress: 'Tower B, 5th Floor, Cyber Heights, Outer Ring Rd',
      city: 'Bengaluru',
      pincode: '560103',
      phone: '+91 98765 43210',
      isDefault: false,
    ),
  ];

  String? _selectedAddressId = 'addr_1';

  CheckoutRepositoryImpl([this.prefs]) {
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    if (prefs == null) return;
    final jsonStr = prefs!.getString(_addressesKey);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
        _addresses.clear();
        _addresses.addAll(
          list.map(
            (item) => DeliveryAddress.fromMap(item as Map<String, dynamic>),
          ),
        );
      } catch (_) {}
    }

    final selectedId = prefs!.getString(_selectedAddressKey);
    if (selectedId != null && selectedId.isNotEmpty) {
      _selectedAddressId = selectedId;
    }
  }

  Future<void> _saveToPrefs() async {
    if (prefs == null) return;
    final list = _addresses.map((a) => a.toMap()).toList();
    await prefs!.setString(_addressesKey, jsonEncode(list));
    if (_selectedAddressId != null) {
      await prefs!.setString(_selectedAddressKey, _selectedAddressId!);
    }
  }

  @override
  List<DeliveryAddress> getAddresses() => List.unmodifiable(_addresses);

  @override
  DeliveryAddress? getSelectedAddress() {
    if (_addresses.isEmpty) return null;
    return _addresses.firstWhere(
      (a) => a.id == _selectedAddressId,
      orElse: () => _addresses.first,
    );
  }

  @override
  Future<void> saveAddress(DeliveryAddress address) async {
    final index = _addresses.indexWhere((a) => a.id == address.id);
    if (index >= 0) {
      _addresses[index] = address;
    } else {
      _addresses.add(address);
    }
    if (address.isDefault || _addresses.length == 1) {
      _selectedAddressId = address.id;
    }
    await _saveToPrefs();
  }

  @override
  Future<void> deleteAddress(String id) async {
    _addresses.removeWhere((a) => a.id == id);
    if (_selectedAddressId == id) {
      _selectedAddressId = _addresses.isNotEmpty ? _addresses.first.id : null;
    }
    await _saveToPrefs();
  }

  @override
  Future<void> setSelectedAddress(String id) async {
    _selectedAddressId = id;
    await _saveToPrefs();
  }
}
