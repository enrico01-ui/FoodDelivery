import 'package:fooddelivery/entity/order.dart';
import 'package:fooddelivery/entity/menu.dart';

class OrderItem{
  int order_id;
  int item_id;
  int quantity;
  int price;

  Menu? menus;
  Order? orders;

  OrderItem({
    required this.order_id,
    required this.item_id,
    required this.quantity,
    required this.price,
    this.menus,
    this.orders,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json){
    return OrderItem(
      order_id: json['order_id'],
      item_id: json['item_id'],
      quantity: json['quantity'],
      price: json['price'],
      menus: json['menu'] != null ? Menu.fromJson(json['menu']) : null,
      orders: json['order'] != null ? Order.fromJson(json['order']) : null,
    );
  }

  String toRawJson(){
    return '{"order_id": $order_id, "item_id": $item_id, "quantity": $quantity, "price": $price}';
  }

  Map<String, dynamic> toJson(){
    return {
      'order_id': order_id,
      'item_id': item_id,
      'quantity': quantity,
      'price': price,
    };
  }
}