// To parse this JSON data, do
//
//     final getCustomerOrdersResponeModel = getCustomerOrdersResponeModelFromJson(jsonString);

import 'dart:convert';

GetCustomerOrdersResponeModel getCustomerOrdersResponeModelFromJson(
        String str) =>
    GetCustomerOrdersResponeModel.fromJson(json.decode(str));

String getCustomerOrdersResponeModelToJson(
        GetCustomerOrdersResponeModel data) =>
    json.encode(data.toJson());

class GetCustomerOrdersResponeModel {
  List<HistoryProduct>? products;
  int? total;
  int? totalPages;
  int? perPage;
  int? currentPage;

  GetCustomerOrdersResponeModel({
    this.products,
    this.total,
    this.totalPages,
    this.perPage,
    this.currentPage,
  });

  GetCustomerOrdersResponeModel copyWith({
    List<HistoryProduct>? products,
    int? total,
    int? totalPages,
    int? perPage,
    int? currentPage,
  }) =>
      GetCustomerOrdersResponeModel(
        products: products ?? this.products,
        total: total ?? this.total,
        totalPages: totalPages ?? this.totalPages,
        perPage: perPage ?? this.perPage,
        currentPage: currentPage ?? this.currentPage,
      );

  factory GetCustomerOrdersResponeModel.fromJson(Map<String, dynamic> json) =>
      GetCustomerOrdersResponeModel(
        products: json["products"] == null
            ? []
            : List<HistoryProduct>.from(
                json["products"]!.map((x) => HistoryProduct.fromJson(x))),
        total: json["total"],
        totalPages: json["total_pages"],
        perPage: json["per_page"],
        currentPage: json["current_page"],
      );

  Map<String, dynamic> toJson() => {
        "products": products == null
            ? []
            : List<dynamic>.from(products!.map((x) => x.toJson())),
        "total": total,
        "total_pages": totalPages,
        "per_page": perPage,
        "current_page": currentPage,
      };
}

class HistoryProduct {
  int? id;
  int? parentId;
  String? status;
  String? currency;
  String? version;
  bool? pricesIncludeTax;
  DateTime? dateCreated;
  DateTime? dateModified;
  String? discountTotal;
  String? discountTax;
  String? shippingTotal;
  String? shippingTax;
  String? cartTax;
  String? total;
  String? totalTax;
  int? customerId;
  String? orderKey;
  Ing? billing;
  Ing? shipping;
  String? paymentMethod;
  String? paymentMethodTitle;
  String? transactionId;
  String? customerIpAddress;
  String? customerUserAgent;
  String? createdVia;
  String? customerNote;
  DateTime? dateCompleted;
  DateTime? datePaid;
  String? cartHash;
  String? number;
  List<ProductMetaDatum>? metaData;
  List<LineItem>? lineItems;
  List<dynamic>? taxLines;
  List<dynamic>? shippingLines;
  List<dynamic>? feeLines;
  List<dynamic>? couponLines;
  List<Refund>? refunds;
  String? paymentUrl;
  bool? isEditable;
  bool? needsPayment;
  bool? needsProcessing;
  DateTime? dateCreatedGmt;
  DateTime? dateModifiedGmt;
  DateTime? dateCompletedGmt;
  DateTime? datePaidGmt;
  String? currencySymbol;
  String? deliveryStatus;
  String? orderType;
  Links? links;

  HistoryProduct({
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
    this.transactionId,
    this.customerIpAddress,
    this.customerUserAgent,
    this.createdVia,
    this.customerNote,
    this.dateCompleted,
    this.datePaid,
    this.cartHash,
    this.number,
    this.metaData,
    this.lineItems,
    this.taxLines,
    this.shippingLines,
    this.feeLines,
    this.couponLines,
    this.refunds,
    this.paymentUrl,
    this.isEditable,
    this.needsPayment,
    this.needsProcessing,
    this.dateCreatedGmt,
    this.dateModifiedGmt,
    this.dateCompletedGmt,
    this.datePaidGmt,
    this.currencySymbol,
    this.deliveryStatus,
    this.orderType,
    this.links,
  });

  HistoryProduct copyWith({
    int? id,
    int? parentId,
    String? status,
    String? currency,
    String? version,
    bool? pricesIncludeTax,
    DateTime? dateCreated,
    DateTime? dateModified,
    String? discountTotal,
    String? discountTax,
    String? shippingTotal,
    String? shippingTax,
    String? cartTax,
    String? total,
    String? totalTax,
    int? customerId,
    String? orderKey,
    Ing? billing,
    Ing? shipping,
    String? paymentMethod,
    String? paymentMethodTitle,
    String? transactionId,
    String? customerIpAddress,
    String? customerUserAgent,
    String? createdVia,
    String? customerNote,
    DateTime? dateCompleted,
    DateTime? datePaid,
    String? cartHash,
    String? number,
    List<ProductMetaDatum>? metaData,
    List<LineItem>? lineItems,
    List<dynamic>? taxLines,
    List<dynamic>? shippingLines,
    List<dynamic>? feeLines,
    List<dynamic>? couponLines,
    List<Refund>? refunds,
    String? paymentUrl,
    bool? isEditable,
    bool? needsPayment,
    bool? needsProcessing,
    DateTime? dateCreatedGmt,
    DateTime? dateModifiedGmt,
    DateTime? dateCompletedGmt,
    DateTime? datePaidGmt,
    String? currencySymbol,
    String? deliveryStatus,
    String? orderType,
    Links? links,
  }) =>
      HistoryProduct(
        id: id ?? this.id,
        parentId: parentId ?? this.parentId,
        status: status ?? this.status,
        currency: currency ?? this.currency,
        version: version ?? this.version,
        pricesIncludeTax: pricesIncludeTax ?? this.pricesIncludeTax,
        dateCreated: dateCreated ?? this.dateCreated,
        dateModified: dateModified ?? this.dateModified,
        discountTotal: discountTotal ?? this.discountTotal,
        discountTax: discountTax ?? this.discountTax,
        shippingTotal: shippingTotal ?? this.shippingTotal,
        shippingTax: shippingTax ?? this.shippingTax,
        cartTax: cartTax ?? this.cartTax,
        total: total ?? this.total,
        totalTax: totalTax ?? this.totalTax,
        customerId: customerId ?? this.customerId,
        orderKey: orderKey ?? this.orderKey,
        billing: billing ?? this.billing,
        shipping: shipping ?? this.shipping,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        paymentMethodTitle: paymentMethodTitle ?? this.paymentMethodTitle,
        transactionId: transactionId ?? this.transactionId,
        customerIpAddress: customerIpAddress ?? this.customerIpAddress,
        customerUserAgent: customerUserAgent ?? this.customerUserAgent,
        createdVia: createdVia ?? this.createdVia,
        customerNote: customerNote ?? this.customerNote,
        dateCompleted: dateCompleted ?? this.dateCompleted,
        datePaid: datePaid ?? this.datePaid,
        cartHash: cartHash ?? this.cartHash,
        number: number ?? this.number,
        metaData: metaData ?? this.metaData,
        lineItems: lineItems ?? this.lineItems,
        taxLines: taxLines ?? this.taxLines,
        shippingLines: shippingLines ?? this.shippingLines,
        feeLines: feeLines ?? this.feeLines,
        couponLines: couponLines ?? this.couponLines,
        refunds: refunds ?? this.refunds,
        paymentUrl: paymentUrl ?? this.paymentUrl,
        isEditable: isEditable ?? this.isEditable,
        needsPayment: needsPayment ?? this.needsPayment,
        needsProcessing: needsProcessing ?? this.needsProcessing,
        dateCreatedGmt: dateCreatedGmt ?? this.dateCreatedGmt,
        dateModifiedGmt: dateModifiedGmt ?? this.dateModifiedGmt,
        dateCompletedGmt: dateCompletedGmt ?? this.dateCompletedGmt,
        datePaidGmt: datePaidGmt ?? this.datePaidGmt,
        currencySymbol: currencySymbol ?? this.currencySymbol,
        deliveryStatus: deliveryStatus ?? this.deliveryStatus,
        orderType: orderType ?? this.orderType,
        links: links ?? this.links,
      );

  factory HistoryProduct.fromJson(Map<String, dynamic> json) => HistoryProduct(
        id: json["id"],
        parentId: json["parent_id"],
        status: json["status"],
        currency: json["currency"],
        version: json["version"],
        pricesIncludeTax: json["prices_include_tax"],
        dateCreated: json["date_created"] == null
            ? null
            : DateTime.parse(json["date_created"]),
        dateModified: json["date_modified"] == null
            ? null
            : DateTime.parse(json["date_modified"]),
        discountTotal: json["discount_total"],
        discountTax: json["discount_tax"],
        shippingTotal: json["shipping_total"],
        shippingTax: json["shipping_tax"],
        cartTax: json["cart_tax"],
        total: json["total"],
        totalTax: json["total_tax"],
        customerId: json["customer_id"],
        orderKey: json["order_key"],
        billing: json["billing"] == null ? null : Ing.fromJson(json["billing"]),
        shipping:
            json["shipping"] == null ? null : Ing.fromJson(json["shipping"]),
        paymentMethod: json["payment_method"],
        paymentMethodTitle: json["payment_method_title"],
        transactionId: json["transaction_id"],
        customerIpAddress: json["customer_ip_address"],
        customerUserAgent: json["customer_user_agent"],
        createdVia: json["created_via"],
        customerNote: json["customer_note"],
        dateCompleted: json["date_completed"] == null
            ? null
            : DateTime.parse(json["date_completed"]),
        datePaid: json["date_paid"] == null
            ? null
            : DateTime.parse(json["date_paid"]),
        cartHash: json["cart_hash"],
        number: json["number"],
        metaData: json["meta_data"] == null
            ? []
            : List<ProductMetaDatum>.from(
                json["meta_data"]!.map((x) => ProductMetaDatum.fromJson(x))),
        lineItems: json["line_items"] == null
            ? []
            : List<LineItem>.from(
                json["line_items"]!.map((x) => LineItem.fromJson(x))),
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
        refunds: json["refunds"] == null
            ? []
            : List<Refund>.from(
                json["refunds"]!.map((x) => Refund.fromJson(x))),
        paymentUrl: json["payment_url"],
        isEditable: json["is_editable"],
        needsPayment: json["needs_payment"],
        needsProcessing: json["needs_processing"],
        dateCreatedGmt: json["date_created_gmt"] == null
            ? null
            : DateTime.parse(json["date_created_gmt"]),
        dateModifiedGmt: json["date_modified_gmt"] == null
            ? null
            : DateTime.parse(json["date_modified_gmt"]),
        dateCompletedGmt: json["date_completed_gmt"] == null
            ? null
            : DateTime.parse(json["date_completed_gmt"]),
        datePaidGmt: json["date_paid_gmt"] == null
            ? null
            : DateTime.parse(json["date_paid_gmt"]),
        currencySymbol: json["currency_symbol"],
        deliveryStatus: json["delivery_status"],
        orderType: json["order_type"]?.toString() ??
            _extractOrderTypeFromMeta(json["meta_data"]),
        links: json["_links"] == null ? null : Links.fromJson(json["_links"]),
      );

  static String? _extractOrderTypeFromMeta(dynamic metaData) {
    if (metaData is List) {
      for (final m in metaData) {
        if (m is Map &&
            (m["key"] == "order_type" || m["key"] == "_order_type")) {
          return m["value"]?.toString();
        }
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "parent_id": parentId,
        "status": status,
        "currency": currency,
        "version": version,
        "prices_include_tax": pricesIncludeTax,
        "date_created": dateCreated?.toIso8601String(),
        "date_modified": dateModified?.toIso8601String(),
        "discount_total": discountTotal,
        "discount_tax": discountTax,
        "shipping_total": shippingTotal,
        "shipping_tax": shippingTax,
        "cart_tax": cartTax,
        "total": total,
        "total_tax": totalTax,
        "customer_id": customerId,
        "order_key": orderKey,
        "billing": billing?.toJson(),
        "shipping": shipping?.toJson(),
        "payment_method": paymentMethod,
        "payment_method_title": paymentMethodTitle,
        "transaction_id": transactionId,
        "customer_ip_address": customerIpAddress,
        "customer_user_agent": customerUserAgent,
        "created_via": createdVia,
        "customer_note": customerNote,
        "date_completed": dateCompleted?.toIso8601String(),
        "date_paid": datePaid?.toIso8601String(),
        "cart_hash": cartHash,
        "number": number,
        "meta_data": metaData == null
            ? []
            : List<dynamic>.from(metaData!.map((x) => x.toJson())),
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
        "refunds": refunds == null
            ? []
            : List<dynamic>.from(refunds!.map((x) => x.toJson())),
        "payment_url": paymentUrl,
        "is_editable": isEditable,
        "needs_payment": needsPayment,
        "needs_processing": needsProcessing,
        "date_created_gmt": dateCreatedGmt?.toIso8601String(),
        "date_modified_gmt": dateModifiedGmt?.toIso8601String(),
        "date_completed_gmt": dateCompletedGmt?.toIso8601String(),
        "date_paid_gmt": datePaidGmt?.toIso8601String(),
        "currency_symbol": currencySymbol,
        "delivery_status": deliveryStatus,
        "order_type": orderType,
        "_links": links?.toJson(),
      };
}

class Ing {
  String? firstName;
  String? lastName;
  String? company;
  String? address1;
  String? address2;
  String? city;
  String? state;
  String? postcode;
  String? country;
  String? email;
  String? phone;

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

  Ing copyWith({
    String? firstName,
    String? lastName,
    String? company,
    String? address1,
    String? address2,
    String? city,
    String? state,
    String? postcode,
    String? country,
    String? email,
    String? phone,
  }) =>
      Ing(
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        company: company ?? this.company,
        address1: address1 ?? this.address1,
        address2: address2 ?? this.address2,
        city: city ?? this.city,
        state: state ?? this.state,
        postcode: postcode ?? this.postcode,
        country: country ?? this.country,
        email: email ?? this.email,
        phone: phone ?? this.phone,
      );

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

class LineItem {
  int? id;
  String? name;
  int? productId;
  int? variationId;
  int? quantity;
  String? taxClass;
  String? subtotal;
  String? subtotalTax;
  String? total;
  String? totalTax;
  List<dynamic>? taxes;
  List<LineItemMetaDatum>? metaData;
  String? sku;
  dynamic price;
  LineItemImage? image;
  dynamic parentName;
  ProductData? productData;

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
    this.price,
    this.image,
    this.parentName,
    this.productData,
  });

  LineItem copyWith({
    int? id,
    String? name,
    int? productId,
    int? variationId,
    int? quantity,
    String? taxClass,
    String? subtotal,
    String? subtotalTax,
    String? total,
    String? totalTax,
    List<dynamic>? taxes,
    List<LineItemMetaDatum>? metaData,
    String? sku,
    dynamic price,
    LineItemImage? image,
    dynamic parentName,
    ProductData? productData,
  }) =>
      LineItem(
        id: id ?? this.id,
        name: name ?? this.name,
        productId: productId ?? this.productId,
        variationId: variationId ?? this.variationId,
        quantity: quantity ?? this.quantity,
        taxClass: taxClass ?? this.taxClass,
        subtotal: subtotal ?? this.subtotal,
        subtotalTax: subtotalTax ?? this.subtotalTax,
        total: total ?? this.total,
        totalTax: totalTax ?? this.totalTax,
        taxes: taxes ?? this.taxes,
        metaData: metaData ?? this.metaData,
        sku: sku ?? this.sku,
        price: price ?? this.price,
        image: image ?? this.image,
        parentName: parentName ?? this.parentName,
        productData: productData ?? this.productData,
      );

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
        // metaData: json["meta_data"] == null
        //     ? []
        //     : List<LineItemMetaDatum>.from(
        //         json["meta_data"]!.map((x) => LineItemMetaDatum.fromJson(x))),
        sku: json["sku"],
        price: json["price"],
        image: json["image"] == null
            ? null
            : LineItemImage.fromJson(json["image"]),
        parentName: json["parent_name"],
        productData: json["product_data"] == null
            ? null
            : ProductData.fromJson(json["product_data"]),
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
        "meta_data": metaData == null
            ? []
            : List<dynamic>.from(metaData!.map((x) => x.toJson())),
        "sku": sku,
        "price": price,
        "image": image?.toJson(),
        "parent_name": parentName,
        "product_data": productData?.toJson(),
      };
}

