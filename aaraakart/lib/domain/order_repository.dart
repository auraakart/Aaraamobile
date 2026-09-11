import 'package:dio/dio.dart';
import 'package:aaraa_kart/core/di/injection.dart';
import 'package:aaraa_kart/core/network/api_constants.dart';
import 'package:aaraa_kart/data/model/get_customer_order.dart';
import 'package:aaraa_kart/data/model/order_create_request.dart';
import 'package:aaraa_kart/data/model/order_create_response.dart';
import 'package:aaraa_kart/data/model/order_note_response_model.dart';
import 'package:aaraa_kart/data/model/update_order_request.dart';

class OrderRepository {
  Dio dio = getIt<Dio>(instanceName: 'farmersVillageDio');

  OrderRepository(this.dio);
  Future<OrderCreateResponseModel> createOrder(
      OrderCreateRequest request) async {
    try {
      final response = await dio.post(
        ApiConstants.CreateOrder,
        data: request.toJson(),
      );

      return OrderCreateResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to Create Order: $e');
    }
  }

  Future<OrderNoteResponeModel> getOrderNoteList(
    String orderId, {
    String resource = ApiConstants.CreateOrder,
  }) async {
    try {
      final response = await dio.get(
        '$resource/$orderId/${ApiConstants.GetOrderNotes}',
      );

      return _parseNoteList(response.data);
    } catch (e) {
      throw Exception('Failed to get Order Notes: $e');
    }
  }

  Future<OrderNoteProduct> createOrderNote(
    String orderId,
    String msg, {
    String resource = ApiConstants.CreateOrder,
  }) async {
    try {
      Map<String, dynamic> payload = {
        "note": msg,
        "customer_note": true,
      };
      final response = await dio.post(
        '$resource/$orderId/${ApiConstants.GetOrderNotes}',
        data: payload,
      );

      return OrderNoteProduct.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get Order Notes: $e');
    }
  }

  static OrderNoteResponeModel _parseNoteList(dynamic data) {
    if (data is List) {
      return OrderNoteResponeModel(
        products: data
            .whereType<Map<String, dynamic>>()
            .map(OrderNoteProduct.fromJson)
            .toList(),
        total: data.length,
      );
    }
    return OrderNoteResponeModel.fromJson(data as Map<String, dynamic>);
  }

  Future<OrderCreateResponseModel> updateOrder(
      String orderID, UpdateOrderReqest request) async {
    try {
      final response = await dio.put(
        '${ApiConstants.CreateOrder}/$orderID',
        data: request.toJson(),
      );

      return OrderCreateResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to Update Order: $e');
    }
  }

  static GetCustomerOrdersResponeModel _parseCustomerOrders(dynamic data) {
    if (data is List) {
      return GetCustomerOrdersResponeModel(
        products: data
            .whereType<Map<String, dynamic>>()
            .map(HistoryProduct.fromJson)
            .toList(),
        total: data.length,
      );
    } else if (data is Map<String, dynamic>) {
      return GetCustomerOrdersResponeModel.fromJson(data);
    }
    return GetCustomerOrdersResponeModel(products: []);
  }

  Future<GetCustomerOrdersResponeModel> getCustomerOrderList(String customerID,
      int pageNumber, DateTime fromDate, DateTime toDate) async {
    try {
      Map<String, dynamic> payload = {
        "customer": customerID,
        "per_page": 50,
        "page": pageNumber,
        "after": _dayBoundary(fromDate, endOfDay: false),
        "before": _dayBoundary(toDate, endOfDay: true),
      };

      final response = await dio.get(
        ApiConstants.CreateOrder,
        queryParameters: payload,
      );

      return _parseCustomerOrders(response.data);
    } catch (e) {
      throw Exception('Failed to get order list: $e');
    }
  }

  Future<GetCustomerOrdersResponeModel> getFutureCustomerOrderList(
      String customerID,
      int pageNumber,
      DateTime fromDate,
      DateTime toDate) async {
    try {
      Map<String, dynamic> payload = {
        "customer": customerID,
        "per_page": 50,
        "page": pageNumber,
        "after": _dayBoundary(fromDate, endOfDay: false),
        "before": _dayBoundary(toDate, endOfDay: true),
      };

      final response = await dio.get(
        ApiConstants.FutureOrders,
        queryParameters: payload,
      );

      return _parseCustomerOrders(response.data);
    } catch (e) {
      throw Exception('Failed to get future order list: $e');
    }
  }

  static String _dayBoundary(DateTime date, {required bool endOfDay}) {
    final bound = endOfDay
        ? DateTime(date.year, date.month, date.day, 23, 59, 59)
        : DateTime(date.year, date.month, date.day);
    return bound.toIso8601String().split('.').first;
  }
}


