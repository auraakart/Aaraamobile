// To parse this JSON data, do
//
//     final subscriptionProductDetailModel = subscriptionProductDetailModelFromJson(jsonString);

import 'dart:convert';

List<SubscriptionProductDetailModel> subscriptionProductDetailModelFromJson(
        String str) =>
    List<SubscriptionProductDetailModel>.from(json
        .decode(str)
        .map((x) => SubscriptionProductDetailModel.fromJson(x)));

String subscriptionProductDetailModelToJson(
        List<SubscriptionProductDetailModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SubscriptionProductDetailModel {
  String? subscriptionPeriodInterval;
  String? subscriptionPeriod;
  String? subscriptionLength;
  String? subscriptionPaymentSyncDateMonth;
  String? subscriptionPaymentSyncDateDay;
  String? subscriptionPricingMethod;
  String? subscriptionRegularPrice;
  String? subscriptionSalePrice;
  String? subscriptionDiscount;
  String? position;
  String? subscriptionPrice;
  String? advanceWalletAmount;
  int? subscriptionPaymentSyncDate;

  SubscriptionProductDetailModel(
      {this.subscriptionPeriodInterval,
      this.subscriptionPeriod,
      this.subscriptionLength,
      this.subscriptionPaymentSyncDateMonth,
      this.subscriptionPaymentSyncDateDay,
      this.subscriptionPricingMethod,
      this.subscriptionRegularPrice,
      this.subscriptionSalePrice,
      this.subscriptionDiscount,
      this.position,
      this.subscriptionPrice,
      this.subscriptionPaymentSyncDate,
      this.advanceWalletAmount});

  SubscriptionProductDetailModel copyWith({
    String? subscriptionPeriodInterval,
    String? subscriptionPeriod,
    String? subscriptionLength,
    String? subscriptionPaymentSyncDateMonth,
    String? subscriptionPaymentSyncDateDay,
    String? subscriptionPricingMethod,
    String? subscriptionRegularPrice,
    String? subscriptionSalePrice,
    String? subscriptionDiscount,
    String? position,
    String? subscriptionPrice,
    String? advanceWalletAmount,
    int? subscriptionPaymentSyncDate,
  }) =>
      SubscriptionProductDetailModel(
        subscriptionPeriodInterval:
            subscriptionPeriodInterval ?? this.subscriptionPeriodInterval,
        subscriptionPeriod: subscriptionPeriod ?? this.subscriptionPeriod,
        subscriptionLength: subscriptionLength ?? this.subscriptionLength,
        subscriptionPaymentSyncDateMonth: subscriptionPaymentSyncDateMonth ??
            this.subscriptionPaymentSyncDateMonth,
        subscriptionPaymentSyncDateDay: subscriptionPaymentSyncDateDay ??
            this.subscriptionPaymentSyncDateDay,
        subscriptionPricingMethod:
            subscriptionPricingMethod ?? this.subscriptionPricingMethod,
        subscriptionRegularPrice:
            subscriptionRegularPrice ?? this.subscriptionRegularPrice,
        subscriptionSalePrice:
            subscriptionSalePrice ?? this.subscriptionSalePrice,
        subscriptionDiscount: subscriptionDiscount ?? this.subscriptionDiscount,
        position: position ?? this.position,
        subscriptionPrice: subscriptionPrice ?? this.subscriptionPrice,
        advanceWalletAmount: advanceWalletAmount ?? this.advanceWalletAmount,
        subscriptionPaymentSyncDate:
            subscriptionPaymentSyncDate ?? this.subscriptionPaymentSyncDate,
      );

  factory SubscriptionProductDetailModel.fromJson(Map<String, dynamic> json) =>
      SubscriptionProductDetailModel(
        subscriptionPeriodInterval: json["subscription_period_interval"],
        subscriptionPeriod: json["subscription_period"],
        subscriptionLength: json["subscription_length"],
        subscriptionPaymentSyncDateMonth:
            json["subscription_payment_sync_date_month"],
        subscriptionPaymentSyncDateDay:
            json["subscription_payment_sync_date_day"],
        subscriptionPricingMethod: json["subscription_pricing_method"],
        subscriptionRegularPrice: json["subscription_regular_price"],
        subscriptionSalePrice: json["subscription_sale_price"],
        subscriptionDiscount: json["subscription_discount"],
        position: json["position"],
        advanceWalletAmount: json["advance_wallet_amount"],
        subscriptionPrice: json["subscription_price"],
        subscriptionPaymentSyncDate: json["subscription_payment_sync_date"],
      );

  Map<String, dynamic> toJson() => {
        "subscription_period_interval": subscriptionPeriodInterval,
        "subscription_period": subscriptionPeriod,
        "subscription_length": subscriptionLength,
        "subscription_payment_sync_date_month":
            subscriptionPaymentSyncDateMonth,
        "subscription_payment_sync_date_day": subscriptionPaymentSyncDateDay,
        "subscription_pricing_method": subscriptionPricingMethod,
        "subscription_regular_price": subscriptionRegularPrice,
        "subscription_sale_price": subscriptionSalePrice,
        "subscription_discount": subscriptionDiscount,
        "position": position,
        "subscription_price": subscriptionPrice,
        "subscription_payment_sync_date": subscriptionPaymentSyncDate,
        "advance_wallet_amount": advanceWalletAmount,
      };
}