class LineItemImage {
  dynamic id;
  String? src;

  LineItemImage({
    this.id,
    this.src,
  });

  LineItemImage copyWith({
    dynamic id,
    String? src,
  }) =>
      LineItemImage(
        id: id ?? this.id,
        src: src ?? this.src,
      );

  factory LineItemImage.fromJson(Map<String, dynamic> json) => LineItemImage(
        id: json["id"],
        src: json["src"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "src": src,
      };
}

class LineItemMetaDatum {
  int? id;
  String? key;
  String? value;
  String? displayKey;
  String? displayValue;

  LineItemMetaDatum({
    this.id,
    this.key,
    this.value,
    this.displayKey,
    this.displayValue,
  });

  LineItemMetaDatum copyWith({
    int? id,
    String? key,
    String? value,
    String? displayKey,
    String? displayValue,
  }) =>
      LineItemMetaDatum(
        id: id ?? this.id,
        key: key ?? this.key,
        value: value ?? this.value,
        displayKey: displayKey ?? this.displayKey,
        displayValue: displayValue ?? this.displayValue,
      );

  factory LineItemMetaDatum.fromJson(Map<String, dynamic> json) =>
      LineItemMetaDatum(
        id: json["id"],
        key: json["key"],
        value: json["value"],
        displayKey: json["display_key"],
        displayValue: json["display_value"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "key": key,
        "value": value,
        "display_key": displayKey,
        "display_value": displayValue,
      };
}

class ProductData {
  int? id;
  String? name;
  String? slug;
  String? permalink;
  DateTime? dateCreated;
  DateTime? dateCreatedGmt;
  DateTime? dateModified;
  DateTime? dateModifiedGmt;
  String? type;
  String? status;
  bool? featured;
  String? catalogVisibility;
  String? description;
  String? shortDescription;
  String? sku;
  dynamic price;
  dynamic regularPrice;
  dynamic salePrice;
  dynamic dateOnSaleFrom;
  dynamic dateOnSaleFromGmt;
  dynamic dateOnSaleTo;
  dynamic dateOnSaleToGmt;
  bool? onSale;
  bool? purchasable;
  int? totalSales;
  bool? virtual;
  bool? downloadable;
  List<dynamic>? downloads;
  int? downloadLimit;
  int? downloadExpiry;
  String? externalUrl;
  String? buttonText;
  String? taxStatus;
  String? taxClass;
  bool? manageStock;
  dynamic stockQuantity;
  String? backorders;
  bool? backordersAllowed;
  bool? backordered;
  dynamic lowStockAmount;
  bool? soldIndividually;
  String? weight;
  Dimensions? dimensions;
  bool? shippingRequired;
  bool? shippingTaxable;
  String? shippingClass;
  int? shippingClassId;
  bool? reviewsAllowed;
  String? averageRating;
  int? ratingCount;
  List<dynamic>? upsellIds;
  List<dynamic>? crossSellIds;
  int? parentId;
  String? purchaseNote;
  List<Brand>? categories;
  List<dynamic>? tags;
  List<ImageElement>? images;
  List<dynamic>? attributes;
  List<dynamic>? defaultAttributes;
  List<dynamic>? variations;
  List<dynamic>? groupedProducts;
  int? menuOrder;
  String? priceHtml;
  List<int>? relatedIds;
  List<ProductDataMetaDatum>? metaData;
  String? stockStatus;
  bool? hasOptions;
  String? postPassword;
  String? globalUniqueId;
  List<Brand>? brands;
  bool? isPurchased;
  List<dynamic>? attributesData;
  ProductUnits? productUnits;
  WcfmProductPolicyData? wcfmProductPolicyData;
  bool? showAdditionalInfoTab;
  Store? store;
  String? productRestirctionMessage;

  ProductData({
    this.id,
    this.name,
    this.slug,
    this.permalink,
    this.dateCreated,
    this.dateCreatedGmt,
    this.dateModified,
    this.dateModifiedGmt,
    this.type,
    this.status,
    this.featured,
    this.catalogVisibility,
    this.description,
    this.shortDescription,
    this.sku,
    this.price,
    this.regularPrice,
    this.salePrice,
    this.dateOnSaleFrom,
    this.dateOnSaleFromGmt,
    this.dateOnSaleTo,
    this.dateOnSaleToGmt,
    this.onSale,
    this.purchasable,
    this.totalSales,
    this.virtual,
    this.downloadable,
    this.downloads,
    this.downloadLimit,
    this.downloadExpiry,
    this.externalUrl,
    this.buttonText,
    this.taxStatus,
    this.taxClass,
    this.manageStock,
    this.stockQuantity,
    this.backorders,
    this.backordersAllowed,
    this.backordered,
    this.lowStockAmount,
    this.soldIndividually,
    this.weight,
    this.dimensions,
    this.shippingRequired,
    this.shippingTaxable,
    this.shippingClass,
    this.shippingClassId,
    this.reviewsAllowed,
    this.averageRating,
    this.ratingCount,
    this.upsellIds,
    this.crossSellIds,
    this.parentId,
    this.purchaseNote,
    this.categories,
    this.tags,
    this.images,
    this.attributes,
    this.defaultAttributes,
    this.variations,
    this.groupedProducts,
    this.menuOrder,
    this.priceHtml,
    this.relatedIds,
    this.metaData,
    this.stockStatus,
    this.hasOptions,
    this.postPassword,
    this.globalUniqueId,
    this.brands,
    this.isPurchased,
    this.attributesData,
    this.productUnits,
    this.wcfmProductPolicyData,
    this.showAdditionalInfoTab,
    this.store,
    this.productRestirctionMessage,
  });

  ProductData copyWith({
    int? id,
    String? name,
    String? slug,
    String? permalink,
    DateTime? dateCreated,
    DateTime? dateCreatedGmt,
    DateTime? dateModified,
    DateTime? dateModifiedGmt,
    String? type,
    String? status,
    bool? featured,
    String? catalogVisibility,
    String? description,
    String? shortDescription,
    String? sku,
    dynamic price,
    dynamic regularPrice,
    dynamic salePrice,
    dynamic dateOnSaleFrom,
    dynamic dateOnSaleFromGmt,
    dynamic dateOnSaleTo,
    dynamic dateOnSaleToGmt,
    bool? onSale,
    bool? purchasable,
    int? totalSales,
    bool? virtual,
    bool? downloadable,
    List<dynamic>? downloads,
    int? downloadLimit,
    int? downloadExpiry,
    String? externalUrl,
    String? buttonText,
    String? taxStatus,
    String? taxClass,
    bool? manageStock,
    dynamic stockQuantity,
    String? backorders,
    bool? backordersAllowed,
    bool? backordered,
    dynamic lowStockAmount,
    bool? soldIndividually,
    String? weight,
    Dimensions? dimensions,
    bool? shippingRequired,
    bool? shippingTaxable,
    String? shippingClass,
    int? shippingClassId,
    bool? reviewsAllowed,
    String? averageRating,
    int? ratingCount,
    List<dynamic>? upsellIds,
    List<dynamic>? crossSellIds,
    int? parentId,
    String? purchaseNote,
    List<Brand>? categories,
    List<dynamic>? tags,
    List<ImageElement>? images,
    List<dynamic>? attributes,
    List<dynamic>? defaultAttributes,
    List<dynamic>? variations,
    List<dynamic>? groupedProducts,
    int? menuOrder,
    String? priceHtml,
    List<int>? relatedIds,
    List<ProductDataMetaDatum>? metaData,
    String? stockStatus,
    bool? hasOptions,
    String? postPassword,
    String? globalUniqueId,
    List<Brand>? brands,
    bool? isPurchased,
    List<dynamic>? attributesData,
    ProductUnits? productUnits,
    WcfmProductPolicyData? wcfmProductPolicyData,
    bool? showAdditionalInfoTab,
    Store? store,
    String? productRestirctionMessage,
  }) =>
      ProductData(
        id: id ?? this.id,
        name: name ?? this.name,
        slug: slug ?? this.slug,
        permalink: permalink ?? this.permalink,
        dateCreated: dateCreated ?? this.dateCreated,
        dateCreatedGmt: dateCreatedGmt ?? this.dateCreatedGmt,
        dateModified: dateModified ?? this.dateModified,
        dateModifiedGmt: dateModifiedGmt ?? this.dateModifiedGmt,
        type: type ?? this.type,
        status: status ?? this.status,
        featured: featured ?? this.featured,
        catalogVisibility: catalogVisibility ?? this.catalogVisibility,
        description: description ?? this.description,
        shortDescription: shortDescription ?? this.shortDescription,
        sku: sku ?? this.sku,
        price: price ?? this.price,
        regularPrice: regularPrice ?? this.regularPrice,
        salePrice: salePrice ?? this.salePrice,
        dateOnSaleFrom: dateOnSaleFrom ?? this.dateOnSaleFrom,
        dateOnSaleFromGmt: dateOnSaleFromGmt ?? this.dateOnSaleFromGmt,
        dateOnSaleTo: dateOnSaleTo ?? this.dateOnSaleTo,
        dateOnSaleToGmt: dateOnSaleToGmt ?? this.dateOnSaleToGmt,
        onSale: onSale ?? this.onSale,
        purchasable: purchasable ?? this.purchasable,
        totalSales: totalSales ?? this.totalSales,
        virtual: virtual ?? this.virtual,
        downloadable: downloadable ?? this.downloadable,
        downloads: downloads ?? this.downloads,
        downloadLimit: downloadLimit ?? this.downloadLimit,
        downloadExpiry: downloadExpiry ?? this.downloadExpiry,
        externalUrl: externalUrl ?? this.externalUrl,
        buttonText: buttonText ?? this.buttonText,
        taxStatus: taxStatus ?? this.taxStatus,
        taxClass: taxClass ?? this.taxClass,
        manageStock: manageStock ?? this.manageStock,
        stockQuantity: stockQuantity ?? this.stockQuantity,
        backorders: backorders ?? this.backorders,
        backordersAllowed: backordersAllowed ?? this.backordersAllowed,
        backordered: backordered ?? this.backordered,
        lowStockAmount: lowStockAmount ?? this.lowStockAmount,
        soldIndividually: soldIndividually ?? this.soldIndividually,
        weight: weight ?? this.weight,
        dimensions: dimensions ?? this.dimensions,
        shippingRequired: shippingRequired ?? this.shippingRequired,
        shippingTaxable: shippingTaxable ?? this.shippingTaxable,
        shippingClass: shippingClass ?? this.shippingClass,
        shippingClassId: shippingClassId ?? this.shippingClassId,
        reviewsAllowed: reviewsAllowed ?? this.reviewsAllowed,
        averageRating: averageRating ?? this.averageRating,
        ratingCount: ratingCount ?? this.ratingCount,
        upsellIds: upsellIds ?? this.upsellIds,
        crossSellIds: crossSellIds ?? this.crossSellIds,
        parentId: parentId ?? this.parentId,
        purchaseNote: purchaseNote ?? this.purchaseNote,
        categories: categories ?? this.categories,
        tags: tags ?? this.tags,
        images: images ?? this.images,
        attributes: attributes ?? this.attributes,
        defaultAttributes: defaultAttributes ?? this.defaultAttributes,
        variations: variations ?? this.variations,
        groupedProducts: groupedProducts ?? this.groupedProducts,
        menuOrder: menuOrder ?? this.menuOrder,
        priceHtml: priceHtml ?? this.priceHtml,
        relatedIds: relatedIds ?? this.relatedIds,
        metaData: metaData ?? this.metaData,
        stockStatus: stockStatus ?? this.stockStatus,
        hasOptions: hasOptions ?? this.hasOptions,
        postPassword: postPassword ?? this.postPassword,
        globalUniqueId: globalUniqueId ?? this.globalUniqueId,
        brands: brands ?? this.brands,
        isPurchased: isPurchased ?? this.isPurchased,
        attributesData: attributesData ?? this.attributesData,
        productUnits: productUnits ?? this.productUnits,
        wcfmProductPolicyData:
            wcfmProductPolicyData ?? this.wcfmProductPolicyData,
        showAdditionalInfoTab:
            showAdditionalInfoTab ?? this.showAdditionalInfoTab,
        store: store ?? this.store,
        productRestirctionMessage:
            productRestirctionMessage ?? this.productRestirctionMessage,
      );

