import '../../domain/entities/restaurant.dart';

class RestaurantModel extends Restaurant {
  const RestaurantModel({
    required super.id,
    required super.name,
    required super.cuisine,
    required super.rating,
    required super.deliveryTime,
    required super.image,
  });

  factory RestaurantModel.fromMap(Map<String, dynamic> map) {
    final id = map['id'];
    final name = map['name'];
    final cuisine = map['cuisine'];
    final rating = map['rating'];
    final deliveryTime = map['deliveryTime'];
    final image = map['image'];

    if (id is! String ||
        name is! String ||
        cuisine is! String ||
        rating is! num ||
        deliveryTime is! num ||
        image is! String) {
      throw const FormatException('Invalid restaurant data');
    }

    return RestaurantModel(
      id: id,
      name: name,
      cuisine: cuisine,
      rating: rating.toDouble(),
      deliveryTime: deliveryTime.toInt(),
      image: image,
    );
  }

  factory RestaurantModel.fromJson(Map<String, dynamic> json) =>
      RestaurantModel.fromMap(json);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cuisine': cuisine,
      'rating': rating,
      'deliveryTime': deliveryTime,
      'image': image,
    };
  }

  Map<String, dynamic> toJson() => toMap();
}
