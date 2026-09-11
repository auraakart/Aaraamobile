import 'package:aaraa_kart/core/network/api_constants.dart';
import 'package:aaraa_kart/cubit/order/order_state.dart';
import 'package:aaraa_kart/data/model/order_create_request.dart';
import 'package:aaraa_kart/data/model/update_order_request.dart';
import 'package:aaraa_kart/domain/order_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderCubit extends Cubit<OrderState> {
  final OrderRepository _repository;

  OrderCubit(this._repository) : super(OrderInitial());

  void createOrder(OrderCreateRequest request) async {
    if (state is OrderCreateLoading) return;
    emit(OrderCreateLoading(isLoading: true));

    try {
      final result = await _repository.createOrder(request);

      emit(OrderCreateSuccess(
        orderResponse: result.products,
      ));
    } catch (e) {
      emit(OrderCreateError(e.toString()));
    }
  }

  void updateOrder(UpdateOrderReqest request, String orderID) async {
    if (state is OrderUpdateLoading) return;
    emit(OrderUpdateLoading(isLoading: true));

    try {
      final result = await _repository.updateOrder(orderID, request);

      emit(OrderUpdateSuccess(
        orderResponse: result,
      ));
    } catch (e) {
      emit(OrderUpdateError(e.toString()));
    }
  }

  Future<void> getOrderList(String customerID, int pageNumber,
      DateTime fromDate, DateTime toDate) async {
    if (state is GetOrderListLoading) return;
    emit(GetOrderListLoading(isLoading: true));

    try {
      final result = await _repository.getCustomerOrderList(
          customerID, pageNumber, fromDate, toDate);

      emit(GetOrderListSuccess(
        orderListResponse: result.products ?? [],
        currentPage: result.currentPage ?? 1,
        totalPage: result.totalPages ?? 1,
      ));
    } catch (e) {
      emit(GetOrderListError(e.toString()));
    }
  }

  void getOrderNoteList(
    String orderID, {
    String resource = ApiConstants.CreateOrder,
  }) async {
    if (state is OrderNoteLoading) return;
    emit(OrderNoteLoading(isLoading: true));

    try {
      final result =
          await _repository.getOrderNoteList(orderID, resource: resource);

      emit(OrderNoteSuccess(
        orderNoteResponse: result.products ?? [],
      ));
    } catch (e) {
      emit(OrderNoteError(e.toString()));
    }
  }

  void createOrderNote(
    String orderID,
    String msg, {
    String resource = ApiConstants.CreateOrder,
  }) async {
    if (state is CreateOrderNoteLoading) return;
    emit(CreateOrderNoteLoading(isLoading: true));

    try {
      final result =
          await _repository.createOrderNote(orderID, msg, resource: resource);

      emit(CreateOrderNoteSuccess(
        orderNoteResponse: result,
      ));
    } catch (e) {
      emit(CreateOrderNoteError(e.toString()));
    }
  }

  void reset() => emit(OrderInitial());
}


