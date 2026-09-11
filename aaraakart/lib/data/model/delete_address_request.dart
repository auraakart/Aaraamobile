// To parse this JSON data, do
//
//     final deleteAddressRequest = deleteAddressRequestFromJson(jsonString);

import 'dart:convert';

DeleteAddressRequest deleteAddressRequestFromJson(String str) =>
    DeleteAddressRequest.fromJson(json.decode(str));

String deleteAddressRequestToJson(DeleteAddressRequest data) =>
    json.encode(data.toJson());

class DeleteAddressRequest {
  String? userId;
  String? addressId;

  DeleteAddressRequest({
    this.userId,
    this.addressId,
  });

  DeleteAddressRequest copyWith({
    String? userId,
    String? addressId,
  }) =>
      DeleteAddressRequest(
        userId: userId ?? this.userId,
        addressId: addressId ?? this.addressId,
      );

  factory DeleteAddressRequest.fromJson(Map<String, dynamic> json) =>
      DeleteAddressRequest(
        userId: json["user_id"],
        addressId: json["address_id"],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "address_id": addressId,
      };
}


