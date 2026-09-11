// To parse this JSON data, do
//
//     final orderCreateRequest = orderCreateRequestFromJson(jsonString);

import 'dart:convert';

OrderCreateRequest orderCreateRequestFromJson(String str) =>
    OrderCreateRequest.fromJson(json.decode(str));

String orderCreateRequestToJson(OrderCreateRequest data) =>
    json.encode(data.toJson());

class OrderCreateRequest {
  String? paymentMethod;
  String? paymentMethodTitle;
  bool? setPaid;
  int? customerID;
  Billing? billing;
  List<LineItem>? lineItems;
  List<Map<String, dynamic>>? metaData;
  String? dateCreated;
  String? dateCreatedGmt;

  OrderCreateRequest({
    this.paymentMethod,
    this.paymentMethodTitle,
    this.setPaid,
    this.billing,
    this.lineItems,
    this.customerID,
    this.metaData,
    this.dateCreated,
    this.dateCreatedGmt,
  });

  OrderCreateRequest copyWith({
    String? paymentMethod,
    String? paymentMethodTitle,
    bool? setPaid,
    int? customerID,
    Billing? billing,
    List<LineItem>? lineItems,
    List<Map<String, dynamic>>? metaData,
    String? dateCreated,
    String? dateCreatedGmt,
  }) =>
      OrderCreateRequest(
        paymentMethod: paymentMethod ?? this.paymentMethod,
        paymentMethodTitle: paymentMethodTitle ?? this.paymentMethodTitle,
        setPaid: setPaid ?? this.setPaid,
        customerID: customerID ?? this.customerID,
        billing: billing ?? this.billing,
        lineItems: lineItems ?? this.lineItems,
        metaData: metaData ?? this.metaData,
        dateCreated: dateCreated ?? this.dateCreated,
        dateCreatedGmt: dateCreatedGmt ?? this.dateCreatedGmt,
      );

  factory OrderCreateRequest.fromJson(Map<String, dynamic> json) =>
      OrderCreateRequest(
        paymentMethod: json["payment_method"],
        paymentMethodTitle: json["payment_method_title"],
        setPaid: json["set_paid"],
        customerID: json["customer_id"],
        billing:
            json["billing"] == null ? null : Billing.fromJson(json["billing"]),
        lineItems: json["line_items"] == null
            ? []
            : List<LineItem>.from(
                json["line_items"]!.map((x) => LineItem.fromJson(x))),
        metaData: json["meta_data"] == null
            ? []
            : List<Map<String, dynamic>>.from(json["meta_data"]!),
        dateCreated: json["date_created"],
        dateCreatedGmt: json["date_created_gmt"],
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (paymentMethod != null) data["payment_method"] = paymentMethod;
    if (paymentMethodTitle != null) {
      data["payment_method_title"] = paymentMethodTitle;
    }
    if (setPaid != null) data["set_paid"] = setPaid;
    if (customerID != null) data["customer_id"] = customerID;
    if (billing != null) data["billing"] = billing?.toJson();
    if (lineItems != null && lineItems!.isNotEmpty) {
      data["line_items"] = lineItems!.map((x) => x.toJson()).toList();
    }
    if (metaData != null && metaData!.isNotEmpty) {
      data["meta_data"] = metaData;
    }
    if (dateCreated != null) data["date_created"] = dateCreated;
    if (dateCreatedGmt != null) data["date_created_gmt"] = dateCreatedGmt;
    return data;
  }
}

class Billing {
  String? firstName;
  String? lastName;
  String? address1;
  String? address2;
  String? landmark;
  String? customerNote;
  String? city;
  String? state;
  String? postcode;
  String? country;
  String? email;
  String? phone;

  Billing({
    this.firstName,
    this.lastName,
    this.address1,
    this.address2,
    this.landmark,
    this.customerNote,
    this.city,
    this.state,
    this.postcode,
    this.country,
    this.email,
    this.phone,
  });

  Billing copyWith({
    String? firstName,
    String? lastName,
    String? address1,
    String? address2,
    String? landmark,
    String? customerNote,
    String? city,
    String? state,
    String? postcode,
    String? country,
    String? email,
    String? phone,
  }) =>
      Billing(
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        address1: address1 ?? this.address1,
        address2: address2 ?? this.address2,
        landmark: landmark ?? this.landmark,
        customerNote: customerNote ?? this.customerNote,
        city: city ?? this.city,
        state: state ?? this.state,
        postcode: postcode ?? this.postcode,
        country: country ?? this.country,
        email: email ?? this.email,
        phone: phone ?? this.phone,
      );

  factory Billing.fromJson(Map<String, dynamic> json) => Billing(
        firstName: json["first_name"],
        lastName: json["last_name"],
        address1: json["address_1"],
        address2: json["address_2"],
        landmark: json["landmark"],
        customerNote: json["customer_note"],
        city: json["city"],
        state: json["state"],
        postcode: json["postcode"],
        country: json["country"],
        email: json["email"],
        phone: json["phone"],
      );

  Map<String, dynamic> toJson() => {
        "first_name": firstName,
        "last_name": lastName,
        "address_1": address1,
        "address_2": address2,
        "landmark": landmark,
        "customer_note": customerNote,
        "city": city,
        "state": state,
        "postcode": postcode,
        "country": country,
        "email": email,
        "phone": phone,
      };
}

class LineItem {
  int? productId;
  int? quantity;
  String? variationId;

  LineItem({
    this.productId,
    this.quantity,
    this.variationId,
  });

  LineItem copyWith({
    int? productId,
    int? quantity,
    String? variationId,
  }) =>
      LineItem(
        productId: productId ?? this.productId,
        quantity: quantity ?? this.quantity,
        variationId: variationId ?? this.variationId,
      );

  factory LineItem.fromJson(Map<String, dynamic> json) => LineItem(
        productId: json["product_id"],
        quantity: json["quantity"],
        variationId: json["variation_id"],
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (productId != null) data["product_id"] = productId;
    if (quantity != null) data["quantity"] = quantity;
    if (variationId != null &&
        variationId!.isNotEmpty &&
        int.tryParse(variationId!) != null &&
        int.parse(variationId!) > 0) {
      data["variation_id"] = int.parse(variationId!);
    }
    return data;
  }
}


