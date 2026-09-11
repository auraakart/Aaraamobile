class ScheduledDeliveryItem {
  final String id;
  final String? subscriptionId;
  final String productName;
  final String? productImage;
  final int quantity;
  final double price;
  final String? deliverySlot;
  final String status; // 'Scheduled', 'Paused', 'One-time Delivery'
  final bool isOneTime;
  final DateTime deliveryDate;
  final DateTime? orderDate;

  const ScheduledDeliveryItem({
    required this.id,
    this.subscriptionId,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.price,
    this.deliverySlot,
    required this.status,
    this.isOneTime = false,
    required this.deliveryDate,
    this.orderDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subscription_id': subscriptionId,
      'product_name': productName,
      'product_image': productImage,
      'quantity': quantity,
      'price': price,
      'delivery_slot': deliverySlot,
      'status': status,
      'is_one_time': isOneTime,
      'delivery_date': deliveryDate.toIso8601String(),
      'order_date': orderDate?.toIso8601String(),
    };
  }

  factory ScheduledDeliveryItem.fromJson(Map<String, dynamic> json) {
    return ScheduledDeliveryItem(
      id: json['id']?.toString() ?? '',
      subscriptionId: json['subscription_id']?.toString(),
      productName: json['product_name']?.toString() ?? 'Delivery Item',
      productImage: json['product_image']?.toString(),
      quantity: json['quantity'] is int
          ? json['quantity']
          : int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      price: json['price'] is num
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      deliverySlot: json['delivery_slot']?.toString(),
      status: json['status']?.toString() ?? 'Scheduled',
      isOneTime: json['is_one_time'] == true,
      deliveryDate: json['delivery_date'] != null
          ? DateTime.tryParse(json['delivery_date'].toString()) ??
              DateTime.now()
          : DateTime.now(),
      orderDate: json['order_date'] != null
          ? DateTime.tryParse(json['order_date'].toString())
          : null,
    );
  }
}
