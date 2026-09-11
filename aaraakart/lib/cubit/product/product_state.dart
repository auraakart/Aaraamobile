import 'package:aaraa_kart/data/model/cart_item.dart';
import 'package:aaraa_kart/data/model/product_list_response.dart';

abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {
  final bool isLoading;
  ProductLoading({this.isLoading = true});
}

class ProductSuccess extends ProductState {
  final List<Product> products;
  final String currentPage;
  final String totalPage;
  final List<DeliverySlot>? deliverySlots;
  final DeliverySchedule? deliverySchedule;

  ProductSuccess({
    required this.products,
    required this.currentPage,
    required this.totalPage,
    this.deliverySlots,
    this.deliverySchedule,
  });
}

class ProductError extends ProductState {
  final String message;

  ProductError(this.message);
}

class GetProductDetailsLoading extends ProductState {
  // final bool isLoading;
  GetProductDetailsLoading();
}

class GetProductDetailsSuccess extends ProductState {
  final Product? productDetails;
  final List<DeliverySlot>? deliverySlots;
  final DeliverySchedule? deliverySchedule;

  GetProductDetailsSuccess({
    required this.productDetails,
    this.deliverySlots,
    this.deliverySchedule,
  });
}

class GetProductDetailsError extends ProductState {
  final String message;

  GetProductDetailsError(this.message);
}

class ProductFavState extends ProductState {
  List<CartItem> items = [];

  ProductFavState({required this.items});

  ProductFavState copyWith({List<CartItem>? items}) {
    return ProductFavState(items: items ?? List.from(this.items));
  }
}


