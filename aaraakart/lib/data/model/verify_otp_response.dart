// To parse this JSON data, do
//
//     final verifyOtpResponse = verifyOtpResponseFromJson(jsonString);

import 'dart:convert';

VerifyOtpResponse verifyOtpResponseFromJson(String str) =>
    VerifyOtpResponse.fromJson(json.decode(str));

String verifyOtpResponseToJson(VerifyOtpResponse data) =>
    json.encode(data.toJson());

class VerifyOtpResponse {
  bool? success;
  String? message;
  dynamic userId;
  String? userEmail;
  String? userName;
  String? phone;
  bool? isAlreadyRegistered;

  VerifyOtpResponse(
      {this.success,
      this.message,
      this.userId,
      this.userEmail,
      this.phone,
      this.userName,
      this.isAlreadyRegistered});

  VerifyOtpResponse copyWith({
    bool? success,
    String? message,
    dynamic userId,
    String? userEmail,
    String? phone,
    bool? isAlreadyRegistered,
    String? userName,
  }) =>
      VerifyOtpResponse(
        success: success ?? this.success,
        message: message ?? this.message,
        userId: userId ?? this.userId,
        userEmail: userEmail ?? this.userEmail,
        phone: phone ?? this.phone,
        isAlreadyRegistered: isAlreadyRegistered ?? this.isAlreadyRegistered,
        userName: userName ?? this.userName,
      );

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) =>
      VerifyOtpResponse(
        success: json["success"],
        message: json["message"],
        userId: json["user_id"],
        userEmail: json["user_email"],
        phone: json["phone"],
        isAlreadyRegistered: json["is_already_registered"],
        userName: json["user_name"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "user_id": userId,
        "user_email": userEmail,
        "phone": phone,
        "is_already_registered": isAlreadyRegistered,
        'user_name': userName,
      };
}


