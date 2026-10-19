import '../../domain/entities/order_item.dart';

class OrderItemModel extends OrderItem {
  const OrderItemModel({
    required super.foodId,
    required super.name,
    required super.price,
    required super.quantity,
    super.image = '',
  });

  factory OrderItemModel.fromEntity(OrderItem entity) {
    return OrderItemModel(
      foodId: entity.foodId,
      name: entity.name,
      price: entity.price,
      quantity: entity.quantity,
      image: entity.image,
    );
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      foodId: (map['foodId'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      image: (map['image'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'foodId': foodId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'image': image,
    };
  }
}
