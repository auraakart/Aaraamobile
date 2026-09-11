import 'package:aaraa_kart/data/model/cart_item.dart';

class CartState {
  final List<CartItem> items;

  CartState({required this.items});

  CartState copyWith({List<CartItem>? items}) {
    return CartState(items: items ?? List.from(this.items));
  }

  int get totalQuantity {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
}


