import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fooddelivery/entity/order.dart';
import 'package:fooddelivery/entity/orderItem.dart';
import 'package:fooddelivery/util/constant.dart';

class Orderclient {
  static const baseUrl = baseIp;

  //want to create

  static Future<Order> createOrder(Order order, String token) async {
    const String endpointOrder = 'api/order';
    try {
      final response = await http.post(
        Uri.http(baseUrl, endpointOrder),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: order.toRawJson(),
      ).timeout(const Duration(seconds: 20), onTimeout: () {
        return http.Response('Error', 408);
      });

      if (response.statusCode == 201) {
        // Assuming that 'data' contains the order object in the response
        return Order.fromJson(jsonDecode(response.body)['data']);
      } else {
        print('Error ${response.statusCode}: ${response.body}');
        return Future.error('Error creating order');
      }
    } catch (e) {
      print('Exception: $e');
      return Future.error('Error creating order: $e');
    }
  }
  static Future<OrderItem> createItem(OrderItem item, String token) async{
    const String endpoint = 'api/orderItem';

    try{
      final response = await http.post(
        Uri.http(baseUrl, endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: item.toRawJson(),
      ).timeout(const Duration(seconds: 20), onTimeout: () {
        return http.Response('Error', 408);
      });
      if (response.statusCode == 201) {
        return OrderItem.fromJson(jsonDecode(response.body)['data']);
      } else {
        print('Error ${response.statusCode}: ${response.body}');
        return Future.error('Error creating order');
      }
    }catch (e) {
      print('Exception: $e');
      return Future.error('Error creating order item: $e');
    }
  }

  static Future<List<Order>> fetchOrderByUserId(String token, String userId) async {
    const String endpoint = 'api/order/show';
    try {
      final response = await http.post(
        Uri.http(baseUrl, endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'user_id': userId}),
      ).timeout(const Duration(seconds: 20), onTimeout: () {
        return http.Response('Error', 408);
      });

      if (response.statusCode == 200) {
        List<Order> orders = [];
        var data = jsonDecode(response.body)['data'];
        print('Response Data: $data');
        for (var i in data) {
          orders.add(Order.fromJson(i));
        }
        return orders;
      } else {
        print('Error ${response.statusCode}: ${response.body}');
        return Future.error('Error fetching order');
      }
    } catch (e) {
      print('Exception: $e');
      return Future.error('Error fetching order: $e');
    }

  }
  static Future<void> updateOrderStatus(String token, String id, String status) async{
    const String endpoint = 'api/order/update';
    try{
      final response = await http.put(
        Uri.http(baseUrl, endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'id': id, 'status': status}),
      );

      if(response.statusCode == 200){
        var data = jsonDecode(response.body)['message'];
        return data;
      }else{
        return Future.error('Error updating order status: ${response.statusCode}');
      }
    }catch(e){
      return Future.error('Error updating order status: $e');
    }
  }

  static Future<List<OrderItem>> fetchOrderItem(String token, String orderId) async {
    const String endpoint = 'api/orderItem/show';
    try {
      final response = await http.post(
        Uri.http(baseUrl, endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'order_id': orderId}),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body)['data'];
        print('Response Data: $data');
        List<OrderItem> orderItems = [];
        for (var i in data) {
          if(i['menu'] == null){
            print("Menu is null");
          }
          if(i['order'] == null){
            print("Order is null");
          }
          orderItems.add(OrderItem.fromJson(i));
        }
        for(var i in orderItems){
          print("OrderItem: ${i.item_id}");
        }
        return orderItems;
      } else {
        return Future.error('Error fetching order items: ${response.statusCode}');
      }
    } catch (e) {
      return Future.error('Error fetching order items: $e');
    }
  }
  static Future<String> deleteOrder(String token, String id) async{
    const String endpoint = 'api/order/delete';
    try{
      final response = await http.delete(Uri.http(baseUrl, endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'id': id}),
      );

      if(response.statusCode == 200){
        var data = jsonDecode(response.body)['message'];
        return data;
      }else{
        return Future.error('Error deleting order: ${response.statusCode}');
      }
    }catch(e){
      return Future.error('Error deleting order: $e');
    }
  }
}