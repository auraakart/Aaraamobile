import 'dart:convert';

CreateSubscriptionRequestModel createSubscriptionRequestModelFromJson(
        String str) =>
    CreateSubscriptionRequestModel.fromJson(json.decode(str));

String createSubscriptionRequestModelToJson(
        CreateSubscriptionRequestModel data) =>
    json.encode(data.toJson());

class CreateSubscriptionRequestModel {
  int? customerId;
  List<int>? productIds;
  String? status;
  DateTime? startDate;
  DateTime? nextPaymentDate;
  String? paymentMethod;
  String? paymentMethodTitle;
  int? billingInterval;
  String? billingPeriod;
  int? deliverySlot;
  String? deliverySchedule;
  List<int>? deliveryDays;
  SubBilling? billing;

  CreateSubscriptionRequestModel(
      {this.customerId,
      this.productIds,
      this.status,
      this.startDate,
      this.nextPaymentDate,
      this.paymentMethod,
      this.billing,
      this.paymentMethodTitle,
      this.billingInterval,
      this.billingPeriod,
      this.deliverySlot,
      this.deliverySchedule,
      this.deliveryDays});

  CreateSubscriptionRequestModel copyWith(
          {int? customerId,
          List<int>? productIds,
          String? status,
          DateTime? startDate,
          DateTime? nextPaymentDate,
          String? paymentMethod,
          String? paymentMethodTitle,
          SubBilling? billing,
          int? billingInterval,
          String? billingPeriod,
          int? deliverySlot,
          String? deliverySchedule,
          List<int>? deliveryDays}) =>
      CreateSubscriptionRequestModel(
        customerId: customerId ?? this.customerId,
        productIds: productIds ?? this.productIds,
        status: status ?? this.status,
        startDate: startDate ?? this.startDate,
        nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        paymentMethodTitle: paymentMethodTitle ?? this.paymentMethodTitle,
        billing: billing ?? this.billing,
        billingInterval: billingInterval ?? this.billingInterval,
        billingPeriod: billingPeriod ?? this.billingPeriod,
        deliverySlot: deliverySlot ?? this.deliverySlot,
        deliverySchedule: deliverySchedule ?? this.deliverySchedule,
        deliveryDays: deliveryDays ?? this.deliveryDays,
      );

  factory CreateSubscriptionRequestModel.fromJson(Map<String, dynamic> json) =>
      CreateSubscriptionRequestModel(
        customerId: json["customer_id"],
        productIds: json["product_ids"] == null
            ? []
            : List<int>.from(json["product_ids"]!.map((x) => x)),
        status: json["status"],
        startDate: json["start_date"] == null
            ? null
            : DateTime.parse(json["start_date"]),
        nextPaymentDate: json["next_payment_date"] == null
            ? null
            : DateTime.parse(json["next_payment_date"]),
        paymentMethod: json["payment_method"],
        paymentMethodTitle: json["payment_method_title"],
        billing: json["billing"] == null
            ? null
            : SubBilling.fromJson(json["billing"]),
        billingInterval: json["billing_interval"],
        billingPeriod: json["billing_period"],
        deliverySlot: json["delivery_slot"],
        deliverySchedule: json["delivery_schedule"],
        deliveryDays: json["delivery_days"] == null
            ? null
            : List<int>.from(json["delivery_days"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "customer_id": customerId,
        "product_ids": productIds == null
            ? []
            : List<dynamic>.from(productIds!.map((x) => x)),
        "status": status,
        "start_date": startDate?.toUtc().toIso8601String(),
        // "next_payment_date": nextPaymentDate?.toUtc().toIso8601String(),
        "payment_method": paymentMethod,
        "payment_method_title": paymentMethodTitle,
        "billing": billing?.toJson(),
        "billing_interval": billingInterval,
        "billing_period": billingPeriod,
        "delivery_slot": deliverySlot,
        "delivery_schedule": deliverySchedule,
        if (deliveryDays != null && deliveryDays!.isNotEmpty)
          "delivery_days": deliveryDays,
      };
}

class SubBilling {
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

  SubBilling({
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

  SubBilling copyWith({
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
      SubBilling(
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

  factory SubBilling.fromJson(Map<String, dynamic> json) => SubBilling(
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


