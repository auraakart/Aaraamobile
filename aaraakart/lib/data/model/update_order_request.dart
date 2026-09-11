// To parse this JSON data, do
//
//     final updateOrderReqest = updateOrderReqestFromJson(jsonString);

import 'dart:convert';

UpdateOrderReqest updateOrderReqestFromJson(String str) =>
    UpdateOrderReqest.fromJson(json.decode(str));

String updateOrderReqestToJson(UpdateOrderReqest data) =>
    json.encode(data.toJson());

class UpdateOrderReqest {
  String? status;

  UpdateOrderReqest({
    this.status,
  });

  UpdateOrderReqest copyWith({
    String? status,
  }) =>
      UpdateOrderReqest(
        status: status ?? this.status,
      );

  factory UpdateOrderReqest.fromJson(Map<String, dynamic> json) =>
      UpdateOrderReqest(
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
      };
}


