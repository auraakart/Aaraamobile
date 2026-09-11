
import 'dart:convert';

OrderSuccessRouteModel orderSuccessRouteModelFromJson(String str) => OrderSuccessRouteModel.fromJson(json.decode(str));

String orderSuccessRouteModelToJson(OrderSuccessRouteModel data) => json.encode(data.toJson());

class OrderSuccessRouteModel {
    String? totalAmount;
    String? orderId;
    String? paymentMethod;
    String? orderDate;
    String? deliveryInfo;
    String? subscriptionId;
    int? deliverySlot;
    String? deliverySchedule;
    List<dynamic>? deliveryDays;

    OrderSuccessRouteModel({
        this.totalAmount,
        this.orderId,
        this.paymentMethod,
        this.orderDate,
        this.deliveryInfo,
        this.subscriptionId,
        this.deliverySlot,
        this.deliverySchedule,
        this.deliveryDays,
    });

    OrderSuccessRouteModel copyWith({
        String? totalAmount,
        String? orderId,
        String? paymentMethod,
        String? orderDate,
        String? deliveryInfo,
        String? subscriptionId,
        int? deliverySlot,
        String? deliverySchedule,
        List<dynamic>? deliveryDays,
    }) =>
        OrderSuccessRouteModel(
            totalAmount: totalAmount ?? this.totalAmount,
            orderId: orderId ?? this.orderId,
            paymentMethod: paymentMethod ?? this.paymentMethod,
            orderDate: orderDate ?? this.orderDate,
            deliveryInfo: deliveryInfo ?? this.deliveryInfo,
            subscriptionId: subscriptionId ?? this.subscriptionId,
            deliverySlot: deliverySlot ?? this.deliverySlot,
            deliverySchedule: deliverySchedule ?? this.deliverySchedule,
            deliveryDays: deliveryDays ?? this.deliveryDays,
        );

    factory OrderSuccessRouteModel.fromJson(Map<String, dynamic> json) => OrderSuccessRouteModel(
        totalAmount: json["totalAmount"],
        orderId: json["orderID"],
        paymentMethod: json["paymentMethod"],
        orderDate: json["orderDate"],
        deliveryInfo: json["deliveryInfo"],
        subscriptionId: json["subscriptionId"],
        deliverySlot: json["deliverySlot"],
        deliverySchedule: json["deliverySchedule"],
        deliveryDays: json["deliveryDays"] == null ? [] : List<dynamic>.from(json["deliveryDays"]!.map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "totalAmount": totalAmount,
        "orderID": orderId,
        "paymentMethod": paymentMethod,
        "orderDate": orderDate,
        "deliveryInfo": deliveryInfo,
        "subscriptionId": subscriptionId,
        "deliverySlot": deliverySlot,
        "deliverySchedule": deliverySchedule,
        "deliveryDays": deliveryDays == null ? [] : List<dynamic>.from(deliveryDays!.map((x) => x)),
    };
}


