import 'package:fooddelivery/entity/restaurant.dart';
import 'package:hive/hive.dart';

part 'menu.g.dart';

@HiveType(typeId: 0)
class Menu {
  @HiveField(0)
  int item_id;
  @HiveField(1)
  int restaurant_id;
  @HiveField(2)
  String name;
  @HiveField(3)
  int price;
  @HiveField(4)
  int? totalPrice;
  @HiveField(5)
  int? totalCount;
  @HiveField(6)
  String type;
  @HiveField(7)
  String description;
  @HiveField(8)
  String image_url;
  @HiveField(9)
  Restaurant restaurant;

  Menu({required this.item_id,required this.restaurant_id, required this.name, required this.price, required this.type,required this.description, required this.image_url, required this.restaurant, this.totalPrice, this.totalCount});

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      item_id: json['item_id'],
      restaurant_id: json['restaurant_id'],
      name: json['name'],
      price: json['price'],
      type: json['type'],
      description: json['description'],
      image_url: json['image_url'],
      restaurant: Restaurant.fromJson(json['restaurant']),
    );
  }

  String toRawJson() {
    return '{"item_id": "$item_id" ,"restaurant_id": "$restaurant_id", "name": "$name", "price": "$price", "type": "$type","description": "$description", "image": "$image_url"}';
  }
  Map<String, dynamic> toJson() {
    return {
      'item_id': item_id,
      'restaurant_id': restaurant_id,
      'name': name,
      'price': price,
      'type': type,
      'description': description,
      'image': image_url,
    };
  }
}