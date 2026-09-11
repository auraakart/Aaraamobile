// To parse this JSON data, do
//
//     final getCustomerSubscriptionsResponseModel = getCustomerSubscriptionsResponseModelFromJson(jsonString);

import 'dart:convert';

List<GetCustomerSubscriptionsResponseModel>
    getCustomerSubscriptionsResponseModelFromJson(String str) =>
        List<GetCustomerSubscriptionsResponseModel>.from(json
            .decode(str)
            .map((x) => GetCustomerSubscriptionsResponseModel.fromJson(x)));

String getCustomerSubscriptionsResponseModelToJson(
        List<GetCustomerSubscriptionsResponseModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetCustomerSubscriptionsResponseModel {
  final dynamic id;
  final dynamic parentId;
  final String? status;
  final String? currency;
  final String? version;
  final bool? pricesIncludeTax;
  final String? dateCreated;
  final String? dateModified;
  final String? discountTotal;
  final String? discountTax;
  final String? shippingTotal;
  final String? shippingTax;
  final String? cartTax;
  final String? total;
  final String? totalTax;
  final dynamic customerId;
  final String? orderKey;
  final Ing? billing;
  final Ing? shipping;
  final String? paymentMethod;
  final String? paymentMethodTitle;
  final String? customerIpAddress;
  final String? customerUserAgent;
  final String? createdVia;
  final String? customerNote;
  final dynamic dateCompleted;
  final dynamic datePaid;
  final String? number;
  final DeliverySchedule? deliverySchedule;
  final DeliverySlot? deliverySlot;
  final List<LineItem>? lineItems;
  final List<dynamic>? taxLines;
  final List<dynamic>? shippingLines;
  final List<dynamic>? feeLines;
  final List<dynamic>? couponLines;
  final String? paymentUrl;
  final bool? isEditable;
  final bool? needsPayment;
  final bool? needsProcessing;
  final String? dateCreatedGmt;
  final String? dateModifiedGmt;
  final dynamic dateCompletedGmt;
  final dynamic datePaidGmt;
  final bool? isPaused;
  final List<dynamic>? pauseDates;
  final dynamic resumeDate;
  final String? pauseType;
  final dynamic billingPeriod;
  final dynamic billingInterval;
  final String? trialPeriod;
  final int? suspensionCount;
  final bool? requiresManualRenewal;
  final String? startDateGmt;
  final String? trialEndDateGmt;
  final String? nextPaymentDateGmt;
  final String? lastPaymentDateGmt;
  final String? cancelledDateGmt;
  final String? endDateGmt;
  final String? resubscribedFrom;
  final String? resubscribedSubscription;
  final List<dynamic>? removedLineItems;

  GetCustomerSubscriptionsResponseModel({
    this.id,
    this.parentId,
    this.status,
    this.currency,
    this.version,
    this.pricesIncludeTax,
    this.dateCreated,
    this.dateModified,
    this.discountTotal,
    this.discountTax,
    this.shippingTotal,
    this.shippingTax,
    this.cartTax,
    this.total,
    this.totalTax,
    this.customerId,
    this.orderKey,
    this.billing,
    this.shipping,
    this.paymentMethod,
    this.paymentMethodTitle,
    this.customerIpAddress,
    this.customerUserAgent,
    this.createdVia,
    this.customerNote,
    this.dateCompleted,
    this.datePaid,
    this.number,
    this.lineItems,
    this.taxLines,
    this.shippingLines,
    this.feeLines,
    this.couponLines,
    this.paymentUrl,
    this.isEditable,
    this.needsPayment,
    this.needsProcessing,
    this.dateCreatedGmt,
    this.dateModifiedGmt,
    this.dateCompletedGmt,
    this.datePaidGmt,
    this.isPaused,
    this.pauseDates,
    this.resumeDate,
    this.pauseType,
    this.billingPeriod,
    this.billingInterval,
    this.trialPeriod,
    this.suspensionCount,
    this.requiresManualRenewal,
    this.startDateGmt,
    this.trialEndDateGmt,
    this.nextPaymentDateGmt,
    this.lastPaymentDateGmt,
    this.cancelledDateGmt,
    this.endDateGmt,
    this.resubscribedFrom,
    this.resubscribedSubscription,
    this.removedLineItems,
    this.deliverySchedule,
    this.deliverySlot,
  });

  factory GetCustomerSubscriptionsResponseModel.fromJson(
          Map<String, dynamic> json) {
    final metaList = json["meta_data"] as List<dynamic>?;
    final Map<String, dynamic> metaMap = {};
    if (metaList != null) {
      for (final item in metaList) {
        if (item is Map && item.containsKey("key")) {
          metaMap[item["key"].toString()] = item["value"];
        }
      }
    }

    dynamic getField(String key, [List<String>? altKeys]) {
      if (json[key] != null) return json[key];
      if (metaMap.containsKey(key)) return metaMap[key];
      if (metaMap.containsKey('_$key')) return metaMap['_$key'];
      if (altKeys != null) {
        for (final k in altKeys) {
          if (json[k] != null) return json[k];
          if (metaMap.containsKey(k)) return metaMap[k];
          if (metaMap.containsKey('_$k')) return metaMap['_$k'];
        }
      }
      return null;
    }

    List<dynamic> parsePauseDates() {
      final raw = getField("pause_dates", [
        "subscription_pause_dates",
        "paused_dates",
        "pause_date",
        "_pause_dates",
        "_aaraa_pause_dates",
        "aaraa_pause_dates",
        "_wcfmu_pause_dates",
        "wcfmu_pause_dates",
      ]);
      if (raw == null) return [];
      if (raw is List) {
        return raw
            .where((x) =>
                x != null &&
                x.toString().trim().isNotEmpty &&
                x.toString().trim() != '[]')
            .toList();
      }
      if (raw is String) {
        final trimmed = raw.trim();
        if (trimmed.isEmpty || trimmed == '[]' || trimmed == '""') return [];
        if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
          try {
            final decoded = jsonDecode(trimmed);
            if (decoded is List) {
              return decoded
                  .where((x) =>
                      x != null &&
                      x.toString().trim().isNotEmpty &&
                      x.toString().trim() != '[]')
                  .toList();
            }
          } catch (_) {}
        }
        if (trimmed.contains(',')) {
          return trimmed
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty && s != '[]')
              .toList();
        }
        return [trimmed];
      }
      return [];
    }

    bool? parseIsPaused() {
      final raw = getField(
          "is_paused", ["subscription_is_paused", "paused", "_is_paused"]);
      if (raw == null) return null;
      if (raw is bool) return raw;
      if (raw is num) return raw == 1;
      final str = raw.toString().toLowerCase().trim();
      if (str == 'false' || str == '0' || str == 'no' || str.isEmpty) {
        return false;
      }
      return str == 'true' || str == '1' || str == 'yes';
    }

    dynamic parseResumeDate() {
      final raw = getField(
          "resume_date", ["subscription_resume_date", "resume_at", "_resume_date"]);
      if (raw == null || raw.toString().trim().isEmpty) return null;
      return raw;
    }

    dynamic parseNextPaymentDate() {
      bool isValidDateStr(dynamic v) {
        if (v == null) return false;
        final s = v.toString().trim();
        return s.isNotEmpty &&
            s != '0' &&
            s != '0000-00-00 00:00:00' &&
            s != 'null';
      }

      final candidateKeys = [
        "next_payment_date_gmt",
        "next_payment_date",
        "schedule_next_payment",
        "_schedule_next_payment",
        "_next_payment_date_gmt",
        "_next_payment_date",
      ];

      for (final k in candidateKeys) {
        if (isValidDateStr(json[k])) return json[k].toString().trim();
        if (isValidDateStr(metaMap[k])) return metaMap[k].toString().trim();
        if (isValidDateStr(metaMap['_$k'])) return metaMap['_$k'].toString().trim();
      }
      return null;
    }

    String? parsePauseType() {
      final raw =
          getField("pause_type", ["subscription_pause_type", "_pause_type"]);
      if (raw == null || raw.toString().trim().isEmpty) return null;
      return raw.toString().trim();
    }

    DeliverySchedule? parseDeliverySchedule() {
      dynamic raw = getField(
          "delivery_schedule", ["_delivery_schedule", "schedule"]);
      if (raw == null) return null;
      if (raw is String && raw.trim().startsWith('{')) {
        try {
          raw = jsonDecode(raw);
        } catch (_) {}
      }
      if (raw is Map<String, dynamic>) {
        return DeliverySchedule.fromJson(raw);
      } else if (raw is Map) {
        return DeliverySchedule.fromJson(Map<String, dynamic>.from(raw));
      }
      return null;
    }

    DeliverySlot? parseDeliverySlot() {
      dynamic raw = getField("delivery_slot", ["_delivery_slot", "slot"]);
      if (raw == null) return null;
      if (raw is String && raw.trim().startsWith('{')) {
        try {
          raw = jsonDecode(raw);
        } catch (_) {}
      }
      if (raw is Map<String, dynamic>) {
        return DeliverySlot.fromJson(raw);
      } else if (raw is Map) {
        return DeliverySlot.fromJson(Map<String, dynamic>.from(raw));
      }
      return null;
    }

    final model = GetCustomerSubscriptionsResponseModel(
      id: json["id"],
      parentId: json["parent_id"],
      status: json["status"],
      currency: json["currency"],
      version: json["version"],
      pricesIncludeTax: json["prices_include_tax"],
      dateCreated: json["date_created"],
      dateModified: json["date_modified"],
      discountTotal: json["discount_total"],
      discountTax: json["discount_tax"],
      shippingTotal: json["shipping_total"],
      shippingTax: json["shipping_tax"],
      cartTax: json["cart_tax"],
      total: json["total"],
      totalTax: json["total_tax"],
      customerId: json["customer_id"],
      deliverySchedule: parseDeliverySchedule(),
      deliverySlot: parseDeliverySlot(),
      orderKey: json["order_key"],
      billing: json["billing"] == null ? null : Ing.fromJson(json["billing"]),
      shipping:
          json["shipping"] == null ? null : Ing.fromJson(json["shipping"]),
      paymentMethod: json["payment_method"],
      paymentMethodTitle: json["payment_method_title"],
      customerIpAddress: json["customer_ip_address"],
      customerUserAgent: json["customer_user_agent"],
      createdVia: json["created_via"],
      customerNote: json["customer_note"],
      dateCompleted: json["date_completed"],
      datePaid: json["date_paid"],
      number: json["number"],
      lineItems: (json["line_items"] ?? json["items"]) == null
          ? []
          : List<LineItem>.from(
              (json["line_items"] ?? json["items"])!.map((x) => LineItem.fromJson(x))),
      taxLines: json["tax_lines"] == null
          ? []
          : List<dynamic>.from(json["tax_lines"]!.map((x) => x)),
      shippingLines: json["shipping_lines"] == null
          ? []
          : List<dynamic>.from(json["shipping_lines"]!.map((x) => x)),
      feeLines: json["fee_lines"] == null
          ? []
          : List<dynamic>.from(json["fee_lines"]!.map((x) => x)),
      couponLines: json["coupon_lines"] == null
          ? []
          : List<dynamic>.from(json["coupon_lines"]!.map((x) => x)),
      paymentUrl: json["payment_url"],
      isEditable: json["is_editable"],
      needsPayment: json["needs_payment"],
      needsProcessing: json["needs_processing"],
      dateCreatedGmt: json["date_created_gmt"],
      dateModifiedGmt: json["date_modified_gmt"],
      dateCompletedGmt: json["date_completed_gmt"],
      datePaidGmt: json["date_paid_gmt"],
      isPaused: parseIsPaused(),
      pauseDates: parsePauseDates(),
      resumeDate: parseResumeDate(),
      pauseType: parsePauseType(),
      billingPeriod: json["billing_period"],
      billingInterval: json["billing_interval"],
      trialPeriod: json["trial_period"],
      suspensionCount: json["suspension_count"],
      requiresManualRenewal: json["requires_manual_renewal"],
      startDateGmt: json["start_date_gmt"],
      trialEndDateGmt: json["trial_end_date_gmt"],
      nextPaymentDateGmt: parseNextPaymentDate(),
      lastPaymentDateGmt: json["last_payment_date_gmt"],
      cancelledDateGmt: json["cancelled_date_gmt"],
      endDateGmt: json["end_date_gmt"],
      resubscribedFrom: json["resubscribed_from"],
      resubscribedSubscription: json["resubscribed_subscription"],
      removedLineItems: json["removed_line_items"] == null
          ? []
          : List<dynamic>.from(json["removed_line_items"]!.map((x) => x)),
    );

    // [DEBUG LOG - INVESTIGATION ONLY]
    // ignore: avoid_print
    print('=== [DEBUG MODEL] GetCustomerSubscriptionsResponseModel.fromJson ===');
    // ignore: avoid_print
    print('Model ID: ${model.id}');
    // ignore: avoid_print
    print('Model status: ${model.status}');
    // ignore: avoid_print
    print('Model billingPeriod: ${model.billingPeriod}, billingInterval: ${model.billingInterval}');
    // ignore: avoid_print
    print('Model deliverySchedule: ${model.deliverySchedule}');
    // ignore: avoid_print
    print('Model deliverySchedule.type: ${model.deliverySchedule?.type}');
    // ignore: avoid_print
    print('Model deliverySchedule.label: ${model.deliverySchedule?.label}');
    // ignore: avoid_print
    print('Model startDateGmt: ${model.startDateGmt}, dateCreated: ${model.dateCreated}');
    // ignore: avoid_print
    print('Model nextPaymentDateGmt: ${model.nextPaymentDateGmt}');

    return model;
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "parent_id": parentId,
        "status": status,
        "currency": currency,
        "version": version,
        "prices_include_tax": pricesIncludeTax,
        "date_created": dateCreated,
        "date_modified": dateModified,
        "discount_total": discountTotal,
        "discount_tax": discountTax,
        "shipping_total": shippingTotal,
        "shipping_tax": shippingTax,
        "cart_tax": cartTax,
        "total": total,
        "total_tax": totalTax,
        "customer_id": customerId,
        "delivery_schedule": deliverySchedule?.toJson(),
        "delivery_slot": deliverySlot?.toJson(),
        "order_key": orderKey,
        "billing": billing?.toJson(),
        "shipping": shipping?.toJson(),
        "payment_method": paymentMethod,
        "payment_method_title": paymentMethodTitle,
        "customer_ip_address": customerIpAddress,
        "customer_user_agent": customerUserAgent,
        "created_via": createdVia,
        "customer_note": customerNote,
        "date_completed": dateCompleted,
        "date_paid": datePaid,
        "number": number,
        "line_items": lineItems == null
            ? []
            : List<dynamic>.from(lineItems!.map((x) => x.toJson())),
        "tax_lines":
            taxLines == null ? [] : List<dynamic>.from(taxLines!.map((x) => x)),
        "shipping_lines": shippingLines == null
            ? []
            : List<dynamic>.from(shippingLines!.map((x) => x)),
        "fee_lines":
            feeLines == null ? [] : List<dynamic>.from(feeLines!.map((x) => x)),
        "coupon_lines": couponLines == null
            ? []
            : List<dynamic>.from(couponLines!.map((x) => x)),
        "payment_url": paymentUrl,
        "is_editable": isEditable,
        "needs_payment": needsPayment,
        "needs_processing": needsProcessing,
        "date_created_gmt": dateCreatedGmt,
        "date_modified_gmt": dateModifiedGmt,
        "date_completed_gmt": dateCompletedGmt,
        "date_paid_gmt": datePaidGmt,
        "is_paused": isPaused,
        "pause_dates": pauseDates == null
            ? []
            : List<dynamic>.from(pauseDates!.map((x) => x)),
        "resume_date": resumeDate,
        "pause_type": pauseType,
        "billing_period": billingPeriod,
        "billing_interval": billingInterval,
        "trial_period": trialPeriod,
        "suspension_count": suspensionCount,
        "requires_manual_renewal": requiresManualRenewal,
        "start_date_gmt": startDateGmt,
        "trial_end_date_gmt": trialEndDateGmt,
        "next_payment_date_gmt": nextPaymentDateGmt,
        "last_payment_date_gmt": lastPaymentDateGmt,
        "cancelled_date_gmt": cancelledDateGmt,
        "end_date_gmt": endDateGmt,
        "resubscribed_from": resubscribedFrom,
        "resubscribed_subscription": resubscribedSubscription,
        "removed_line_items": removedLineItems == null
            ? []
            : List<dynamic>.from(removedLineItems!.map((x) => x)),
      };
}

