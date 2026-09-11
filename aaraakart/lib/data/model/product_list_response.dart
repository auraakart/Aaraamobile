import 'dart:convert';

ProductListModel productListModelFromJson(String str) =>
    ProductListModel.fromJson(json.decode(str));

String productListModelToJson(ProductListModel data) =>
    json.encode(data.toJson());

class ProductListModel {
  List<Product>? products;
  int? total;
  int? totalPages;
  int? perPage;
  int? currentPage;

  List<DeliverySlot>? deliverySlots;
  DeliverySchedule? deliverySchedule;

  ProductListModel({
    this.products,
    this.total,
    this.totalPages,
    this.perPage,
    this.currentPage,
    this.deliverySlots,
    this.deliverySchedule,
  });

  factory ProductListModel.fromJson(Map<String, dynamic> json) {
    List<Product> productList = [];

    final productsJson = json["products"];

    if (productsJson is List) {
      productList = productsJson.map((e) => Product.fromJson(e)).toList();
    } else if (productsJson is Map<String, dynamic>) {
      productList = [Product.fromJson(productsJson)];
    }

    return ProductListModel(
      products: productList,
      total: json["total"],
      totalPages: json["total_pages"],
      perPage: json["per_page"],
      currentPage: json["current_page"],
      deliverySlots: json["delivery_slots"] == null
          ? []
          : List<DeliverySlot>.from(
              json["delivery_slots"].map((x) => DeliverySlot.fromJson(x))),
      deliverySchedule: json["delivery_schedule"] == null
          ? null
          : DeliverySchedule.fromJson(json["delivery_schedule"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "products": products == null
            ? []
            : List<dynamic>.from(products!.map((x) => x.toJson())),
        "total": total,
        "total_pages": totalPages,
        "per_page": perPage,
        "current_page": currentPage,
        "delivery_slots": deliverySlots?.map((e) => e.toJson()).toList() ?? [],
        "delivery_schedule": deliverySchedule?.toJson(),
      };

  Product? get product =>
      products != null && products!.isNotEmpty ? products!.first : null;
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

  factory DeliverySlot.fromJson(Map<String, dynamic> json) {
    return DeliverySlot(
      id: json["id"],
      name: json["name"],
      startTime: json["start_time"],
      endTime: json["end_time"],
      timeLabel: json["time_label"],
      label: json["label"],
      status: json["status"],
    );
  }

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

class ScheduleOption {
  final String? key;
  final String? label;
  final bool? requiresDays;
  final List<int>? days;

  ScheduleOption({
    this.key,
    this.label,
    this.requiresDays,
    this.days,
  });

  factory ScheduleOption.fromJson(Map<String, dynamic> json) {
    return ScheduleOption(
      key: json["key"],
      label: json["label"],
      requiresDays: json["requires_days"],
      days: json["days"] == null ? [] : List<int>.from(json["days"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "key": key,
        "label": label,
        "requires_days": requiresDays,
        "days": days ?? [],
      };
}

class Weekday {
  final int? value;
  final String? label;

  Weekday({
    this.value,
    this.label,
  });

  factory Weekday.fromJson(Map<String, dynamic> json) {
    return Weekday(
      value: json["value"],
      label: json["label"],
    );
  }

  Map<String, dynamic> toJson() => {
        "value": value,
        "label": label,
      };
}

class DeliverySchedule {
  final List<ScheduleOption>? schedules;
  final List<Weekday>? weekdays;

  DeliverySchedule({
    this.schedules,
    this.weekdays,
  });

  factory DeliverySchedule.fromJson(Map<String, dynamic> json) {
    return DeliverySchedule(
      schedules: json["schedules"] == null
          ? []
          : List<ScheduleOption>.from(
              json["schedules"].map((x) => ScheduleOption.fromJson(x))),
      weekdays: json["weekdays"] == null
          ? []
          : List<Weekday>.from(
              json["weekdays"].map((x) => Weekday.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "schedules": schedules?.map((e) => e.toJson()).toList() ?? [],
        "weekdays": weekdays?.map((e) => e.toJson()).toList() ?? [],
      };
}

class Product {
  int? id;
  String? name;
  String? slug;
  String? dateCreated;
  String? dateModified;
  String? status;
  bool? featured;
  String? description;
  String? shortDescription;
  String? sku;
  String? price;
  String? regularPrice;
  String? salePrice;
  String? stockStatus;
  int? downloadLimit;
  int? advanceAmount;
  String? weight;
  bool? reviewsAllowed;
  String? averageRating;
  int? ratingCount;
  List<Category>? categories;
  List<Image>? images;
  List<dynamic>? attributes;
  List<dynamic>? defaultAttributes;
  List<dynamic>? variations;
  List<dynamic>? groupedProducts;
  List<int>? relatedIds;
  List<MetaDatum>? metaData;
  List<GetSubscriptionResponse>? subscriptionPlans;

  Product({
    this.id,
    this.name,
    this.slug,
    this.dateCreated,
    this.dateModified,
    this.status,
    this.featured,
    this.description,
    this.shortDescription,
    this.sku,
    this.price,
    this.regularPrice,
    this.salePrice,
    this.stockStatus,
    this.downloadLimit,
    this.advanceAmount,
    this.weight,
    this.reviewsAllowed,
    this.averageRating,
    this.ratingCount,
    this.categories,
    this.images,
    this.attributes,
    this.defaultAttributes,
    this.variations,
    this.groupedProducts,
    this.relatedIds,
    this.metaData,
    this.subscriptionPlans,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"],
        name: json["name"],
        slug: json["slug"],
        dateCreated: json["date_created"],
        dateModified: json["date_modified"],
        status: json["status"],
        featured: json["featured"],
        description: json["description"],
        shortDescription: json["short_description"],
        sku: json["sku"],
        price: json["price"],
        regularPrice: json["regular_price"],
        salePrice: json["sale_price"],
        stockStatus: json["stock_status"],
        downloadLimit: json["download_limit"],
        advanceAmount: json["advance_amount"],
        weight: json["weight"],
        reviewsAllowed: json["reviews_allowed"],
        averageRating: json["average_rating"],
        ratingCount: json["rating_count"],
        categories: json["categories"] == null
            ? []
            : List<Category>.from(
                json["categories"].map((x) => Category.fromJson(x))),
        images: json["images"] == null
            ? []
            : List<Image>.from(json["images"].map((x) => Image.fromJson(x))),
        attributes: json["attributes"] == null
            ? []
            : List<dynamic>.from(json["attributes"]),
        defaultAttributes: json["default_attributes"] == null
            ? []
            : List<dynamic>.from(json["default_attributes"]),
        variations: json["variations"] == null
            ? []
            : List<dynamic>.from(json["variations"]),
        groupedProducts: json["grouped_products"] == null
            ? []
            : List<dynamic>.from(json["grouped_products"]),
        relatedIds: json["related_ids"] == null
            ? []
            : List<int>.from(json["related_ids"]),
        metaData: json["meta_data"] == null
            ? []
            : List<MetaDatum>.from(
                json["meta_data"].map((x) => MetaDatum.fromJson(x))),
        subscriptionPlans: json["subscription_plans"] == null
            ? []
            : List<GetSubscriptionResponse>.from(json["subscription_plans"]
                .map((x) => GetSubscriptionResponse.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
        "date_created": dateCreated,
        "date_modified": dateModified,
        "status": status,
        "featured": featured,
        "description": description,
        "short_description": shortDescription,
        "sku": sku,
        "price": price,
        "regular_price": regularPrice,
        "sale_price": salePrice,
        "stock_status": stockStatus,
        "download_limit": downloadLimit,
        "advance_amount": advanceAmount,
        "weight": weight,
        "reviews_allowed": reviewsAllowed,
        "average_rating": averageRating,
        "rating_count": ratingCount,
        "categories": categories?.map((e) => e.toJson()).toList(),
        "images": images?.map((e) => e.toJson()).toList(),
        "attributes": attributes,
        "default_attributes": defaultAttributes,
        "variations": variations,
        "grouped_products": groupedProducts,
        "related_ids": relatedIds,
        "meta_data": metaData?.map((e) => e.toJson()).toList(),
        "subscription_plans":
            subscriptionPlans?.map((e) => e.toJson()).toList(),
      };

  bool get isOutOfStock {
    final status = stockStatus?.trim().toLowerCase();
    if (status != null && status.isNotEmpty) return status == 'outofstock';

    return false;
  }
}

class GetSubscriptionResponse {
  int? interval;
  String? period;
  int? length;
  String? pricingMethod;
  String? regularPrice;
  String? salePrice;
  String? price;
  String? discount;
  int? advanceAmount;

  GetSubscriptionResponse({
    this.interval,
    this.period,
    this.length,
    this.pricingMethod,
    this.regularPrice,
    this.salePrice,
    this.price,
    this.discount,
    this.advanceAmount,
  });

  factory GetSubscriptionResponse.fromJson(Map<String, dynamic> json) =>
      GetSubscriptionResponse(
        interval: json["interval"],
        period: json["period"],
        length: json["length"],
        pricingMethod: json["pricing_method"],
        regularPrice: json["regular_price"],
        salePrice: json["sale_price"],
        price: json["price"],
        discount: json["discount"],
        advanceAmount: json["advance_amount"],
      );

  Map<String, dynamic> toJson() => {
        "interval": interval,
        "period": period,
        "length": length,
        "pricing_method": pricingMethod,
        "regular_price": regularPrice,
        "sale_price": salePrice,
        "price": price,
        "discount": discount,
        "advance_amount": advanceAmount,
      };
}

class Category {
  int? id;
  String? name;
  String? slug;

  Category({
    this.id,
    this.name,
    this.slug,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
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

class Image {
  int? id;
  String? dateCreated;
  String? dateCreatedGmt;
  String? dateModified;
  String? dateModifiedGmt;
  String? src;
  String? name;
  String? alt;
  String? srcset;
  String? thumbnail;
  String? x1536x1536;
  String? x2048x2048;
  String? postThumbnail;
  String? econisFullWidth;
  String? econisBlogSidebar;
  String? econisBlogLayout1;
  String? woocommerceThumbnail;
  String? woocommerceSingle;
  String? woocommerceGalleryThumbnail;
  String? wooscLarge;
  String? wooscSmall;

  Image({
    this.id,
    this.dateCreated,
    this.dateCreatedGmt,
    this.dateModified,
    this.dateModifiedGmt,
    this.src,
    this.name,
    this.alt,
    this.srcset,
    this.thumbnail,
    this.x1536x1536,
    this.x2048x2048,
    this.postThumbnail,
    this.econisFullWidth,
    this.econisBlogSidebar,
    this.econisBlogLayout1,
    this.woocommerceThumbnail,
    this.woocommerceSingle,
    this.woocommerceGalleryThumbnail,
    this.wooscLarge,
    this.wooscSmall,
  });

  factory Image.fromJson(Map<String, dynamic> json) => Image(
        id: json["id"],
        dateCreated: json["date_created"],
        dateCreatedGmt: json["date_created_gmt"],
        dateModified: json["date_modified"],
        dateModifiedGmt: json["date_modified_gmt"],
        src: json["src"],
        name: json["name"],
        alt: json["alt"],
        srcset: json["srcset"],
        thumbnail: json["thumbnail"],
        x1536x1536: json["1536x1536"],
        x2048x2048: json["2048x2048"],
        postThumbnail: json["post-thumbnail"],
        econisFullWidth: json["econis-full-width"],
        econisBlogSidebar: json["econis-blog-sidebar"],
        econisBlogLayout1: json["econis-blog-layout-1"],
        woocommerceThumbnail: json["woocommerce_thumbnail"],
        woocommerceSingle: json["woocommerce_single"],
        woocommerceGalleryThumbnail: json["woocommerce_gallery_thumbnail"],
        wooscLarge: json["woosc-large"],
        wooscSmall: json["woosc-small"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "date_created": dateCreated,
        "date_created_gmt": dateCreatedGmt,
        "date_modified": dateModified,
        "date_modified_gmt": dateModifiedGmt,
        "src": src,
        "name": name,
        "alt": alt,
        "srcset": srcset,
        "thumbnail": thumbnail,
        "1536x1536": x1536x1536,
        "2048x2048": x2048x2048,
        "post-thumbnail": postThumbnail,
        "econis-full-width": econisFullWidth,
        "econis-blog-sidebar": econisBlogSidebar,
        "econis-blog-layout-1": econisBlogLayout1,
        "woocommerce_thumbnail": woocommerceThumbnail,
        "woocommerce_single": woocommerceSingle,
        "woocommerce_gallery_thumbnail": woocommerceGalleryThumbnail,
        "woosc-large": wooscLarge,
        "woosc-small": wooscSmall,
      };
}

class MetaDatum {
  int? id;
  String? key;
  dynamic value;

  MetaDatum({
    this.id,
    this.key,
    this.value,
  });

  factory MetaDatum.fromJson(Map<String, dynamic> json) => MetaDatum(
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

class ValueElement {
  String? subscriptionPeriodInterval;
  String? subscriptionPeriod;
  String? subscriptionLength;
  String? subscriptionPricingMethod;
  String? subscriptionRegularPrice;
  String? subscriptionSalePrice;
  String? subscriptionDiscount;
  String? position;
  String? subscriptionPrice;
  int? subscriptionPaymentSyncDate;

  ValueElement({
    this.subscriptionPeriodInterval,
    this.subscriptionPeriod,
    this.subscriptionLength,
    this.subscriptionPricingMethod,
    this.subscriptionRegularPrice,
    this.subscriptionSalePrice,
    this.subscriptionDiscount,
    this.position,
    this.subscriptionPrice,
    this.subscriptionPaymentSyncDate,
  });

  factory ValueElement.fromJson(Map<String, dynamic> json) => ValueElement(
        subscriptionPeriodInterval: json["subscription_period_interval"],
        subscriptionPeriod: json["subscription_period"],
        subscriptionLength: json["subscription_length"],
        subscriptionPricingMethod: json["subscription_pricing_method"],
        subscriptionRegularPrice: json["subscription_regular_price"],
        subscriptionSalePrice: json["subscription_sale_price"],
        subscriptionDiscount: json["subscription_discount"],
        position: json["position"],
        subscriptionPrice: json["subscription_price"],
        subscriptionPaymentSyncDate: json["subscription_payment_sync_date"],
      );

  Map<String, dynamic> toJson() => {
        "subscription_period_interval": subscriptionPeriodInterval,
        "subscription_period": subscriptionPeriod,
        "subscription_length": subscriptionLength,
        "subscription_pricing_method": subscriptionPricingMethod,
        "subscription_regular_price": subscriptionRegularPrice,
        "subscription_sale_price": subscriptionSalePrice,
        "subscription_discount": subscriptionDiscount,
        "position": position,
        "subscription_price": subscriptionPrice,
        "subscription_payment_sync_date": subscriptionPaymentSyncDate,
      };
}