  factory ProductData.fromJson(Map<String, dynamic> json) => ProductData(
        id: json["id"],
        name: json["name"],
        slug: json["slug"],
        permalink: json["permalink"],
        dateCreated: json["date_created"] == null
            ? null
            : DateTime.parse(json["date_created"]),
        dateCreatedGmt: json["date_created_gmt"] == null
            ? null
            : DateTime.parse(json["date_created_gmt"]),
        dateModified: json["date_modified"] == null
            ? null
            : DateTime.parse(json["date_modified"]),
        dateModifiedGmt: json["date_modified_gmt"] == null
            ? null
            : DateTime.parse(json["date_modified_gmt"]),
        type: json["type"],
        status: json["status"],
        featured: json["featured"],
        catalogVisibility: json["catalog_visibility"],
        description: json["description"],
        shortDescription: json["short_description"],
        sku: json["sku"],
        price: json["price"],
        regularPrice: json["regular_price"],
        salePrice: json["sale_price"],
        dateOnSaleFrom: json["date_on_sale_from"],
        dateOnSaleFromGmt: json["date_on_sale_from_gmt"],
        dateOnSaleTo: json["date_on_sale_to"],
        dateOnSaleToGmt: json["date_on_sale_to_gmt"],
        onSale: json["on_sale"],
        purchasable: json["purchasable"],
        totalSales: json["total_sales"],
        virtual: json["virtual"],
        downloadable: json["downloadable"],
        downloads: json["downloads"] == null
            ? []
            : List<dynamic>.from(json["downloads"]!.map((x) => x)),
        downloadLimit: json["download_limit"],
        downloadExpiry: json["download_expiry"],
        externalUrl: json["external_url"],
        buttonText: json["button_text"],
        taxStatus: json["tax_status"],
        taxClass: json["tax_class"],
        manageStock: json["manage_stock"],
        stockQuantity: json["stock_quantity"],
        backorders: json["backorders"],
        backordersAllowed: json["backorders_allowed"],
        backordered: json["backordered"],
        lowStockAmount: json["low_stock_amount"],
        soldIndividually: json["sold_individually"],
        weight: json["weight"],
        dimensions: json["dimensions"] == null
            ? null
            : Dimensions.fromJson(json["dimensions"]),
        shippingRequired: json["shipping_required"],
        shippingTaxable: json["shipping_taxable"],
        shippingClass: json["shipping_class"],
        shippingClassId: json["shipping_class_id"],
        reviewsAllowed: json["reviews_allowed"],
        averageRating: json["average_rating"],
        ratingCount: json["rating_count"],
        upsellIds: json["upsell_ids"] == null
            ? []
            : List<dynamic>.from(json["upsell_ids"]!.map((x) => x)),
        crossSellIds: json["cross_sell_ids"] == null
            ? []
            : List<dynamic>.from(json["cross_sell_ids"]!.map((x) => x)),
        parentId: json["parent_id"],
        purchaseNote: json["purchase_note"],
        categories: json["categories"] == null
            ? []
            : List<Brand>.from(
                json["categories"]!.map((x) => Brand.fromJson(x))),
        tags: json["tags"] == null
            ? []
            : List<dynamic>.from(json["tags"]!.map((x) => x)),
        images: json["images"] == null
            ? []
            : List<ImageElement>.from(
                json["images"]!.map((x) => ImageElement.fromJson(x))),
        attributes: json["attributes"] == null
            ? []
            : List<dynamic>.from(json["attributes"]!.map((x) => x)),
        defaultAttributes: json["default_attributes"] == null
            ? []
            : List<dynamic>.from(json["default_attributes"]!.map((x) => x)),
        variations: json["variations"] == null
            ? []
            : List<dynamic>.from(json["variations"]!.map((x) => x)),
        groupedProducts: json["grouped_products"] == null
            ? []
            : List<dynamic>.from(json["grouped_products"]!.map((x) => x)),
        menuOrder: json["menu_order"],
        priceHtml: json["price_html"],
        relatedIds: json["related_ids"] == null
            ? []
            : List<int>.from(json["related_ids"]!.map((x) => x)),
        metaData: json["meta_data"] == null
            ? []
            : List<ProductDataMetaDatum>.from(json["meta_data"]!
                .map((x) => ProductDataMetaDatum.fromJson(x))),
        stockStatus: json["stock_status"],
        hasOptions: json["has_options"],
        postPassword: json["post_password"],
        globalUniqueId: json["global_unique_id"],
        brands: json["brands"] == null
            ? []
            : List<Brand>.from(json["brands"]!.map((x) => Brand.fromJson(x))),
        isPurchased: json["is_purchased"],
        attributesData: json["attributesData"] == null
            ? []
            : List<dynamic>.from(json["attributesData"]!.map((x) => x)),
        productUnits: json["product_units"] == null
            ? null
            : ProductUnits.fromJson(json["product_units"]),
        wcfmProductPolicyData: json["wcfm_product_policy_data"] == null
            ? null
            : WcfmProductPolicyData.fromJson(json["wcfm_product_policy_data"]),
        showAdditionalInfoTab: json["showAdditionalInfoTab"],
        store: json["store"] == null ? null : Store.fromJson(json["store"]),
        productRestirctionMessage: json["product_restirction_message"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
        "permalink": permalink,
        "date_created": dateCreated?.toIso8601String(),
        "date_created_gmt": dateCreatedGmt?.toIso8601String(),
        "date_modified": dateModified?.toIso8601String(),
        "date_modified_gmt": dateModifiedGmt?.toIso8601String(),
        "type": type,
        "status": status,
        "featured": featured,
        "catalog_visibility": catalogVisibility,
        "description": description,
        "short_description": shortDescription,
        "sku": sku,
        "price": price,
        "regular_price": regularPrice,
        "sale_price": salePrice,
        "date_on_sale_from": dateOnSaleFrom,
        "date_on_sale_from_gmt": dateOnSaleFromGmt,
        "date_on_sale_to": dateOnSaleTo,
        "date_on_sale_to_gmt": dateOnSaleToGmt,
        "on_sale": onSale,
        "purchasable": purchasable,
        "total_sales": totalSales,
        "virtual": virtual,
        "downloadable": downloadable,
        "downloads": downloads == null
            ? []
            : List<dynamic>.from(downloads!.map((x) => x)),
        "download_limit": downloadLimit,
        "download_expiry": downloadExpiry,
        "external_url": externalUrl,
        "button_text": buttonText,
        "tax_status": taxStatus,
        "tax_class": taxClass,
        "manage_stock": manageStock,
        "stock_quantity": stockQuantity,
        "backorders": backorders,
        "backorders_allowed": backordersAllowed,
        "backordered": backordered,
        "low_stock_amount": lowStockAmount,
        "sold_individually": soldIndividually,
        "weight": weight,
        "dimensions": dimensions?.toJson(),
        "shipping_required": shippingRequired,
        "shipping_taxable": shippingTaxable,
        "shipping_class": shippingClass,
        "shipping_class_id": shippingClassId,
        "reviews_allowed": reviewsAllowed,
        "average_rating": averageRating,
        "rating_count": ratingCount,
        "upsell_ids": upsellIds == null
            ? []
            : List<dynamic>.from(upsellIds!.map((x) => x)),
        "cross_sell_ids": crossSellIds == null
            ? []
            : List<dynamic>.from(crossSellIds!.map((x) => x)),
        "parent_id": parentId,
        "purchase_note": purchaseNote,
        "categories": categories == null
            ? []
            : List<dynamic>.from(categories!.map((x) => x.toJson())),
        "tags": tags == null ? [] : List<dynamic>.from(tags!.map((x) => x)),
        "images": images == null
            ? []
            : List<dynamic>.from(images!.map((x) => x.toJson())),
        "attributes": attributes == null
            ? []
            : List<dynamic>.from(attributes!.map((x) => x)),
        "default_attributes": defaultAttributes == null
            ? []
            : List<dynamic>.from(defaultAttributes!.map((x) => x)),
        "variations": variations == null
            ? []
            : List<dynamic>.from(variations!.map((x) => x)),
        "grouped_products": groupedProducts == null
            ? []
            : List<dynamic>.from(groupedProducts!.map((x) => x)),
        "menu_order": menuOrder,
        "price_html": priceHtml,
        "related_ids": relatedIds == null
            ? []
            : List<dynamic>.from(relatedIds!.map((x) => x)),
        "meta_data": metaData == null
            ? []
            : List<dynamic>.from(metaData!.map((x) => x.toJson())),
        "stock_status": stockStatus,
        "has_options": hasOptions,
        "post_password": postPassword,
        "global_unique_id": globalUniqueId,
        "brands": brands == null
            ? []
            : List<dynamic>.from(brands!.map((x) => x.toJson())),
        "is_purchased": isPurchased,
        "attributesData": attributesData == null
            ? []
            : List<dynamic>.from(attributesData!.map((x) => x)),
        "product_units": productUnits?.toJson(),
        "wcfm_product_policy_data": wcfmProductPolicyData?.toJson(),
        "showAdditionalInfoTab": showAdditionalInfoTab,
        "store": store?.toJson(),
        "product_restirction_message": productRestirctionMessage,
      };
}

class Brand {
  int? id;
  String? name;
  String? slug;

  Brand({
    this.id,
    this.name,
    this.slug,
  });

  Brand copyWith({
    int? id,
    String? name,
    String? slug,
  }) =>
      Brand(
        id: id ?? this.id,
        name: name ?? this.name,
        slug: slug ?? this.slug,
      );

  factory Brand.fromJson(Map<String, dynamic> json) => Brand(
        id: json["id"],
        name: json["name"],
        slug: json["slug"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
      };
}

class Dimensions {
  String? length;
  String? width;
  String? height;

  Dimensions({
    this.length,
    this.width,
    this.height,
  });

  Dimensions copyWith({
    String? length,
    String? width,
    String? height,
  }) =>
      Dimensions(
        length: length ?? this.length,
        width: width ?? this.width,
        height: height ?? this.height,
      );

  factory Dimensions.fromJson(Map<String, dynamic> json) => Dimensions(
        length: json["length"],
        width: json["width"],
        height: json["height"],
      );

  Map<String, dynamic> toJson() => {
        "length": length,
        "width": width,
        "height": height,
      };
}

class ImageElement {
  int? id;
  DateTime? dateCreated;
  DateTime? dateCreatedGmt;
  DateTime? dateModified;
  DateTime? dateModifiedGmt;
  String? src;
  String? name;
  String? alt;

  ImageElement({
    this.id,
    this.dateCreated,
    this.dateCreatedGmt,
    this.dateModified,
    this.dateModifiedGmt,
    this.src,
    this.name,
    this.alt,
  });

  ImageElement copyWith({
    int? id,
    DateTime? dateCreated,
    DateTime? dateCreatedGmt,
    DateTime? dateModified,
    DateTime? dateModifiedGmt,
    String? src,
    String? name,
    String? alt,
  }) =>
      ImageElement(
        id: id ?? this.id,
        dateCreated: dateCreated ?? this.dateCreated,
        dateCreatedGmt: dateCreatedGmt ?? this.dateCreatedGmt,
        dateModified: dateModified ?? this.dateModified,
        dateModifiedGmt: dateModifiedGmt ?? this.dateModifiedGmt,
        src: src ?? this.src,
        name: name ?? this.name,
        alt: alt ?? this.alt,
      );

  factory ImageElement.fromJson(Map<String, dynamic> json) => ImageElement(
        id: json["id"],
        dateCreated: json["date_created"] == null
            ? null
            : DateTime.parse(json["date_created"]),
        dateCreatedGmt: json["date_created_gmt"] == null
            ? null
            : DateTime.parse(json["date_created_gmt"]),
        dateModified: json["date_modified"] == null
            ? null
            : DateTime.parse(json["date_modified"]),
        dateModifiedGmt: json["date_modified_gmt"] == null
            ? null
            : DateTime.parse(json["date_modified_gmt"]),
        src: json["src"],
        name: json["name"],
        alt: json["alt"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "date_created": dateCreated?.toIso8601String(),
        "date_created_gmt": dateCreatedGmt?.toIso8601String(),
        "date_modified": dateModified?.toIso8601String(),
        "date_modified_gmt": dateModifiedGmt?.toIso8601String(),
        "src": src,
        "name": name,
        "alt": alt,
      };
}

class ProductDataMetaDatum {
  int? id;
  String? key;
  dynamic value;

  ProductDataMetaDatum({
    this.id,
    this.key,
    this.value,
  });

  ProductDataMetaDatum copyWith({
    int? id,
    String? key,
    dynamic value,
  }) =>
      ProductDataMetaDatum(
        id: id ?? this.id,
        key: key ?? this.key,
        value: value ?? this.value,
      );

  factory ProductDataMetaDatum.fromJson(Map<String, dynamic> json) =>
      ProductDataMetaDatum(
        id: json["id"],
        key: json["key"],
        value: json["value"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "key": key,
        "value": value,
      };
}

class PurpleValue {
  Max? min;
  Max? max;
  Subscription? subscription;
  bool? identical;

  PurpleValue({
    this.min,
    this.max,
    this.subscription,
    this.identical,
  });

