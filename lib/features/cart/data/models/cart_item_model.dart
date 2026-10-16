import '../../domain/entities/cart_item.dart';

class CartItemModel extends CartItem {
  const CartItemModel({
    required super.foodId,
    required super.restaurantId,
    required super.name,
    required super.price,
    super.quantity = 1,
    super.image = '',
  });

  factory CartItemModel.fromEntity(CartItem entity) {
    return CartItemModel(
      foodId: entity.foodId,
      restaurantId: entity.restaurantId,
      name: entity.name,
      price: entity.price,
      quantity: entity.quantity,
      image: entity.image,
    );
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      foodId: (map['foodId'] ?? map['id'] ?? '').toString(),
      restaurantId: (map['restaurantId'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      image: (map['image'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'foodId': foodId,
      'restaurantId': restaurantId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'image': image,
    };
  }
}
