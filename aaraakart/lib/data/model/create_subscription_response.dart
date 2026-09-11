import 'dart:convert';

CreateSubscriptionResponseModel createSubscriptionResponseModelFromJson(
        String str) =>
    CreateSubscriptionResponseModel.fromJson(json.decode(str));

String createSubscriptionResponseModelToJson(
        CreateSubscriptionResponseModel data) =>
    json.encode(data.toJson());

class CreateSubscriptionResponseModel {
  int? orderId;
  int? subscriptionId;
  int? deliverySlot;
  String? deliverySchedule;
  List<dynamic>? deliveryDays;

  CreateSubscriptionResponseModel({
    this.orderId,
    this.subscriptionId,
    this.deliverySlot,
    this.deliverySchedule,
    this.deliveryDays,
  });

  factory CreateSubscriptionResponseModel.fromJson(
          Map<String, dynamic> json) =>
      CreateSubscriptionResponseModel(
        orderId: json["order_id"],
        subscriptionId: json["subscription_id"],
        deliverySlot: json["delivery_slot"],
        deliverySchedule: json["delivery_schedule"],
        deliveryDays: json["delivery_days"] == null
            ? []
            : List<dynamic>.from(json["delivery_days"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "order_id": orderId,
        "subscription_id": subscriptionId,
        "delivery_slot": deliverySlot,
        "delivery_schedule": deliverySchedule,
        "delivery_days": deliveryDays == null
            ? []
            : List<dynamic>.from(deliveryDays!.map((x) => x)),
      };
}