  PurpleValue copyWith({
    Max? min,
    Max? max,
    Subscription? subscription,
    bool? identical,
  }) =>
      PurpleValue(
        min: min ?? this.min,
        max: max ?? this.max,
        subscription: subscription ?? this.subscription,
        identical: identical ?? this.identical,
      );

  factory PurpleValue.fromJson(Map<String, dynamic> json) => PurpleValue(
        min: json["min"] == null ? null : Max.fromJson(json["min"]),
        max: json["max"] == null ? null : Max.fromJson(json["max"]),
        subscription: json["subscription"] == null
            ? null
            : Subscription.fromJson(json["subscription"]),
        identical: json["identical"],
      );

  Map<String, dynamic> toJson() => {
        "min": min?.toJson(),
        "max": max?.toJson(),
        "subscription": subscription?.toJson(),
        "identical": identical,
      };
}

class Max {
  int? variationId;
  int? price;
  int? regularPrice;
  int? salePrice;
  String? period;
  String? interval;

  Max({
    this.variationId,
    this.price,
    this.regularPrice,
    this.salePrice,
    this.period,
    this.interval,
  });

  Max copyWith({
    int? variationId,
    int? price,
    int? regularPrice,
    int? salePrice,
    String? period,
    String? interval,
  }) =>
      Max(
        variationId: variationId ?? this.variationId,
        price: price ?? this.price,
        regularPrice: regularPrice ?? this.regularPrice,
        salePrice: salePrice ?? this.salePrice,
        period: period ?? this.period,
        interval: interval ?? this.interval,
      );

  factory Max.fromJson(Map<String, dynamic> json) => Max(
        variationId: json["variation_id"],
        price: json["price"],
        regularPrice: json["regular_price"],
        salePrice: json["sale_price"],
        period: json["period"],
        interval: json["interval"],
      );

  Map<String, dynamic> toJson() => {
        "variation_id": variationId,
        "price": price,
        "regular_price": regularPrice,
        "sale_price": salePrice,
        "period": period,
        "interval": interval,
      };
}

class Subscription {
  int? signupFee;
  String? trialPeriod;
  int? trialLength;
  int? length;

  Subscription({
    this.signupFee,
    this.trialPeriod,
    this.trialLength,
    this.length,
  });

  Subscription copyWith({
    int? signupFee,
    String? trialPeriod,
    int? trialLength,
    int? length,
  }) =>
      Subscription(
        signupFee: signupFee ?? this.signupFee,
        trialPeriod: trialPeriod ?? this.trialPeriod,
        trialLength: trialLength ?? this.trialLength,
        length: length ?? this.length,
      );

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
        signupFee: json["signup-fee"],
        trialPeriod: json["trial_period"],
        trialLength: json["trial_length"],
        length: json["length"],
      );

  Map<String, dynamic> toJson() => {
        "signup-fee": signupFee,
        "trial_period": trialPeriod,
        "trial_length": trialLength,
        "length": length,
      };
}

class ProductUnits {
  String? weightUnit;
  String? dimensionUnit;

  ProductUnits({
    this.weightUnit,
    this.dimensionUnit,
  });

  ProductUnits copyWith({
    String? weightUnit,
    String? dimensionUnit,
  }) =>
      ProductUnits(
        weightUnit: weightUnit ?? this.weightUnit,
        dimensionUnit: dimensionUnit ?? this.dimensionUnit,
      );

  factory ProductUnits.fromJson(Map<String, dynamic> json) => ProductUnits(
        weightUnit: json["weight_unit"],
        dimensionUnit: json["dimension_unit"],
      );

  Map<String, dynamic> toJson() => {
        "weight_unit": weightUnit,
        "dimension_unit": dimensionUnit,
      };
}

class Store {
  String? vendorId;
  dynamic vendorDisplayName;
  String? vendorShopName;
  String? formattedDisplayName;
  String? storeHideEmail;
  String? storeHidePhone;
  String? storeHideAddress;
  String? storeHideDescription;
  String? storeHidePolicy;
  int? storeProductsPerPage;
  String? vendorEmail;
  String? vendorPhone;
  String? vendorAddress;
  bool? disableVendor;
  String? isStoreOffline;
  String? vendorShopLogo;
  String? vendorBannerType;
  String? vendorBanner;
  String? mobileBanner;
  String? vendorListBannerType;
  String? vendorListBanner;
  String? storeRating;
  String? emailVerified;
  List<VendorAdditionalInfo>? vendorAdditionalInfo;
  String? vendorDescription;
  WcfmProductPolicyData? vendorPolicies;
  StoreTabHeadings? storeTabHeadings;
  int? vendorReviewsCount;
  Settings? settings;
  String? shopUrl;

  Store({
    this.vendorId,
    this.vendorDisplayName,
    this.vendorShopName,
    this.formattedDisplayName,
    this.storeHideEmail,
    this.storeHidePhone,
    this.storeHideAddress,
    this.storeHideDescription,
    this.storeHidePolicy,
    this.storeProductsPerPage,
    this.vendorEmail,
    this.vendorPhone,
    this.vendorAddress,
    this.disableVendor,
    this.isStoreOffline,
    this.vendorShopLogo,
    this.vendorBannerType,
    this.vendorBanner,
    this.mobileBanner,
    this.vendorListBannerType,
    this.vendorListBanner,
    this.storeRating,
    this.emailVerified,
    this.vendorAdditionalInfo,
    this.vendorDescription,
    this.vendorPolicies,
    this.storeTabHeadings,
    this.vendorReviewsCount,
    this.settings,
    this.shopUrl,
  });

  Store copyWith({
    String? vendorId,
    dynamic vendorDisplayName,
    String? vendorShopName,
    String? formattedDisplayName,
    String? storeHideEmail,
    String? storeHidePhone,
    String? storeHideAddress,
    String? storeHideDescription,
    String? storeHidePolicy,
    int? storeProductsPerPage,
    String? vendorEmail,
    String? vendorPhone,
    String? vendorAddress,
    bool? disableVendor,
    String? isStoreOffline,
    String? vendorShopLogo,
    String? vendorBannerType,
    String? vendorBanner,
    String? mobileBanner,
    String? vendorListBannerType,
    String? vendorListBanner,
    String? storeRating,
    String? emailVerified,
    List<VendorAdditionalInfo>? vendorAdditionalInfo,
    String? vendorDescription,
    WcfmProductPolicyData? vendorPolicies,
    StoreTabHeadings? storeTabHeadings,
    int? vendorReviewsCount,
    Settings? settings,
    String? shopUrl,
  }) =>
      Store(
        vendorId: vendorId ?? this.vendorId,
        vendorDisplayName: vendorDisplayName ?? this.vendorDisplayName,
        vendorShopName: vendorShopName ?? this.vendorShopName,
        formattedDisplayName: formattedDisplayName ?? this.formattedDisplayName,
        storeHideEmail: storeHideEmail ?? this.storeHideEmail,
        storeHidePhone: storeHidePhone ?? this.storeHidePhone,
        storeHideAddress: storeHideAddress ?? this.storeHideAddress,
        storeHideDescription: storeHideDescription ?? this.storeHideDescription,
        storeHidePolicy: storeHidePolicy ?? this.storeHidePolicy,
        storeProductsPerPage: storeProductsPerPage ?? this.storeProductsPerPage,
        vendorEmail: vendorEmail ?? this.vendorEmail,
        vendorPhone: vendorPhone ?? this.vendorPhone,
        vendorAddress: vendorAddress ?? this.vendorAddress,
        disableVendor: disableVendor ?? this.disableVendor,
        isStoreOffline: isStoreOffline ?? this.isStoreOffline,
        vendorShopLogo: vendorShopLogo ?? this.vendorShopLogo,
        vendorBannerType: vendorBannerType ?? this.vendorBannerType,
        vendorBanner: vendorBanner ?? this.vendorBanner,
        mobileBanner: mobileBanner ?? this.mobileBanner,
        vendorListBannerType: vendorListBannerType ?? this.vendorListBannerType,
        vendorListBanner: vendorListBanner ?? this.vendorListBanner,
        storeRating: storeRating ?? this.storeRating,
        emailVerified: emailVerified ?? this.emailVerified,
        vendorAdditionalInfo: vendorAdditionalInfo ?? this.vendorAdditionalInfo,
        vendorDescription: vendorDescription ?? this.vendorDescription,
        vendorPolicies: vendorPolicies ?? this.vendorPolicies,
        storeTabHeadings: storeTabHeadings ?? this.storeTabHeadings,
        vendorReviewsCount: vendorReviewsCount ?? this.vendorReviewsCount,
        settings: settings ?? this.settings,
        shopUrl: shopUrl ?? this.shopUrl,
      );

  factory Store.fromJson(Map<String, dynamic> json) => Store(
        vendorId: json["vendor_id"],
        vendorDisplayName: json["vendor_display_name"],
        vendorShopName: json["vendor_shop_name"],
        formattedDisplayName: json["formatted_display_name"],
        storeHideEmail: json["store_hide_email"],
        storeHidePhone: json["store_hide_phone"],
        storeHideAddress: json["store_hide_address"],
        storeHideDescription: json["store_hide_description"],
        storeHidePolicy: json["store_hide_policy"],
        storeProductsPerPage: json["store_products_per_page"],
        vendorEmail: json["vendor_email"],
        vendorPhone: json["vendor_phone"],
        vendorAddress: json["vendor_address"],
        disableVendor: json["disable_vendor"],
        isStoreOffline: json["is_store_offline"],
        vendorShopLogo: json["vendor_shop_logo"],
        vendorBannerType: json["vendor_banner_type"],
        vendorBanner: json["vendor_banner"],
        mobileBanner: json["mobile_banner"],
        vendorListBannerType: json["vendor_list_banner_type"],
        vendorListBanner: json["vendor_list_banner"],
        storeRating: json["store_rating"],
        emailVerified: json["email_verified"],
        vendorAdditionalInfo: json["vendor_additional_info"] == null
            ? []
            : List<VendorAdditionalInfo>.from(json["vendor_additional_info"]!
                .map((x) => VendorAdditionalInfo.fromJson(x))),
        vendorDescription: json["vendor_description"],
        vendorPolicies: json["vendor_policies"] == null
            ? null
            : WcfmProductPolicyData.fromJson(json["vendor_policies"]),
        storeTabHeadings: json["store_tab_headings"] == null
            ? null
            : StoreTabHeadings.fromJson(json["store_tab_headings"]),
        vendorReviewsCount: json["vendor_reviews_count"],
        settings: json["settings"] == null
            ? null
            : Settings.fromJson(json["settings"]),
        shopUrl: json["shop_url"],
      );

  Map<String, dynamic> toJson() => {
        "vendor_id": vendorId,
        "vendor_display_name": vendorDisplayName,
        "vendor_shop_name": vendorShopName,
        "formatted_display_name": formattedDisplayName,
        "store_hide_email": storeHideEmail,
        "store_hide_phone": storeHidePhone,
        "store_hide_address": storeHideAddress,
        "store_hide_description": storeHideDescription,
        "store_hide_policy": storeHidePolicy,
        "store_products_per_page": storeProductsPerPage,
        "vendor_email": vendorEmail,
        "vendor_phone": vendorPhone,
        "vendor_address": vendorAddress,
        "disable_vendor": disableVendor,
        "is_store_offline": isStoreOffline,
        "vendor_shop_logo": vendorShopLogo,
        "vendor_banner_type": vendorBannerType,
        "vendor_banner": vendorBanner,
        "mobile_banner": mobileBanner,
        "vendor_list_banner_type": vendorListBannerType,
        "vendor_list_banner": vendorListBanner,
        "store_rating": storeRating,
        "email_verified": emailVerified,
        "vendor_additional_info": vendorAdditionalInfo == null
            ? []
            : List<dynamic>.from(vendorAdditionalInfo!.map((x) => x.toJson())),
        "vendor_description": vendorDescription,
        "vendor_policies": vendorPolicies?.toJson(),
        "store_tab_headings": storeTabHeadings?.toJson(),
        "vendor_reviews_count": vendorReviewsCount,
        "settings": settings?.toJson(),
        "shop_url": shopUrl,
      };
}

class Settings {
  String? userName;
  String? userEmail;
  String? firstName;
  String? lastName;
  String? storeName;
  String? storeSlug;
  String? storeEmail;
  String? phone;
  String? vendorId;
  String? gravatar;
  String? bannerType;
  String? banner;
  String? bannerVideo;
  List<BannerSlider>? bannerSlider;
  String? mobileBanner;
  String? listBannerType;
  String? listBanner;
  String? listBannerVideo;
  String? shopDescription;
  String? storeNamePosition;
  String? storePpp;
  WcfmDeliveryTime? wcfmDeliveryTime;
  Commission? commission;
  Withdrawal? withdrawal;
  Payment? payment;
  WcfmStoreHours? wcfmStoreHours;
  String? wcfmVacationModeType;
  String? wcfmVacationStartDate;
  String? wcfmVacationEndDate;
  String? wcfmVacationModeMsg;
  StoreSeo? storeSeo;
  Social? social;
  String? wcfmPolicyTabTitle;
  String? wcfmShippingPolicy;
  String? wcfmRefundPolicy;
  String? wcfmCancellationPolicy;
  CustomerSupport? customerSupport;
  String? bfirstName;
  String? blastName;
  String? bphone;
  String? baddr1;
  String? baddr2;
  String? bcountry;
  String? bcity;
  String? bstate;
  String? bzip;
  String? sfirstName;
  String? slastName;
  String? saddr1;
  String? saddr2;
  String? scountry;
  String? scity;
  String? sstate;
  String? szip;
  String? wcfmVacationMode;
  String? wcfmDisableVacationPurchase;
  Address? address;
  Geolocation? geolocation;
  String? findAddress;
  String? storeLocation;
  String? storeLat;
  String? storeLng;
  String? storeHideEmail;
  String? storeHidePhone;
  String? storeHideAddress;
  String? storeHideMap;
  String? storeHideDescription;
  String? storeHidePolicy;

