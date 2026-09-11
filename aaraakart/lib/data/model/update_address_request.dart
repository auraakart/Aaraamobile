// To parse this JSON data, do
//
//     final updateAddressRequest = updateAddressRequestFromJson(jsonString);

import 'dart:convert';

UpdateAddressRequest updateAddressRequestFromJson(String str) =>
    UpdateAddressRequest.fromJson(json.decode(str));

String updateAddressRequestToJson(UpdateAddressRequest data) =>
    json.encode(data.toJson());

class UpdateAddressRequest {
  String? customerId;
  String? addressId;
  String? addressBillingName;
  bool? isDefault;

  UpdateAddressRequest({
    this.customerId,
    this.addressId,
    this.addressBillingName,
    this.isDefault,
  });

  UpdateAddressRequest copyWith({
    String? customerId,
    String? addressId,
    String? addressBillingName,
    bool? isDefault,
  }) =>
      UpdateAddressRequest(
        customerId: customerId ?? this.customerId,
        addressId: addressId ?? this.addressId,
        addressBillingName: addressBillingName ?? this.addressBillingName,
        isDefault: isDefault ?? this.isDefault,
      );

  factory UpdateAddressRequest.fromJson(Map<String, dynamic> json) =>
      UpdateAddressRequest(
        customerId: json["customer_id"],
        addressId: json["address_id"],
        addressBillingName: json["address_billingName"],
        isDefault: json["is_default"],
      );

  Map<String, dynamic> toJson() => {
        "customer_id": customerId,
        "address_id": addressId,
        "address_billingName": addressBillingName,
        "is_default": isDefault,
      };
}


