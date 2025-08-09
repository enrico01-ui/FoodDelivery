
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fooddelivery/entity/restaurant.dart';
import 'package:fooddelivery/util/constant.dart';

class Restaurantclient {
  static const String baseUrl = baseIp;

  static Future<List<Restaurant>> getRestaurant(String token) async{
    const String endpoint = 'api/restaurant';
    try {
      final response = await http.get(
        Uri.https(baseUrl, endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 20), onTimeout: () {
        return http.Response('Error', 408);
      });

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((json) => Restaurant.fromJson(json)).toList();
      } else {
        print('Error ${response.statusCode}: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Exception: $e');
      return Future.error('Error fetching restaurants: $e');
    }

  }

  
}