  Settings({
    this.userName,
    this.userEmail,
    this.firstName,
    this.lastName,
    this.storeName,
    this.storeSlug,
    this.storeEmail,
    this.phone,
    this.vendorId,
    this.gravatar,
    this.bannerType,
    this.banner,
    this.bannerVideo,
    this.bannerSlider,
    this.mobileBanner,
    this.listBannerType,
    this.listBanner,
    this.listBannerVideo,
    this.shopDescription,
    this.storeNamePosition,
    this.storePpp,
    this.wcfmDeliveryTime,
    this.commission,
    this.withdrawal,
    this.payment,
    this.wcfmStoreHours,
    this.wcfmVacationModeType,
    this.wcfmVacationStartDate,
    this.wcfmVacationEndDate,
    this.wcfmVacationModeMsg,
    this.storeSeo,
    this.social,
    this.wcfmPolicyTabTitle,
    this.wcfmShippingPolicy,
    this.wcfmRefundPolicy,
    this.wcfmCancellationPolicy,
    this.customerSupport,
    this.bfirstName,
    this.blastName,
    this.bphone,
    this.baddr1,
    this.baddr2,
    this.bcountry,
    this.bcity,
    this.bstate,
    this.bzip,
    this.sfirstName,
    this.slastName,
    this.saddr1,
    this.saddr2,
    this.scountry,
    this.scity,
    this.sstate,
    this.szip,
    this.wcfmVacationMode,
    this.wcfmDisableVacationPurchase,
    this.address,
    this.geolocation,
    this.findAddress,
    this.storeLocation,
    this.storeLat,
    this.storeLng,
    this.storeHideEmail,
    this.storeHidePhone,
    this.storeHideAddress,
    this.storeHideMap,
    this.storeHideDescription,
    this.storeHidePolicy,
  });

  Settings copyWith({
    String? userName,
    String? userEmail,
    String? firstName,
    String? lastName,
    String? storeName,
    String? storeSlug,
    String? storeEmail,
    String? phone,
    String? vendorId,
    String? gravatar,
    String? bannerType,
    String? banner,
    String? bannerVideo,
    List<BannerSlider>? bannerSlider,
    String? mobileBanner,
    String? listBannerType,
    String? listBanner,
    String? listBannerVideo,
    String? shopDescription,
    String? storeNamePosition,
    String? storePpp,
    WcfmDeliveryTime? wcfmDeliveryTime,
    Commission? commission,
    Withdrawal? withdrawal,
    Payment? payment,
    WcfmStoreHours? wcfmStoreHours,
    String? wcfmVacationModeType,
    String? wcfmVacationStartDate,
    String? wcfmVacationEndDate,
    String? wcfmVacationModeMsg,
    StoreSeo? storeSeo,
    Social? social,
    String? wcfmPolicyTabTitle,
    String? wcfmShippingPolicy,
    String? wcfmRefundPolicy,
    String? wcfmCancellationPolicy,
    CustomerSupport? customerSupport,
    String? bfirstName,
    String? blastName,
    String? bphone,
    String? baddr1,
    String? baddr2,
    String? bcountry,
    String? bcity,
    String? bstate,
    String? bzip,
    String? sfirstName,
    String? slastName,
    String? saddr1,
    String? saddr2,
    String? scountry,
    String? scity,
    String? sstate,
    String? szip,
    String? wcfmVacationMode,
    String? wcfmDisableVacationPurchase,
    Address? address,
    Geolocation? geolocation,
    String? findAddress,
    String? storeLocation,
    String? storeLat,
    String? storeLng,
    String? storeHideEmail,
    String? storeHidePhone,
    String? storeHideAddress,
    String? storeHideMap,
    String? storeHideDescription,
    String? storeHidePolicy,
  }) =>
      Settings(
        userName: userName ?? this.userName,
        userEmail: userEmail ?? this.userEmail,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        storeName: storeName ?? this.storeName,
        storeSlug: storeSlug ?? this.storeSlug,
        storeEmail: storeEmail ?? this.storeEmail,
        phone: phone ?? this.phone,
        vendorId: vendorId ?? this.vendorId,
        gravatar: gravatar ?? this.gravatar,
        bannerType: bannerType ?? this.bannerType,
        banner: banner ?? this.banner,
        bannerVideo: bannerVideo ?? this.bannerVideo,
        bannerSlider: bannerSlider ?? this.bannerSlider,
        mobileBanner: mobileBanner ?? this.mobileBanner,
        listBannerType: listBannerType ?? this.listBannerType,
        listBanner: listBanner ?? this.listBanner,
        listBannerVideo: listBannerVideo ?? this.listBannerVideo,
        shopDescription: shopDescription ?? this.shopDescription,
        storeNamePosition: storeNamePosition ?? this.storeNamePosition,
        storePpp: storePpp ?? this.storePpp,
        wcfmDeliveryTime: wcfmDeliveryTime ?? this.wcfmDeliveryTime,
        commission: commission ?? this.commission,
        withdrawal: withdrawal ?? this.withdrawal,
        payment: payment ?? this.payment,
        wcfmStoreHours: wcfmStoreHours ?? this.wcfmStoreHours,
        wcfmVacationModeType: wcfmVacationModeType ?? this.wcfmVacationModeType,
        wcfmVacationStartDate:
            wcfmVacationStartDate ?? this.wcfmVacationStartDate,
        wcfmVacationEndDate: wcfmVacationEndDate ?? this.wcfmVacationEndDate,
        wcfmVacationModeMsg: wcfmVacationModeMsg ?? this.wcfmVacationModeMsg,
        storeSeo: storeSeo ?? this.storeSeo,
        social: social ?? this.social,
        wcfmPolicyTabTitle: wcfmPolicyTabTitle ?? this.wcfmPolicyTabTitle,
        wcfmShippingPolicy: wcfmShippingPolicy ?? this.wcfmShippingPolicy,
        wcfmRefundPolicy: wcfmRefundPolicy ?? this.wcfmRefundPolicy,
        wcfmCancellationPolicy:
            wcfmCancellationPolicy ?? this.wcfmCancellationPolicy,
        customerSupport: customerSupport ?? this.customerSupport,
        bfirstName: bfirstName ?? this.bfirstName,
        blastName: blastName ?? this.blastName,
        bphone: bphone ?? this.bphone,
        baddr1: baddr1 ?? this.baddr1,
        baddr2: baddr2 ?? this.baddr2,
        bcountry: bcountry ?? this.bcountry,
        bcity: bcity ?? this.bcity,
        bstate: bstate ?? this.bstate,
        bzip: bzip ?? this.bzip,
        sfirstName: sfirstName ?? this.sfirstName,
        slastName: slastName ?? this.slastName,
        saddr1: saddr1 ?? this.saddr1,
        saddr2: saddr2 ?? this.saddr2,
        scountry: scountry ?? this.scountry,
        scity: scity ?? this.scity,
        sstate: sstate ?? this.sstate,
        szip: szip ?? this.szip,
        wcfmVacationMode: wcfmVacationMode ?? this.wcfmVacationMode,
        wcfmDisableVacationPurchase:
            wcfmDisableVacationPurchase ?? this.wcfmDisableVacationPurchase,
        address: address ?? this.address,
        geolocation: geolocation ?? this.geolocation,
        findAddress: findAddress ?? this.findAddress,
        storeLocation: storeLocation ?? this.storeLocation,
        storeLat: storeLat ?? this.storeLat,
        storeLng: storeLng ?? this.storeLng,
        storeHideEmail: storeHideEmail ?? this.storeHideEmail,
        storeHidePhone: storeHidePhone ?? this.storeHidePhone,
        storeHideAddress: storeHideAddress ?? this.storeHideAddress,
        storeHideMap: storeHideMap ?? this.storeHideMap,
        storeHideDescription: storeHideDescription ?? this.storeHideDescription,
        storeHidePolicy: storeHidePolicy ?? this.storeHidePolicy,
      );

  factory Settings.fromJson(Map<String, dynamic> json) => Settings(
        userName: json["user_name"],
        userEmail: json["user_email"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        storeName: json["store_name"],
        storeSlug: json["store_slug"],
        storeEmail: json["store_email"],
        phone: json["phone"],
        vendorId: json["vendor_id"],
        gravatar: json["gravatar"],
        bannerType: json["banner_type"],
        banner: json["banner"],
        bannerVideo: json["banner_video"],
        bannerSlider: json["banner_slider"] == null
            ? []
            : List<BannerSlider>.from(
                json["banner_slider"]!.map((x) => BannerSlider.fromJson(x))),
        mobileBanner: json["mobile_banner"],
        listBannerType: json["list_banner_type"],
        listBanner: json["list_banner"],
        listBannerVideo: json["list_banner_video"],
        shopDescription: json["shop_description"],
        storeNamePosition: json["store_name_position"],
        storePpp: json["store_ppp"],
        wcfmDeliveryTime: json["wcfm_delivery_time"] == null
            ? null
            : WcfmDeliveryTime.fromJson(json["wcfm_delivery_time"]),
        commission: json["commission"] == null
            ? null
            : Commission.fromJson(json["commission"]),
        withdrawal: json["withdrawal"] == null
            ? null
            : Withdrawal.fromJson(json["withdrawal"]),
        payment:
            json["payment"] == null ? null : Payment.fromJson(json["payment"]),
        wcfmStoreHours: json["wcfm_store_hours"] == null
            ? null
            : WcfmStoreHours.fromJson(json["wcfm_store_hours"]),
        wcfmVacationModeType: json["wcfm_vacation_mode_type"],
        wcfmVacationStartDate: json["wcfm_vacation_start_date"],
        wcfmVacationEndDate: json["wcfm_vacation_end_date"],
        wcfmVacationModeMsg: json["wcfm_vacation_mode_msg"],
        storeSeo: json["store_seo"] == null
            ? null
            : StoreSeo.fromJson(json["store_seo"]),
        social: json["social"] == null ? null : Social.fromJson(json["social"]),
        wcfmPolicyTabTitle: json["wcfm_policy_tab_title"],
        wcfmShippingPolicy: json["wcfm_shipping_policy"],
        wcfmRefundPolicy: json["wcfm_refund_policy"],
        wcfmCancellationPolicy: json["wcfm_cancellation_policy"],
        customerSupport: json["customer_support"] == null
            ? null
            : CustomerSupport.fromJson(json["customer_support"]),
        bfirstName: json["bfirst_name"],
        blastName: json["blast_name"],
        bphone: json["bphone"],
        baddr1: json["baddr_1"],
        baddr2: json["baddr_2"],
        bcountry: json["bcountry"],
        bcity: json["bcity"],
        bstate: json["bstate"],
        bzip: json["bzip"],
        sfirstName: json["sfirst_name"],
        slastName: json["slast_name"],
        saddr1: json["saddr_1"],
        saddr2: json["saddr_2"],
        scountry: json["scountry"],
        scity: json["scity"],
        sstate: json["sstate"],
        szip: json["szip"],
        wcfmVacationMode: json["wcfm_vacation_mode"],
        wcfmDisableVacationPurchase: json["wcfm_disable_vacation_purchase"],
        address:
            json["address"] == null ? null : Address.fromJson(json["address"]),
        geolocation: json["geolocation"] == null
            ? null
            : Geolocation.fromJson(json["geolocation"]),
        findAddress: json["find_address"],
        storeLocation: json["store_location"],
        storeLat: json["store_lat"],
        storeLng: json["store_lng"],
        storeHideEmail: json["store_hide_email"],
        storeHidePhone: json["store_hide_phone"],
        storeHideAddress: json["store_hide_address"],
        storeHideMap: json["store_hide_map"],
        storeHideDescription: json["store_hide_description"],
        storeHidePolicy: json["store_hide_policy"],
      );

  Map<String, dynamic> toJson() => {
        "user_name": userName,
        "user_email": userEmail,
        "first_name": firstName,
        "last_name": lastName,
        "store_name": storeName,
        "store_slug": storeSlug,
        "store_email": storeEmail,
        "phone": phone,
        "vendor_id": vendorId,
        "gravatar": gravatar,
        "banner_type": bannerType,
        "banner": banner,
        "banner_video": bannerVideo,
        "banner_slider": bannerSlider == null
            ? []
            : List<dynamic>.from(bannerSlider!.map((x) => x.toJson())),
        "mobile_banner": mobileBanner,
        "list_banner_type": listBannerType,
        "list_banner": listBanner,
        "list_banner_video": listBannerVideo,
        "shop_description": shopDescription,
        "store_name_position": storeNamePosition,
        "store_ppp": storePpp,
        "wcfm_delivery_time": wcfmDeliveryTime?.toJson(),
        "commission": commission?.toJson(),
        "withdrawal": withdrawal?.toJson(),
        "payment": payment?.toJson(),
        "wcfm_store_hours": wcfmStoreHours?.toJson(),
        "wcfm_vacation_mode_type": wcfmVacationModeType,
        "wcfm_vacation_start_date": wcfmVacationStartDate,
        "wcfm_vacation_end_date": wcfmVacationEndDate,
        "wcfm_vacation_mode_msg": wcfmVacationModeMsg,
        "store_seo": storeSeo?.toJson(),
        "social": social?.toJson(),
        "wcfm_policy_tab_title": wcfmPolicyTabTitle,
        "wcfm_shipping_policy": wcfmShippingPolicy,
        "wcfm_refund_policy": wcfmRefundPolicy,
        "wcfm_cancellation_policy": wcfmCancellationPolicy,
        "customer_support": customerSupport?.toJson(),
        "bfirst_name": bfirstName,
        "blast_name": blastName,
        "bphone": bphone,
        "baddr_1": baddr1,
        "baddr_2": baddr2,
        "bcountry": bcountry,
        "bcity": bcity,
        "bstate": bstate,
        "bzip": bzip,
        "sfirst_name": sfirstName,
        "slast_name": slastName,
        "saddr_1": saddr1,
        "saddr_2": saddr2,
        "scountry": scountry,
        "scity": scity,
        "sstate": sstate,
        "szip": szip,
        "wcfm_vacation_mode": wcfmVacationMode,
        "wcfm_disable_vacation_purchase": wcfmDisableVacationPurchase,
        "address": address?.toJson(),
        "geolocation": geolocation?.toJson(),
        "find_address": findAddress,
        "store_location": storeLocation,
        "store_lat": storeLat,
        "store_lng": storeLng,
        "store_hide_email": storeHideEmail,
        "store_hide_phone": storeHidePhone,
        "store_hide_address": storeHideAddress,
        "store_hide_map": storeHideMap,
        "store_hide_description": storeHideDescription,
        "store_hide_policy": storeHidePolicy,
      };
}

class Address {
  String? street1;
  String? street2;
  String? city;
  String? zip;
  String? country;
  String? state;

