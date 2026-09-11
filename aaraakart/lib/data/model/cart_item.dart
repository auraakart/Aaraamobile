class CartItem {
  final String id;
  int quantity;
  final String name;
  final String price;
  final String imageUrl;
  final bool isOutOfStock;
  final String? deliveryDate;
  final String? deliverySlot;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
    this.isOutOfStock = false,
    this.deliveryDate,
    this.deliverySlot,
  });

  /// Unique key to identify an item instance in the cart taking into account scheduled delivery date
  String get cartKey => deliveryDate != null && deliveryDate!.isNotEmpty
      ? '${id}_$deliveryDate'
      : id;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'quantity': quantity,
        'imageUrl': imageUrl,
        'isOutOfStock': isOutOfStock,
        'deliveryDate': deliveryDate,
        'deliverySlot': deliverySlot,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json['id'],
        name: json['name'],
        price: json['price'],
        quantity: json['quantity'],
        imageUrl: json['imageUrl'],
        isOutOfStock: json['isOutOfStock'] as bool? ?? false,
        deliveryDate: json['deliveryDate'] as String?,
        deliverySlot: json['deliverySlot'] as String?,
      );

  CartItem copyWith({
    String? id,
    String? name,
    String? price,
    int? quantity,
    String? imageUrl,
    bool? isOutOfStock,
    String? deliveryDate,
    String? deliverySlot,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      isOutOfStock: isOutOfStock ?? this.isOutOfStock,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      deliverySlot: deliverySlot ?? this.deliverySlot,
    );
  }
}


