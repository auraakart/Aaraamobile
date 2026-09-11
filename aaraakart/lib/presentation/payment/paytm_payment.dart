import 'package:aaraa_kart/app/router/app_routes.dart';
import 'package:aaraa_kart/data/model/create_subscription_request.dart';
import 'package:aaraa_kart/data/model/create_subscription_response.dart';
import 'package:aaraa_kart/data/model/customer_address.dart';
import 'package:aaraa_kart/data/model/order_create_request.dart';
import 'package:aaraa_kart/data/model/order_create_response.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Hands the transaction to [PaytmWebviewScreen], which runs Paytm's hosted
/// checkout in an in-app webview. The native All-in-One SDK integration was
/// dropped, so the webview is the only Paytm flow.
void startPaytmPayment(
  BuildContext context, {
  OrderCreateRequest? orderRequestDetails,
  OrderCreateProducts? orderResponseDetails,
  CreateSubscriptionRequestModel? subRequestDetails,
  double? subScriptionAmount,
  String? subOrderID,
  CreateSubscriptionResponseModel? subResponseDetails,
  required bool isSubscription,
  required bool isWallet,
  GetAddressResponse? walletRequestDetails,
}) {
  context.pushNamed(AppRoutes.paytmPayment.name, extra: <String, dynamic>{
    "orderRequestDetails": orderRequestDetails,
    "orderResponseDetails": orderResponseDetails,
    "subRequestDetails": subRequestDetails,
    "subScriptionAmount": subScriptionAmount,
    "subOrderID": subOrderID,
    "subResponseDetails": subResponseDetails,
    "isSubscription": isSubscription,
    "isWallet": isWallet,
    "walletRequestDetails": walletRequestDetails,
  });
}