  Address({
    this.street1,
    this.street2,
    this.city,
    this.zip,
    this.country,
    this.state,
  });

  Address copyWith({
    String? street1,
    String? street2,
    String? city,
    String? zip,
    String? country,
    String? state,
  }) =>
      Address(
        street1: street1 ?? this.street1,
        street2: street2 ?? this.street2,
        city: city ?? this.city,
        zip: zip ?? this.zip,
        country: country ?? this.country,
        state: state ?? this.state,
      );

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        street1: json["street_1"],
        street2: json["street_2"],
        city: json["city"],
        zip: json["zip"],
        country: json["country"],
        state: json["state"],
      );

  Map<String, dynamic> toJson() => {
        "street_1": street1,
        "street_2": street2,
        "city": city,
        "zip": zip,
        "country": country,
        "state": state,
      };
}

class BannerSlider {
  String? image;
  String? link;

  BannerSlider({
    this.image,
    this.link,
  });

  BannerSlider copyWith({
    String? image,
    String? link,
  }) =>
      BannerSlider(
        image: image ?? this.image,
        link: link ?? this.link,
      );

  factory BannerSlider.fromJson(Map<String, dynamic> json) => BannerSlider(
        image: json["image"],
        link: json["link"],
      );

  Map<String, dynamic> toJson() => {
        "image": image,
        "link": link,
      };
}

class Commission {
  String? commissionMode;
  String? commissionPercent;
  String? commissionFixed;
  List<CommissionBy>? commissionBySales;
  List<CommissionBy>? commissionByProducts;
  List<CommissionBy>? commissionByQuantity;
  String? taxName;
  String? taxPercent;

  Commission({
    this.commissionMode,
    this.commissionPercent,
    this.commissionFixed,
    this.commissionBySales,
    this.commissionByProducts,
    this.commissionByQuantity,
    this.taxName,
    this.taxPercent,
  });

  Commission copyWith({
    String? commissionMode,
    String? commissionPercent,
    String? commissionFixed,
    List<CommissionBy>? commissionBySales,
    List<CommissionBy>? commissionByProducts,
    List<CommissionBy>? commissionByQuantity,
    String? taxName,
    String? taxPercent,
  }) =>
      Commission(
        commissionMode: commissionMode ?? this.commissionMode,
        commissionPercent: commissionPercent ?? this.commissionPercent,
        commissionFixed: commissionFixed ?? this.commissionFixed,
        commissionBySales: commissionBySales ?? this.commissionBySales,
        commissionByProducts: commissionByProducts ?? this.commissionByProducts,
        commissionByQuantity: commissionByQuantity ?? this.commissionByQuantity,
        taxName: taxName ?? this.taxName,
        taxPercent: taxPercent ?? this.taxPercent,
      );

  factory Commission.fromJson(Map<String, dynamic> json) => Commission(
        commissionMode: json["commission_mode"],
        commissionPercent: json["commission_percent"],
        commissionFixed: json["commission_fixed"],
        commissionBySales: json["commission_by_sales"] == null
            ? []
            : List<CommissionBy>.from(json["commission_by_sales"]!
                .map((x) => CommissionBy.fromJson(x))),
        commissionByProducts: json["commission_by_products"] == null
            ? []
            : List<CommissionBy>.from(json["commission_by_products"]!
                .map((x) => CommissionBy.fromJson(x))),
        commissionByQuantity: json["commission_by_quantity"] == null
            ? []
            : List<CommissionBy>.from(json["commission_by_quantity"]!
                .map((x) => CommissionBy.fromJson(x))),
        taxName: json["tax_name"],
        taxPercent: json["tax_percent"],
      );

  Map<String, dynamic> toJson() => {
        "commission_mode": commissionMode,
        "commission_percent": commissionPercent,
        "commission_fixed": commissionFixed,
        "commission_by_sales": commissionBySales == null
            ? []
            : List<dynamic>.from(commissionBySales!.map((x) => x.toJson())),
        "commission_by_products": commissionByProducts == null
            ? []
            : List<dynamic>.from(commissionByProducts!.map((x) => x.toJson())),
        "commission_by_quantity": commissionByQuantity == null
            ? []
            : List<dynamic>.from(commissionByQuantity!.map((x) => x.toJson())),
        "tax_name": taxName,
        "tax_percent": taxPercent,
      };
}

class CommissionBy {
  String? cost;
  String? rule;
  String? type;
  String? commission;
  String? commissionFixed;
  String? quantity;
  String? sales;

  CommissionBy({
    this.cost,
    this.rule,
    this.type,
    this.commission,
    this.commissionFixed,
    this.quantity,
    this.sales,
  });

  CommissionBy copyWith({
    String? cost,
    String? rule,
    String? type,
    String? commission,
    String? commissionFixed,
    String? quantity,
    String? sales,
  }) =>
      CommissionBy(
        cost: cost ?? this.cost,
        rule: rule ?? this.rule,
        type: type ?? this.type,
        commission: commission ?? this.commission,
        commissionFixed: commissionFixed ?? this.commissionFixed,
        quantity: quantity ?? this.quantity,
        sales: sales ?? this.sales,
      );

  factory CommissionBy.fromJson(Map<String, dynamic> json) => CommissionBy(
        cost: json["cost"],
        rule: json["rule"],
        type: json["type"],
        commission: json["commission"],
        commissionFixed: json["commission_fixed"],
        quantity: json["quantity"],
        sales: json["sales"],
      );

  Map<String, dynamic> toJson() => {
        "cost": cost,
        "rule": rule,
        "type": type,
        "commission": commission,
        "commission_fixed": commissionFixed,
        "quantity": quantity,
        "sales": sales,
      };
}

class CustomerSupport {
  String? phone;
  String? email;
  String? address1;
  String? address2;
  String? country;
  String? city;
  String? state;
  String? zip;

  CustomerSupport({
    this.phone,
    this.email,
    this.address1,
    this.address2,
    this.country,
    this.city,
    this.state,
    this.zip,
  });

  CustomerSupport copyWith({
    String? phone,
    String? email,
    String? address1,
    String? address2,
    String? country,
    String? city,
    String? state,
    String? zip,
  }) =>
      CustomerSupport(
        phone: phone ?? this.phone,
        email: email ?? this.email,
        address1: address1 ?? this.address1,
        address2: address2 ?? this.address2,
        country: country ?? this.country,
        city: city ?? this.city,
        state: state ?? this.state,
        zip: zip ?? this.zip,
      );

  factory CustomerSupport.fromJson(Map<String, dynamic> json) =>
      CustomerSupport(
        phone: json["phone"],
        email: json["email"],
        address1: json["address1"],
        address2: json["address2"],
        country: json["country"],
        city: json["city"],
        state: json["state"],
        zip: json["zip"],
      );

  Map<String, dynamic> toJson() => {
        "phone": phone,
        "email": email,
        "address1": address1,
        "address2": address2,
        "country": country,
        "city": city,
        "state": state,
        "zip": zip,
      };
}

class Geolocation {
  String? storeLocation;
  String? storeLat;
  String? storeLng;

  Geolocation({
    this.storeLocation,
    this.storeLat,
    this.storeLng,
  });

  Geolocation copyWith({
    String? storeLocation,
    String? storeLat,
    String? storeLng,
  }) =>
      Geolocation(
        storeLocation: storeLocation ?? this.storeLocation,
        storeLat: storeLat ?? this.storeLat,
        storeLng: storeLng ?? this.storeLng,
      );

  factory Geolocation.fromJson(Map<String, dynamic> json) => Geolocation(
        storeLocation: json["store_location"],
        storeLat: json["store_lat"],
        storeLng: json["store_lng"],
      );

  Map<String, dynamic> toJson() => {
        "store_location": storeLocation,
        "store_lat": storeLat,
        "store_lng": storeLng,
      };
}

class Payment {
  String? method;
  Paypal? paypal;
  Paypal? skrill;
  Bank? bank;

  Payment({
    this.method,
    this.paypal,
    this.skrill,
    this.bank,
  });

  Payment copyWith({
    String? method,
    Paypal? paypal,
    Paypal? skrill,
    Bank? bank,
  }) =>
      Payment(
        method: method ?? this.method,
        paypal: paypal ?? this.paypal,
        skrill: skrill ?? this.skrill,
        bank: bank ?? this.bank,
      );

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        method: json["method"],
        paypal: json["paypal"] == null ? null : Paypal.fromJson(json["paypal"]),
        skrill: json["skrill"] == null ? null : Paypal.fromJson(json["skrill"]),
        bank: json["bank"] == null ? null : Bank.fromJson(json["bank"]),
      );

  Map<String, dynamic> toJson() => {
        "method": method,
        "paypal": paypal?.toJson(),
        "skrill": skrill?.toJson(),
        "bank": bank?.toJson(),
      };
}

class Bank {
  String? acName;
  String? acNumber;
  String? bankName;
  String? bankAddr;
  String? routingNumber;
  String? iban;
  String? swift;
  String? ifsc;

  Bank({
    this.acName,
    this.acNumber,
    this.bankName,
    this.bankAddr,
    this.routingNumber,
    this.iban,
    this.swift,
    this.ifsc,
  });

  Bank copyWith({
    String? acName,
    String? acNumber,
    String? bankName,
    String? bankAddr,
    String? routingNumber,
    String? iban,
    String? swift,
    String? ifsc,
  }) =>
      Bank(
        acName: acName ?? this.acName,
        acNumber: acNumber ?? this.acNumber,
        bankName: bankName ?? this.bankName,
        bankAddr: bankAddr ?? this.bankAddr,
        routingNumber: routingNumber ?? this.routingNumber,
        iban: iban ?? this.iban,
        swift: swift ?? this.swift,
        ifsc: ifsc ?? this.ifsc,
      );

  factory Bank.fromJson(Map<String, dynamic> json) => Bank(
        acName: json["ac_name"],
        acNumber: json["ac_number"],
        bankName: json["bank_name"],
        bankAddr: json["bank_addr"],
        routingNumber: json["routing_number"],
        iban: json["iban"],
        swift: json["swift"],
        ifsc: json["ifsc"],
      );

  Map<String, dynamic> toJson() => {
        "ac_name": acName,
        "ac_number": acNumber,
        "bank_name": bankName,
        "bank_addr": bankAddr,
        "routing_number": routingNumber,
        "iban": iban,
        "swift": swift,
        "ifsc": ifsc,
      };
}

class Paypal {
  String? email;

  Paypal({
    this.email,
  });

  Paypal copyWith({
    String? email,
  }) =>
      Paypal(
        email: email ?? this.email,
      );

  factory Paypal.fromJson(Map<String, dynamic> json) => Paypal(
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "email": email,
      };
}

class Social {
  String? twitter;
  String? fb;
  String? instagram;
  String? youtube;
  String? linkedin;
  String? gplus;
  String? snapchat;
  String? pinterest;

  Social({
    this.twitter,
    this.fb,
    this.instagram,
    this.youtube,
    this.linkedin,
    this.gplus,
    this.snapchat,
    this.pinterest,
  });

  Social copyWith({
    String? twitter,
    String? fb,
    String? instagram,
    String? youtube,
    String? linkedin,
    String? gplus,
    String? snapchat,
    String? pinterest,
  }) =>
      Social(
        twitter: twitter ?? this.twitter,
        fb: fb ?? this.fb,
        instagram: instagram ?? this.instagram,
        youtube: youtube ?? this.youtube,
        linkedin: linkedin ?? this.linkedin,
        gplus: gplus ?? this.gplus,
        snapchat: snapchat ?? this.snapchat,
        pinterest: pinterest ?? this.pinterest,
      );

  factory Social.fromJson(Map<String, dynamic> json) => Social(
        twitter: json["twitter"],
        fb: json["fb"],
        instagram: json["instagram"],
        youtube: json["youtube"],
        linkedin: json["linkedin"],
        gplus: json["gplus"],
        snapchat: json["snapchat"],
        pinterest: json["pinterest"],
      );

  Map<String, dynamic> toJson() => {
        "twitter": twitter,
        "fb": fb,
        "instagram": instagram,
        "youtube": youtube,
        "linkedin": linkedin,
        "gplus": gplus,
        "snapchat": snapchat,
        "pinterest": pinterest,
      };
}

class StoreSeo {
  String? wcfmmpSeoMetaTitle;
  String? wcfmmpSeoMetaDesc;
  String? wcfmmpSeoMetaKeywords;
  String? wcfmmpSeoOgTitle;
  String? wcfmmpSeoOgDesc;
  String? wcfmmpSeoOgImage;
  String? wcfmmpSeoTwitterTitle;
  String? wcfmmpSeoTwitterDesc;
  String? wcfmmpSeoTwitterImage;

  StoreSeo({
    this.wcfmmpSeoMetaTitle,
    this.wcfmmpSeoMetaDesc,
    this.wcfmmpSeoMetaKeywords,
    this.wcfmmpSeoOgTitle,
    this.wcfmmpSeoOgDesc,
    this.wcfmmpSeoOgImage,
    this.wcfmmpSeoTwitterTitle,
    this.wcfmmpSeoTwitterDesc,
    this.wcfmmpSeoTwitterImage,
  });

