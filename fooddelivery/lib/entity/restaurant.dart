
import 'package:hive/hive.dart';

part 'restaurant.g.dart';

@HiveType(typeId: 1)
class Restaurant{
  @HiveField(0)
  int id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String address;
  @HiveField(3)
  String phone_number;
  @HiveField(4)
  String description;
  @HiveField(5)
  String logo_url;
  @HiveField(6)
  int rating;
  @HiveField(7)
  String openTime;
  @HiveField(8)
  String closeTime;

  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.phone_number,
    required this.description,
    required this.logo_url,
    required this.rating,
    required this.openTime,
    required this.closeTime,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json){
    return Restaurant(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      phone_number: json['phone_number'],
      description: json['description'],
      logo_url: json['logo_url'],
      rating: json['rating']?? 0,
      openTime: json['open_time'],
      closeTime: json['close_time'],
    );
  }

  String toRawJson(){
    return '{"name": "$name", "address": "$address", "phone_number": "$phone_number", "description": "$description", "logo_url": "$logo_url", "rating": "$rating", "open_time": "$openTime", "close_time": "$closeTime"}';
  }

  Map<String, dynamic> toJson(){
    return {
      'name': name,
      'address': address,
      'phone_number': phone_number,
      'description': description,
      'logo_url': logo_url,
      'rating': rating,
      'open_time': openTime,
      'close_time': closeTime,
    };
  }
}