class Ing {
  final String? firstName;
  final String? lastName;
  final String? company;
  final String? address1;
  final String? address2;
  final String? city;
  final String? state;
  final String? postcode;
  final String? country;
  final String? email;
  final String? phone;

  Ing({
    this.firstName,
    this.lastName,
    this.company,
    this.address1,
    this.address2,
    this.city,
    this.state,
    this.postcode,
    this.country,
    this.email,
    this.phone,
  });

  factory Ing.fromJson(Map<String, dynamic> json) => Ing(
        firstName: json["first_name"],
        lastName: json["last_name"],
        company: json["company"],
        address1: json["address_1"],
        address2: json["address_2"],
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
        "company": company,
        "address_1": address1,
        "address_2": address2,
        "city": city,
        "state": state,
        "postcode": postcode,
        "country": country,
        "email": email,
        "phone": phone,
      };
}

class DeliverySchedule {
  final String? type;
  final String? label;
  final List<int>? days;
  final List<String>? dayNames;

  DeliverySchedule({
    this.type,
    this.label,
    this.days,
    this.dayNames,
  });

  factory DeliverySchedule.fromJson(Map<String, dynamic> json) =>
      DeliverySchedule(
        type: json["type"],
        label: json["label"],
        days: json["days"] == null
            ? []
            : List<int>.from(json["days"]!.map((x) => x)),
        dayNames: json["day_names"] == null
            ? []
            : List<String>.from(json["day_names"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "label": label,
        "days": days == null ? [] : List<dynamic>.from(days!.map((x) => x)),
        "day_names":
            dayNames == null ? [] : List<dynamic>.from(dayNames!.map((x) => x)),
      };
}

class DeliverySlot {
  final int? id;
  final String? name;
  final String? startTime;
  final String? endTime;
  final String? timeLabel;
  final String? label;
  final String? status;

  DeliverySlot({
    this.id,
    this.name,
    this.startTime,
    this.endTime,
    this.timeLabel,
    this.label,
    this.status,
  });

  factory DeliverySlot.fromJson(Map<String, dynamic> json) => DeliverySlot(
        id: json["id"],
        name: json["name"],
        startTime: json["start_time"],
        endTime: json["end_time"],
        timeLabel: json["time_label"],
        label: json["label"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "start_time": startTime,
        "end_time": endTime,
        "time_label": timeLabel,
        "label": label,
        "status": status,
      };
}

class LineItem {
  final dynamic id;
  final String? name;
  final dynamic productId;
  final dynamic variationId;
  final dynamic quantity;
  final String? taxClass;
  final String? subtotal;
  final String? subtotalTax;
  final String? total;
  final String? totalTax;
  final List<dynamic>? taxes;
  final List<dynamic>? metaData;
  final String? sku;
  final String? globalUniqueId;
  final int? price;
  final Image? image;
  final dynamic parentName;

  LineItem({
    this.id,
    this.name,
    this.productId,
    this.variationId,
    this.quantity,
    this.taxClass,
    this.subtotal,
    this.subtotalTax,
    this.total,
    this.totalTax,
    this.taxes,
    this.metaData,
    this.sku,
    this.globalUniqueId,
    this.price,
    this.image,
    this.parentName,
  });

  factory LineItem.fromJson(Map<String, dynamic> json) => LineItem(
        id: json["id"],
        name: json["name"],
        productId: json["product_id"],
        variationId: json["variation_id"],
        quantity: json["quantity"],
        taxClass: json["tax_class"],
        subtotal: json["subtotal"],
        subtotalTax: json["subtotal_tax"],
        total: json["total"],
        totalTax: json["total_tax"],
        taxes: json["taxes"] == null
            ? []
            : List<dynamic>.from(json["taxes"]!.map((x) => x)),
        metaData: json["meta_data"] == null
            ? []
            : List<dynamic>.from(json["meta_data"]!.map((x) => x)),
        sku: json["sku"],
        globalUniqueId: json["global_unique_id"],
        price: json["price"],
        image: json["image"] == null ? null : Image.fromJson(json["image"]),
        parentName: json["parent_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "product_id": productId,
        "variation_id": variationId,
        "quantity": quantity,
        "tax_class": taxClass,
        "subtotal": subtotal,
        "subtotal_tax": subtotalTax,
        "total": total,
        "total_tax": totalTax,
        "taxes": taxes == null ? [] : List<dynamic>.from(taxes!.map((x) => x)),
        "meta_data":
            metaData == null ? [] : List<dynamic>.from(metaData!.map((x) => x)),
        "sku": sku,
        "global_unique_id": globalUniqueId,
        "price": price,
        "image": image?.toJson(),
        "parent_name": parentName,
      };
}

class Image {
  final dynamic id;
  final String? src;

  Image({
    this.id,
    this.src,
  });

  factory Image.fromJson(Map<String, dynamic> json) => Image(
        id: json["id"],
        src: json["src"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "src": src,
      };
}