  StoreSeo copyWith({
    String? wcfmmpSeoMetaTitle,
    String? wcfmmpSeoMetaDesc,
    String? wcfmmpSeoMetaKeywords,
    String? wcfmmpSeoOgTitle,
    String? wcfmmpSeoOgDesc,
    String? wcfmmpSeoOgImage,
    String? wcfmmpSeoTwitterTitle,
    String? wcfmmpSeoTwitterDesc,
    String? wcfmmpSeoTwitterImage,
  }) =>
      StoreSeo(
        wcfmmpSeoMetaTitle: wcfmmpSeoMetaTitle ?? this.wcfmmpSeoMetaTitle,
        wcfmmpSeoMetaDesc: wcfmmpSeoMetaDesc ?? this.wcfmmpSeoMetaDesc,
        wcfmmpSeoMetaKeywords:
            wcfmmpSeoMetaKeywords ?? this.wcfmmpSeoMetaKeywords,
        wcfmmpSeoOgTitle: wcfmmpSeoOgTitle ?? this.wcfmmpSeoOgTitle,
        wcfmmpSeoOgDesc: wcfmmpSeoOgDesc ?? this.wcfmmpSeoOgDesc,
        wcfmmpSeoOgImage: wcfmmpSeoOgImage ?? this.wcfmmpSeoOgImage,
        wcfmmpSeoTwitterTitle:
            wcfmmpSeoTwitterTitle ?? this.wcfmmpSeoTwitterTitle,
        wcfmmpSeoTwitterDesc: wcfmmpSeoTwitterDesc ?? this.wcfmmpSeoTwitterDesc,
        wcfmmpSeoTwitterImage:
            wcfmmpSeoTwitterImage ?? this.wcfmmpSeoTwitterImage,
      );

  factory StoreSeo.fromJson(Map<String, dynamic> json) => StoreSeo(
        wcfmmpSeoMetaTitle: json["wcfmmp-seo-meta-title"],
        wcfmmpSeoMetaDesc: json["wcfmmp-seo-meta-desc"],
        wcfmmpSeoMetaKeywords: json["wcfmmp-seo-meta-keywords"],
        wcfmmpSeoOgTitle: json["wcfmmp-seo-og-title"],
        wcfmmpSeoOgDesc: json["wcfmmp-seo-og-desc"],
        wcfmmpSeoOgImage: json["wcfmmp-seo-og-image"],
        wcfmmpSeoTwitterTitle: json["wcfmmp-seo-twitter-title"],
        wcfmmpSeoTwitterDesc: json["wcfmmp-seo-twitter-desc"],
        wcfmmpSeoTwitterImage: json["wcfmmp-seo-twitter-image"],
      );

  Map<String, dynamic> toJson() => {
        "wcfmmp-seo-meta-title": wcfmmpSeoMetaTitle,
        "wcfmmp-seo-meta-desc": wcfmmpSeoMetaDesc,
        "wcfmmp-seo-meta-keywords": wcfmmpSeoMetaKeywords,
        "wcfmmp-seo-og-title": wcfmmpSeoOgTitle,
        "wcfmmp-seo-og-desc": wcfmmpSeoOgDesc,
        "wcfmmp-seo-og-image": wcfmmpSeoOgImage,
        "wcfmmp-seo-twitter-title": wcfmmpSeoTwitterTitle,
        "wcfmmp-seo-twitter-desc": wcfmmpSeoTwitterDesc,
        "wcfmmp-seo-twitter-image": wcfmmpSeoTwitterImage,
      };
}

class WcfmDeliveryTime {
  String? startFrom;
  String? endAt;
  String? slotsDuration;
  String? displayFormat;
  List<List<DayTime>>? dayTimes;

  WcfmDeliveryTime({
    this.startFrom,
    this.endAt,
    this.slotsDuration,
    this.displayFormat,
    this.dayTimes,
  });

  WcfmDeliveryTime copyWith({
    String? startFrom,
    String? endAt,
    String? slotsDuration,
    String? displayFormat,
    List<List<DayTime>>? dayTimes,
  }) =>
      WcfmDeliveryTime(
        startFrom: startFrom ?? this.startFrom,
        endAt: endAt ?? this.endAt,
        slotsDuration: slotsDuration ?? this.slotsDuration,
        displayFormat: displayFormat ?? this.displayFormat,
        dayTimes: dayTimes ?? this.dayTimes,
      );

  factory WcfmDeliveryTime.fromJson(Map<String, dynamic> json) =>
      WcfmDeliveryTime(
        startFrom: json["start_from"],
        endAt: json["end_at"],
        slotsDuration: json["slots_duration"],
        displayFormat: json["display_format"],
        dayTimes: json["day_times"] == null
            ? []
            : List<List<DayTime>>.from(json["day_times"]!.map(
                (x) => List<DayTime>.from(x.map((x) => DayTime.fromJson(x))))),
      );

  Map<String, dynamic> toJson() => {
        "start_from": startFrom,
        "end_at": endAt,
        "slots_duration": slotsDuration,
        "display_format": displayFormat,
        "day_times": dayTimes == null
            ? []
            : List<dynamic>.from(dayTimes!
                .map((x) => List<dynamic>.from(x.map((x) => x.toJson())))),
      };
}

class DayTime {
  String? start;
  String? end;

  DayTime({
    this.start,
    this.end,
  });

  DayTime copyWith({
    String? start,
    String? end,
  }) =>
      DayTime(
        start: start ?? this.start,
        end: end ?? this.end,
      );

  factory DayTime.fromJson(Map<String, dynamic> json) => DayTime(
        start: json["start"],
        end: json["end"],
      );

  Map<String, dynamic> toJson() => {
        "start": start,
        "end": end,
      };
}

class WcfmStoreHours {
  List<List<DayTime>>? dayTimes;

  WcfmStoreHours({
    this.dayTimes,
  });

  WcfmStoreHours copyWith({
    List<List<DayTime>>? dayTimes,
  }) =>
      WcfmStoreHours(
        dayTimes: dayTimes ?? this.dayTimes,
      );

  factory WcfmStoreHours.fromJson(Map<String, dynamic> json) => WcfmStoreHours(
        dayTimes: json["day_times"] == null
            ? []
            : List<List<DayTime>>.from(json["day_times"]!.map(
                (x) => List<DayTime>.from(x.map((x) => DayTime.fromJson(x))))),
      );

  Map<String, dynamic> toJson() => {
        "day_times": dayTimes == null
            ? []
            : List<dynamic>.from(dayTimes!
                .map((x) => List<dynamic>.from(x.map((x) => x.toJson())))),
      };
}

class Withdrawal {
  String? transactionMode;
  String? transactionChargeType;
  TransactionCharge? transactionCharge;
  String? withdrawalMode;
  String? withdrawalLimit;
  String? withdrawalThresold;
  String? withdrawalChargeType;
  WithdrawalCharge? withdrawalCharge;

  Withdrawal({
    this.transactionMode,
    this.transactionChargeType,
    this.transactionCharge,
    this.withdrawalMode,
    this.withdrawalLimit,
    this.withdrawalThresold,
    this.withdrawalChargeType,
    this.withdrawalCharge,
  });

  Withdrawal copyWith({
    String? transactionMode,
    String? transactionChargeType,
    TransactionCharge? transactionCharge,
    String? withdrawalMode,
    String? withdrawalLimit,
    String? withdrawalThresold,
    String? withdrawalChargeType,
    WithdrawalCharge? withdrawalCharge,
  }) =>
      Withdrawal(
        transactionMode: transactionMode ?? this.transactionMode,
        transactionChargeType:
            transactionChargeType ?? this.transactionChargeType,
        transactionCharge: transactionCharge ?? this.transactionCharge,
        withdrawalMode: withdrawalMode ?? this.withdrawalMode,
        withdrawalLimit: withdrawalLimit ?? this.withdrawalLimit,
        withdrawalThresold: withdrawalThresold ?? this.withdrawalThresold,
        withdrawalChargeType: withdrawalChargeType ?? this.withdrawalChargeType,
        withdrawalCharge: withdrawalCharge ?? this.withdrawalCharge,
      );

  factory Withdrawal.fromJson(Map<String, dynamic> json) => Withdrawal(
        transactionMode: json["transaction_mode"],
        transactionChargeType: json["transaction_charge_type"],
        transactionCharge: json["transaction_charge"] == null
            ? null
            : TransactionCharge.fromJson(json["transaction_charge"]),
        withdrawalMode: json["withdrawal_mode"],
        withdrawalLimit: json["withdrawal_limit"],
        withdrawalThresold: json["withdrawal_thresold"],
        withdrawalChargeType: json["withdrawal_charge_type"],
        withdrawalCharge: json["withdrawal_charge"] == null
            ? null
            : WithdrawalCharge.fromJson(json["withdrawal_charge"]),
      );

  Map<String, dynamic> toJson() => {
        "transaction_mode": transactionMode,
        "transaction_charge_type": transactionChargeType,
        "transaction_charge": transactionCharge?.toJson(),
        "withdrawal_mode": withdrawalMode,
        "withdrawal_limit": withdrawalLimit,
        "withdrawal_thresold": withdrawalThresold,
        "withdrawal_charge_type": withdrawalChargeType,
        "withdrawal_charge": withdrawalCharge?.toJson(),
      };
}

class TransactionCharge {
  List<Accountfund>? accountfunds;
  List<Accountfund>? ccavenue;

  TransactionCharge({
    this.accountfunds,
    this.ccavenue,
  });

  TransactionCharge copyWith({
    List<Accountfund>? accountfunds,
    List<Accountfund>? ccavenue,
  }) =>
      TransactionCharge(
        accountfunds: accountfunds ?? this.accountfunds,
        ccavenue: ccavenue ?? this.ccavenue,
      );

