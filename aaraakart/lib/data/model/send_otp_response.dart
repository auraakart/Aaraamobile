// To parse this JSON data, do
//
//     final sendOtpResponse = sendOtpResponseFromJson(jsonString);

import 'dart:convert';

SendOtpResponse sendOtpResponseFromJson(String str) =>
    SendOtpResponse.fromJson(json.decode(str));

String sendOtpResponseToJson(SendOtpResponse data) =>
    json.encode(data.toJson());

class SendOtpResponse {
  bool? success;
  String? message;
  String? phone;

  SendOtpResponse({
    this.success,
    this.message,
    this.phone,
  });

  SendOtpResponse copyWith({
    bool? success,
    String? message,
    String? phone,
  }) =>
      SendOtpResponse(
        success: success ?? this.success,
        message: message ?? this.message,
        phone: phone ?? this.phone,
      );

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) =>
      SendOtpResponse(
        success: json["success"],
        message: json["message"],
        phone: json["phone"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "phone": phone,
      };
}


