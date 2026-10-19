import '../entities/delivery_address.dart';

abstract interface class CheckoutRepository {
  List<DeliveryAddress> getAddresses();
  Future<void> saveAddress(DeliveryAddress address);
  Future<void> deleteAddress(String id);
  DeliveryAddress? getSelectedAddress();
  Future<void> setSelectedAddress(String id);
}
