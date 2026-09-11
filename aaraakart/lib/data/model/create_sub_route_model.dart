import 'dart:convert';

import 'package:aaraa_kart/data/model/product_list_response.dart';

CreateSubRouteModel createSubRouteModelFromJson(String str) =>
    CreateSubRouteModel.fromJson(json.decode(str));

String createSubRouteModelToJson(CreateSubRouteModel data) =>
    json.encode(data.toJson());

class CreateSubRouteModel {
  String? productName;
  String? price;
  String? image;
  String? productID;
  int? advanceAmount;
  List<GetSubscriptionResponse>? subscriptionPlans;

  CreateSubRouteModel(
      {this.productName,
      this.price,
      this.image,
      this.productID,
      this.advanceAmount,
      this.subscriptionPlans});

  CreateSubRouteModel copyWith({
    String? productName,
    String? price,
    String? image,
    String? productID,
    int? advanceAmount,
    List<GetSubscriptionResponse>? subscriptionPlans,
  }) =>
      CreateSubRouteModel(
        productName: productName ?? this.productName,
        price: price ?? this.price,
        image: image ?? this.image,
        productID: productID ?? this.productID,
        advanceAmount: advanceAmount ?? this.advanceAmount,
        subscriptionPlans: subscriptionPlans ?? this.subscriptionPlans,
      );

  factory CreateSubRouteModel.fromJson(Map<String, dynamic> json) =>
      CreateSubRouteModel(
        productName: json["productName"],
        price: json["price"],
        image: json["image"],
        productID: json["productID"],
        advanceAmount: json["advanceAmount"],
        subscriptionPlans: List<GetSubscriptionResponse>.from(
            json["subscriptionPlans"]
                .map((x) => GetSubscriptionResponse.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "productName": productName,
        "price": price,
        "image": image,
        "productID": productID,
        "advanceAmount": advanceAmount,
        "subscriptionPlans": subscriptionPlans,
      };
}


