class Order {
  int? id;
  int user_id;
  int restaurant_id;
  String?order_date;
  int total_price;
  String status;

  Order({
    this.id,
    required this.user_id,
    required this.restaurant_id,
    this.order_date,
    required this.total_price,
    required this.status,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      user_id: json['user_id'],
      restaurant_id: json['restaurant_id'],
      order_date: json['order_date'] ?? "not set",
      total_price: json['total_price'],
      status: json['status'],
    );
  }

  String toRawJson() {
    return '{"user_id": $user_id, "restaurant_id": $restaurant_id, "total_price": $total_price, "status": "$status"}';
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': user_id,
      'restaurant_id': restaurant_id,
      'total_price': total_price,
      'status': status,
    };
  }
}