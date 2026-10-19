import '../../domain/entities/food.dart';

class FoodModel extends Food {
  const FoodModel({
    required super.id,
    required super.restaurantId,
    required super.name,
    required super.description,
    required super.price,
    required super.image,
    required super.category,
    super.isAvailable,
  });

  factory FoodModel.fromMap(Map<String, dynamic> map) {
    final id = map['id'];
    final restaurantId = map['restaurantId'];
    final name = map['name'];
    final description = map['description'] ?? '';
    final price = map['price'];
    final image = map['image'] ?? '';
    final category = map['category'] ?? '';
    final isAvailable = map['isAvailable'] ?? true;

    if (id is! String ||
        restaurantId is! String ||
        name is! String ||
        price is! num) {
      throw const FormatException('Invalid food item data');
    }

    return FoodModel(
      id: id,
      restaurantId: restaurantId,
      name: name,
      description: description is String ? description : '',
      price: price.toDouble(),
      image: image is String ? image : '',
      category: category is String ? category : '',
      isAvailable: isAvailable is bool ? isAvailable : true,
    );
  }

  factory FoodModel.fromJson(Map<String, dynamic> json) =>
      FoodModel.fromMap(json);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'category': category,
      'isAvailable': isAvailable,
    };
  }

  Map<String, dynamic> toJson() => toMap();
}
