// To parse this JSON data, do
//
//     final getWalletTransactionsResponseModel = getWalletTransactionsResponseModelFromJson(jsonString);

import 'dart:convert';

List<GetWalletTransactionsResponseModel>
    getWalletTransactionsResponseModelFromJson(String str) =>
        List<GetWalletTransactionsResponseModel>.from(json
            .decode(str)
            .map((x) => GetWalletTransactionsResponseModel.fromJson(x)));

String getWalletTransactionsResponseModelToJson(
        List<GetWalletTransactionsResponseModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetWalletTransactionsResponseModel {
  String? id;
  String? userId;
  String? amount;
  String? currency;
  String? transactionType;
  String? transactionType1;
  String? paymentMethod;
  String? transactionId;
  String? note;
  DateTime? date;

  GetWalletTransactionsResponseModel({
    this.id,
    this.userId,
    this.amount,
    this.currency,
    this.transactionType,
    this.transactionType1,
    this.paymentMethod,
    this.transactionId,
    this.note,
    this.date,
  });

  GetWalletTransactionsResponseModel copyWith({
    String? id,
    String? userId,
    String? amount,
    String? currency,
    String? transactionType,
    String? transactionType1,
    String? paymentMethod,
    String? transactionId,
    String? note,
    DateTime? date,
  }) =>
      GetWalletTransactionsResponseModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        amount: amount ?? this.amount,
        currency: currency ?? this.currency,
        transactionType: transactionType ?? this.transactionType,
        transactionType1: transactionType1 ?? this.transactionType1,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        transactionId: transactionId ?? this.transactionId,
        note: note ?? this.note,
        date: date ?? this.date,
      );

  factory GetWalletTransactionsResponseModel.fromJson(
          Map<String, dynamic> json) =>
      GetWalletTransactionsResponseModel(
        id: json["id"],
        userId: json["user_id"],
        amount: json["amount"],
        currency: json["currency"],
        transactionType: json["transaction_type"],
        transactionType1: json["transaction_type_1"],
        paymentMethod: json["payment_method"],
        transactionId: json["transaction_id"],
        note: json["note"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "amount": amount,
        "currency": currency,
        "transaction_type": transactionType,
        "transaction_type_1": transactionType1,
        "payment_method": paymentMethod,
        "transaction_id": transactionId,
        "note": note,
        "date": date?.toIso8601String(),
      };
}


