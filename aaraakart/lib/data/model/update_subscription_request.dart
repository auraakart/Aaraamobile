// To parse this JSON data, do
//
//     final updateSubscriptionRequest = updateSubscriptionRequestFromJson(jsonString);

import 'dart:convert';

UpdateSubscriptionRequest updateSubscriptionRequestFromJson(String str) =>
    UpdateSubscriptionRequest.fromJson(json.decode(str));

String updateSubscriptionRequestToJson(UpdateSubscriptionRequest data) =>
    json.encode(data.toJson());

class UpdateSubscriptionRequest {
  String? status;
  List<SubMetaDatum>? metaData;

  UpdateSubscriptionRequest({
    this.status,
    this.metaData,
  });

  UpdateSubscriptionRequest copyWith({
    String? status,
    List<SubMetaDatum>? metaData,
  }) =>
      UpdateSubscriptionRequest(
        status: status ?? this.status,
        metaData: metaData ?? this.metaData,
      );

  factory UpdateSubscriptionRequest.fromJson(Map<String, dynamic> json) =>
      UpdateSubscriptionRequest(
        status: json["status"],
        metaData: json["meta_data"] == null
            ? []
            : List<SubMetaDatum>.from(
                json["meta_data"]!.map((x) => SubMetaDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    if (status != null) {
      map['status'] = status;
    }

    if (metaData != null && metaData!.isNotEmpty) {
      map['meta_data'] = metaData!.map((x) => x.toJson()).toList();
    }

    return map;
  }
}

class SubMetaDatum {
  String? key;
  String? value;

  SubMetaDatum({
    this.key,
    this.value,
  });

  SubMetaDatum copyWith({
    String? key,
    String? value,
  }) =>
      SubMetaDatum(
        key: key ?? this.key,
        value: value ?? this.value,
      );

  factory SubMetaDatum.fromJson(Map<String, dynamic> json) => SubMetaDatum(
        key: json["key"],
        value: json["value"],
      );

  Map<String, dynamic> toJson() => {
        "key": key,
        "value": value,
      };
}


