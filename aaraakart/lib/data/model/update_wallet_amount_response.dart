// To parse this JSON data, do
//
//     final updateWalletAmountResponseModel = updateWalletAmountResponseModelFromJson(jsonString);

import 'dart:convert';

UpdateWalletAmountResponseModel updateWalletAmountResponseModelFromJson(
        String str) =>
    UpdateWalletAmountResponseModel.fromJson(json.decode(str));

String updateWalletAmountResponseModelToJson(
        UpdateWalletAmountResponseModel data) =>
    json.encode(data.toJson());

class UpdateWalletAmountResponseModel {
  String? response;
  String? balance;
  int? transactionId;

  UpdateWalletAmountResponseModel({
    this.response,
    this.balance,
    this.transactionId,
  });

  UpdateWalletAmountResponseModel copyWith({
    String? response,
    String? balance,
    int? transactionId,
  }) =>
      UpdateWalletAmountResponseModel(
        response: response ?? this.response,
        balance: balance ?? this.balance,
        transactionId: transactionId ?? this.transactionId,
      );

  factory UpdateWalletAmountResponseModel.fromJson(Map<String, dynamic> json) =>
      UpdateWalletAmountResponseModel(
        response: json["response"],
        balance: json["balance"],
        transactionId: json["transaction_id"],
      );

  Map<String, dynamic> toJson() => {
        "response": response,
        "balance": balance,
        "transaction_id": transactionId,
      };
}


