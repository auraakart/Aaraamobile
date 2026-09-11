import 'package:aaraa_kart/data/model/get_customer_order.dart';
import 'package:aaraa_kart/data/model/order_create_response.dart';
import 'package:aaraa_kart/data/model/order_note_response_model.dart';

abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderCreateLoading extends OrderState {
  final bool isLoading;
  OrderCreateLoading({this.isLoading = true});
}

class OrderCreateSuccess extends OrderState {
  final OrderCreateProducts? orderResponse;

  OrderCreateSuccess({
    required this.orderResponse,
  });
}

class OrderCreateError extends OrderState {
  final String message;

  OrderCreateError(this.message);
}

class OrderUpdateLoading extends OrderState {
  final bool isLoading;
  OrderUpdateLoading({this.isLoading = true});
}

class OrderUpdateSuccess extends OrderState {
  final OrderCreateResponseModel? orderResponse;

  OrderUpdateSuccess({
    required this.orderResponse,
  });
}

class OrderUpdateError extends OrderState {
  final String message;

  OrderUpdateError(this.message);
}

class GetOrderListLoading extends OrderState {
  final bool isLoading;
  GetOrderListLoading({this.isLoading = true});
}

class GetOrderListSuccess extends OrderState {
  final List<HistoryProduct>? orderListResponse;
  final int currentPage;
  final int totalPage;

  GetOrderListSuccess({
    required this.orderListResponse,
    required this.currentPage,
    required this.totalPage,
  });
}

class GetOrderListError extends OrderState {
  final String message;

  GetOrderListError(this.message);
}

class OrderNoteLoading extends OrderState {
  final bool isLoading;
  OrderNoteLoading({this.isLoading = true});
}

class OrderNoteSuccess extends OrderState {
  final List<OrderNoteProduct>? orderNoteResponse;

  OrderNoteSuccess({
    required this.orderNoteResponse,
  });
}

class OrderNoteError extends OrderState {
  final String message;

  OrderNoteError(this.message);
}

class CreateOrderNoteLoading extends OrderState {
  final bool isLoading;
  CreateOrderNoteLoading({this.isLoading = true});
}

class CreateOrderNoteSuccess extends OrderState {
  final OrderNoteProduct? orderNoteResponse;

  CreateOrderNoteSuccess({
    required this.orderNoteResponse,
  });
}

class CreateOrderNoteError extends OrderState {
  final String message;

  CreateOrderNoteError(this.message);
}