  factory TransactionCharge.fromJson(Map<String, dynamic> json) =>
      TransactionCharge(
        accountfunds: json["accountfunds"] == null
            ? []
            : List<Accountfund>.from(
                json["accountfunds"]!.map((x) => Accountfund.fromJson(x))),
        ccavenue: json["ccavenue"] == null
            ? []
            : List<Accountfund>.from(
                json["ccavenue"]!.map((x) => Accountfund.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "accountfunds": accountfunds == null
            ? []
            : List<dynamic>.from(accountfunds!.map((x) => x.toJson())),
        "ccavenue": ccavenue == null
            ? []
            : List<dynamic>.from(ccavenue!.map((x) => x.toJson())),
      };
}

class Accountfund {
  String? percent;
  String? fixed;

  Accountfund({
    this.percent,
    this.fixed,
  });

  Accountfund copyWith({
    String? percent,
    String? fixed,
  }) =>
      Accountfund(
        percent: percent ?? this.percent,
        fixed: fixed ?? this.fixed,
      );

  factory Accountfund.fromJson(Map<String, dynamic> json) => Accountfund(
        percent: json["percent"],
        fixed: json["fixed"],
      );

  Map<String, dynamic> toJson() => {
        "percent": percent,
        "fixed": fixed,
      };
}

class WithdrawalCharge {
  List<BankTransfer>? paypal;
  List<BankTransfer>? stripe;
  List<BankTransfer>? skrill;
  List<BankTransfer>? bankTransfer;

  WithdrawalCharge({
    this.paypal,
    this.stripe,
    this.skrill,
    this.bankTransfer,
  });

  WithdrawalCharge copyWith({
    List<BankTransfer>? paypal,
    List<BankTransfer>? stripe,
    List<BankTransfer>? skrill,
    List<BankTransfer>? bankTransfer,
  }) =>
      WithdrawalCharge(
        paypal: paypal ?? this.paypal,
        stripe: stripe ?? this.stripe,
        skrill: skrill ?? this.skrill,
        bankTransfer: bankTransfer ?? this.bankTransfer,
      );

  factory WithdrawalCharge.fromJson(Map<String, dynamic> json) =>
      WithdrawalCharge(
        paypal: json["paypal"] == null
            ? []
            : List<BankTransfer>.from(
                json["paypal"]!.map((x) => BankTransfer.fromJson(x))),
        stripe: json["stripe"] == null
            ? []
            : List<BankTransfer>.from(
                json["stripe"]!.map((x) => BankTransfer.fromJson(x))),
        skrill: json["skrill"] == null
            ? []
            : List<BankTransfer>.from(
                json["skrill"]!.map((x) => BankTransfer.fromJson(x))),
        bankTransfer: json["bank_transfer"] == null
            ? []
            : List<BankTransfer>.from(
                json["bank_transfer"]!.map((x) => BankTransfer.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "paypal": paypal == null
            ? []
            : List<dynamic>.from(paypal!.map((x) => x.toJson())),
        "stripe": stripe == null
            ? []
            : List<dynamic>.from(stripe!.map((x) => x.toJson())),
        "skrill": skrill == null
            ? []
            : List<dynamic>.from(skrill!.map((x) => x.toJson())),
        "bank_transfer": bankTransfer == null
            ? []
            : List<dynamic>.from(bankTransfer!.map((x) => x.toJson())),
      };
}

class BankTransfer {
  String? percent;
  String? fixed;
  String? tax;

  BankTransfer({
    this.percent,
    this.fixed,
    this.tax,
  });

  BankTransfer copyWith({
    String? percent,
    String? fixed,
    String? tax,
  }) =>
      BankTransfer(
        percent: percent ?? this.percent,
        fixed: fixed ?? this.fixed,
        tax: tax ?? this.tax,
      );

  factory BankTransfer.fromJson(Map<String, dynamic> json) => BankTransfer(
        percent: json["percent"],
        fixed: json["fixed"],
        tax: json["tax"],
      );

  Map<String, dynamic> toJson() => {
        "percent": percent,
        "fixed": fixed,
        "tax": tax,
      };
}

class StoreTabHeadings {
  String? products;
  String? about;
  String? policies;
  String? reviews;

  StoreTabHeadings({
    this.products,
    this.about,
    this.policies,
    this.reviews,
  });

  StoreTabHeadings copyWith({
    String? products,
    String? about,
    String? policies,
    String? reviews,
  }) =>
      StoreTabHeadings(
        products: products ?? this.products,
        about: about ?? this.about,
        policies: policies ?? this.policies,
        reviews: reviews ?? this.reviews,
      );

  factory StoreTabHeadings.fromJson(Map<String, dynamic> json) =>
      StoreTabHeadings(
        products: json["products"],
        about: json["about"],
        policies: json["policies"],
        reviews: json["reviews"],
      );

  Map<String, dynamic> toJson() => {
        "products": products,
        "about": about,
        "policies": policies,
        "reviews": reviews,
      };
}

class VendorAdditionalInfo {
  String? enable;
  String? type;
  String? label;
  String? options;
  String? content;
  String? helpText;
  String? name;
  String? value;

  VendorAdditionalInfo({
    this.enable,
    this.type,
    this.label,
    this.options,
    this.content,
    this.helpText,
    this.name,
    this.value,
  });

  VendorAdditionalInfo copyWith({
    String? enable,
    String? type,
    String? label,
    String? options,
    String? content,
    String? helpText,
    String? name,
    String? value,
  }) =>
      VendorAdditionalInfo(
        enable: enable ?? this.enable,
        type: type ?? this.type,
        label: label ?? this.label,
        options: options ?? this.options,
        content: content ?? this.content,
        helpText: helpText ?? this.helpText,
        name: name ?? this.name,
        value: value ?? this.value,
      );

  factory VendorAdditionalInfo.fromJson(Map<String, dynamic> json) =>
      VendorAdditionalInfo(
        enable: json["enable"],
        type: json["type"],
        label: json["label"],
        options: json["options"],
        content: json["content"],
        helpText: json["help_text"],
        name: json["name"],
        value: json["value"],
      );

  Map<String, dynamic> toJson() => {
        "enable": enable,
        "type": type,
        "label": label,
        "options": options,
        "content": content,
        "help_text": helpText,
        "name": name,
        "value": value,
      };
}

class WcfmProductPolicyData {
  String? shippingPolicyHeading;
  String? shippingPolicy;
  String? refundPolicyHeading;
  String? refundPolicy;
  String? cancellationPolicyHeading;
  String? cancellationPolicy;
  bool? visible;
  String? tabTitle;

  WcfmProductPolicyData({
    this.shippingPolicyHeading,
    this.shippingPolicy,
    this.refundPolicyHeading,
    this.refundPolicy,
    this.cancellationPolicyHeading,
    this.cancellationPolicy,
    this.visible,
    this.tabTitle,
  });

  WcfmProductPolicyData copyWith({
    String? shippingPolicyHeading,
    String? shippingPolicy,
    String? refundPolicyHeading,
    String? refundPolicy,
    String? cancellationPolicyHeading,
    String? cancellationPolicy,
    bool? visible,
    String? tabTitle,
  }) =>
      WcfmProductPolicyData(
        shippingPolicyHeading:
            shippingPolicyHeading ?? this.shippingPolicyHeading,
        shippingPolicy: shippingPolicy ?? this.shippingPolicy,
        refundPolicyHeading: refundPolicyHeading ?? this.refundPolicyHeading,
        refundPolicy: refundPolicy ?? this.refundPolicy,
        cancellationPolicyHeading:
            cancellationPolicyHeading ?? this.cancellationPolicyHeading,
        cancellationPolicy: cancellationPolicy ?? this.cancellationPolicy,
        visible: visible ?? this.visible,
        tabTitle: tabTitle ?? this.tabTitle,
      );

  factory WcfmProductPolicyData.fromJson(Map<String, dynamic> json) =>
      WcfmProductPolicyData(
        shippingPolicyHeading: json["shipping_policy_heading"],
        shippingPolicy: json["shipping_policy"],
        refundPolicyHeading: json["refund_policy_heading"],
        refundPolicy: json["refund_policy"],
        cancellationPolicyHeading: json["cancellation_policy_heading"],
        cancellationPolicy: json["cancellation_policy"],
        visible: json["visible"],
        tabTitle: json["tab_title"],
      );

  Map<String, dynamic> toJson() => {
        "shipping_policy_heading": shippingPolicyHeading,
        "shipping_policy": shippingPolicy,
        "refund_policy_heading": refundPolicyHeading,
        "refund_policy": refundPolicy,
        "cancellation_policy_heading": cancellationPolicyHeading,
        "cancellation_policy": cancellationPolicy,
        "visible": visible,
        "tab_title": tabTitle,
      };
}

class Links {
  List<Self>? self;
  List<Collection>? collection;
  List<Collection>? customer;

  Links({
    this.self,
    this.collection,
    this.customer,
  });

  Links copyWith({
    List<Self>? self,
    List<Collection>? collection,
    List<Collection>? customer,
  }) =>
      Links(
        self: self ?? this.self,
        collection: collection ?? this.collection,
        customer: customer ?? this.customer,
      );

  factory Links.fromJson(Map<String, dynamic> json) => Links(
        self: json["self"] == null
            ? []
            : List<Self>.from(json["self"]!.map((x) => Self.fromJson(x))),
        collection: json["collection"] == null
            ? []
            : List<Collection>.from(
                json["collection"]!.map((x) => Collection.fromJson(x))),
        customer: json["customer"] == null
            ? []
            : List<Collection>.from(
                json["customer"]!.map((x) => Collection.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "self": self == null
            ? []
            : List<dynamic>.from(self!.map((x) => x.toJson())),
        "collection": collection == null
            ? []
            : List<dynamic>.from(collection!.map((x) => x.toJson())),
        "customer": customer == null
            ? []
            : List<dynamic>.from(customer!.map((x) => x.toJson())),
      };
}

class Collection {
  String? href;

  Collection({
    this.href,
  });

  Collection copyWith({
    String? href,
  }) =>
      Collection(
        href: href ?? this.href,
      );

  factory Collection.fromJson(Map<String, dynamic> json) => Collection(
        href: json["href"],
      );

  Map<String, dynamic> toJson() => {
        "href": href,
      };
}

class Self {
  String? href;
  TargetHints? targetHints;

  Self({
    this.href,
    this.targetHints,
  });

  Self copyWith({
    String? href,
    TargetHints? targetHints,
  }) =>
      Self(
        href: href ?? this.href,
        targetHints: targetHints ?? this.targetHints,
      );

  factory Self.fromJson(Map<String, dynamic> json) => Self(
        href: json["href"],
        targetHints: json["targetHints"] == null
            ? null
            : TargetHints.fromJson(json["targetHints"]),
      );

  Map<String, dynamic> toJson() => {
        "href": href,
        "targetHints": targetHints?.toJson(),
      };
}

class TargetHints {
  List<String>? allow;

  TargetHints({
    this.allow,
  });

  TargetHints copyWith({
    List<String>? allow,
  }) =>
      TargetHints(
        allow: allow ?? this.allow,
      );

  factory TargetHints.fromJson(Map<String, dynamic> json) => TargetHints(
        allow: json["allow"] == null
            ? []
            : List<String>.from(json["allow"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "allow": allow == null ? [] : List<dynamic>.from(allow!.map((x) => x)),
      };
}

class ProductMetaDatum {
  int? id;
  String? key;
  dynamic value;

  ProductMetaDatum({
    this.id,
    this.key,
    this.value,
  });

  ProductMetaDatum copyWith({
    int? id,
    String? key,
    dynamic value,
  }) =>
      ProductMetaDatum(
        id: id ?? this.id,
        key: key ?? this.key,
        value: value ?? this.value,
      );

  factory ProductMetaDatum.fromJson(Map<String, dynamic> json) =>
      ProductMetaDatum(
        id: json["id"],
        key: json["key"],
        value: json["value"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "key": key,
        "value": value,
      };
}

class FluffyValue {
  String? displayShippingAddress;
  String? displayEmail;
  String? displayPhone;
  String? displayDate;
  String? displayNumber;
  String? headerLogo;
  String? headerLogoHeight;
  dynamic vatNumber;
  dynamic cocNumber;
  CocNumber? shopName;
  String? shopPhoneNumber;
  CocNumber? shopAddress;
  CocNumber? footer;
  CocNumber? extra1;
  CocNumber? extra2;
  CocNumber? extra3;
  int? number;
  String? formattedNumber;
  dynamic prefix;
  dynamic suffix;
  String? documentType;
  int? orderId;
  dynamic padding;

  FluffyValue({
    this.displayShippingAddress,
    this.displayEmail,
    this.displayPhone,
    this.displayDate,
    this.displayNumber,
    this.headerLogo,
    this.headerLogoHeight,
    this.vatNumber,
    this.cocNumber,
    this.shopName,
    this.shopPhoneNumber,
    this.shopAddress,
    this.footer,
    this.extra1,
    this.extra2,
    this.extra3,
    this.number,
    this.formattedNumber,
    this.prefix,
    this.suffix,
    this.documentType,
    this.orderId,
    this.padding,
  });

  FluffyValue copyWith({
    String? displayShippingAddress,
    String? displayEmail,
    String? displayPhone,
    String? displayDate,
    String? displayNumber,
    String? headerLogo,
    String? headerLogoHeight,
    dynamic vatNumber,
    dynamic cocNumber,
    CocNumber? shopName,
    String? shopPhoneNumber,
    CocNumber? shopAddress,
    CocNumber? footer,
    CocNumber? extra1,
    CocNumber? extra2,
    CocNumber? extra3,
    int? number,
    String? formattedNumber,
    dynamic prefix,
    dynamic suffix,
    String? documentType,
    int? orderId,
    dynamic padding,
  }) =>
      FluffyValue(
        displayShippingAddress:
            displayShippingAddress ?? this.displayShippingAddress,
        displayEmail: displayEmail ?? this.displayEmail,
        displayPhone: displayPhone ?? this.displayPhone,
        displayDate: displayDate ?? this.displayDate,
        displayNumber: displayNumber ?? this.displayNumber,
        headerLogo: headerLogo ?? this.headerLogo,
        headerLogoHeight: headerLogoHeight ?? this.headerLogoHeight,
        vatNumber: vatNumber ?? this.vatNumber,
        cocNumber: cocNumber ?? this.cocNumber,
        shopName: shopName ?? this.shopName,
        shopPhoneNumber: shopPhoneNumber ?? this.shopPhoneNumber,
        shopAddress: shopAddress ?? this.shopAddress,
        footer: footer ?? this.footer,
        extra1: extra1 ?? this.extra1,
        extra2: extra2 ?? this.extra2,
        extra3: extra3 ?? this.extra3,
        number: number ?? this.number,
        formattedNumber: formattedNumber ?? this.formattedNumber,
        prefix: prefix ?? this.prefix,
        suffix: suffix ?? this.suffix,
        documentType: documentType ?? this.documentType,
        orderId: orderId ?? this.orderId,
        padding: padding ?? this.padding,
      );

  factory FluffyValue.fromJson(Map<String, dynamic> json) => FluffyValue(
        displayShippingAddress: json["display_shipping_address"],
        displayEmail: json["display_email"],
        displayPhone: json["display_phone"],
        displayDate: json["display_date"],
        displayNumber: json["display_number"],
        headerLogo: json["header_logo"],
        headerLogoHeight: json["header_logo_height"],
        vatNumber: json["vat_number"],
        cocNumber: json["coc_number"],
        shopName: json["shop_name"] == null
            ? null
            : CocNumber.fromJson(json["shop_name"]),
        shopPhoneNumber: json["shop_phone_number"],
        shopAddress: json["shop_address"] == null
            ? null
            : CocNumber.fromJson(json["shop_address"]),
        footer:
            json["footer"] == null ? null : CocNumber.fromJson(json["footer"]),
        extra1: json["extra_1"] == null
            ? null
            : CocNumber.fromJson(json["extra_1"]),
        extra2: json["extra_2"] == null
            ? null
            : CocNumber.fromJson(json["extra_2"]),
        extra3: json["extra_3"] == null
            ? null
            : CocNumber.fromJson(json["extra_3"]),
        number: json["number"],
        formattedNumber: json["formatted_number"],
        prefix: json["prefix"],
        suffix: json["suffix"],
        documentType: json["document_type"],
        orderId: json["order_id"],
        padding: json["padding"],
      );

  Map<String, dynamic> toJson() => {
        "display_shipping_address": displayShippingAddress,
        "display_email": displayEmail,
        "display_phone": displayPhone,
        "display_date": displayDate,
        "display_number": displayNumber,
        "header_logo": headerLogo,
        "header_logo_height": headerLogoHeight,
        "vat_number": vatNumber,
        "coc_number": cocNumber,
        "shop_name": shopName?.toJson(),
        "shop_phone_number": shopPhoneNumber,
        "shop_address": shopAddress?.toJson(),
        "footer": footer?.toJson(),
        "extra_1": extra1?.toJson(),
        "extra_2": extra2?.toJson(),
        "extra_3": extra3?.toJson(),
        "number": number,
        "formatted_number": formattedNumber,
        "prefix": prefix,
        "suffix": suffix,
        "document_type": documentType,
        "order_id": orderId,
        "padding": padding,
      };
}

class CocNumber {
  String? cocNumberDefault;

  CocNumber({
    this.cocNumberDefault,
  });

  CocNumber copyWith({
    String? cocNumberDefault,
  }) =>
      CocNumber(
        cocNumberDefault: cocNumberDefault ?? this.cocNumberDefault,
      );

  factory CocNumber.fromJson(Map<String, dynamic> json) => CocNumber(
        cocNumberDefault: json["default"],
      );

  Map<String, dynamic> toJson() => {
        "default": cocNumberDefault,
      };
}

class Refund {
  int? id;
  String? reason;
  String? total;

  Refund({
    this.id,
    this.reason,
    this.total,
  });

  Refund copyWith({
    int? id,
    String? reason,
    String? total,
  }) =>
      Refund(
        id: id ?? this.id,
        reason: reason ?? this.reason,
        total: total ?? this.total,
      );

  factory Refund.fromJson(Map<String, dynamic> json) => Refund(
        id: json["id"],
        reason: json["reason"],
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "reason": reason,
        "total": total,
      };
}


