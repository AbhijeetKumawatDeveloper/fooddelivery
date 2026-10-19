import 'package:equatable/equatable.dart';

class DeliveryAddress extends Equatable {
  final String id;
  final String label; // Home, Work, Other
  final String fullAddress;
  final String city;
  final String pincode;
  final String phone;
  final bool isDefault;

  const DeliveryAddress({
    required this.id,
    required this.label,
    required this.fullAddress,
    required this.city,
    required this.pincode,
    required this.phone,
    this.isDefault = false,
  });

  DeliveryAddress copyWith({
    String? id,
    String? label,
    String? fullAddress,
    String? city,
    String? pincode,
    String? phone,
    bool? isDefault,
  }) {
    return DeliveryAddress(
      id: id ?? this.id,
      label: label ?? this.label,
      fullAddress: fullAddress ?? this.fullAddress,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      phone: phone ?? this.phone,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'fullAddress': fullAddress,
      'city': city,
      'pincode': pincode,
      'phone': phone,
      'isDefault': isDefault,
    };
  }

  factory DeliveryAddress.fromMap(Map<String, dynamic> map) {
    return DeliveryAddress(
      id: (map['id'] ?? '').toString(),
      label: (map['label'] ?? 'Home').toString(),
      fullAddress: (map['fullAddress'] ?? '').toString(),
      city: (map['city'] ?? '').toString(),
      pincode: (map['pincode'] ?? '').toString(),
      phone: (map['phone'] ?? '').toString(),
      isDefault: map['isDefault'] == true,
    );
  }

  @override
  List<Object?> get props => [
    id,
    label,
    fullAddress,
    city,
    pincode,
    phone,
    isDefault,
  ];
}
