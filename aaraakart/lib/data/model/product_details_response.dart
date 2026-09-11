// To parse this JSON data, do
//
//     final getProductDetaillsResponseModel = getProductDetaillsResponseModelFromJson(jsonString);

import 'dart:convert';

GetProductDetaillsResponseModel getProductDetaillsResponseModelFromJson(
        String str) =>
    GetProductDetaillsResponseModel.fromJson(json.decode(str));

String getProductDetaillsResponseModelToJson(
        GetProductDetaillsResponseModel data) =>
    json.encode(data.toJson());

class GetProductDetaillsResponseModel {
  ProductDetails? products;
  int? total;
  int? totalPages;
  int? perPage;
  int? currentPage;
  Links? links;

  GetProductDetaillsResponseModel({
    this.products,
    this.total,
    this.totalPages,
    this.perPage,
    this.currentPage,
    this.links,
  });

  GetProductDetaillsResponseModel copyWith({
    ProductDetails? products,
    int? total,
    int? totalPages,
    int? perPage,
    int? currentPage,
    Links? links,
  }) =>
      GetProductDetaillsResponseModel(
        products: products ?? this.products,
        total: total ?? this.total,
        totalPages: totalPages ?? this.totalPages,
        perPage: perPage ?? this.perPage,
        currentPage: currentPage ?? this.currentPage,
        links: links ?? this.links,
      );

  factory GetProductDetaillsResponseModel.fromJson(Map<String, dynamic> json) =>
      GetProductDetaillsResponseModel(
        products: json["products"] == null
            ? null
            : ProductDetails.fromJson(json["products"]),
        total: json["total"],
        totalPages: json["total_pages"],
        perPage: json["per_page"],
        currentPage: json["current_page"],
        links: json["_links"] == null ? null : Links.fromJson(json["_links"]),
      );

  Map<String, dynamic> toJson() => {
        "products": products?.toJson(),
        "total": total,
        "total_pages": totalPages,
        "per_page": perPage,
        "current_page": currentPage,
        "_links": links?.toJson(),
      };
}

class Links {
  List<Self>? self;
  List<Collection>? collection;

  Links({
    this.self,
    this.collection,
  });

  Links copyWith({
    List<Self>? self,
    List<Collection>? collection,
  }) =>
      Links(
        self: self ?? this.self,
        collection: collection ?? this.collection,
      );

  factory Links.fromJson(Map<String, dynamic> json) => Links(
        self: json["self"] == null
            ? []
            : List<Self>.from(json["self"]!.map((x) => Self.fromJson(x))),
        collection: json["collection"] == null
            ? []
            : List<Collection>.from(
                json["collection"]!.map((x) => Collection.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "self": self == null
            ? []
            : List<dynamic>.from(self!.map((x) => x.toJson())),
        "collection": collection == null
            ? []
            : List<dynamic>.from(collection!.map((x) => x.toJson())),
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

class ProductDetails {
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
  dynamic sku;
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
  List<Category>? categories;
  List<dynamic>? tags;
  List<Image>? images;
  List<Attribute>? attributes;
  List<dynamic>? defaultAttributes;
  List<dynamic>? variations;
  List<int>? groupedProducts;
  int? menuOrder;
  String? priceHtml;
  List<int>? relatedIds;
  List<MetaDatum>? metaData;
  String? stockStatus;
  bool? hasOptions;
  String? postPassword;
  String? globalUniqueId;
  bool? isPurchased;
  List<AttributesDatum>? attributesData;
  ProductUnits? productUnits;
  WcfmProductPolicyData? wcfmProductPolicyData;
  bool? showAdditionalInfoTab;
  String? productRestirctionMessage;

  ProductDetails({
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
    this.isPurchased,
    this.attributesData,
    this.productUnits,
    this.wcfmProductPolicyData,
    this.showAdditionalInfoTab,
    this.productRestirctionMessage,
  });

  ProductDetails copyWith({
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
    List<Category>? categories,
    List<dynamic>? tags,
    List<Image>? images,
    List<Attribute>? attributes,
    List<dynamic>? defaultAttributes,
    List<dynamic>? variations,
    List<int>? groupedProducts,
    int? menuOrder,
    String? priceHtml,
    List<int>? relatedIds,
    List<MetaDatum>? metaData,
    String? stockStatus,
    bool? hasOptions,
    String? postPassword,
    String? globalUniqueId,
    List<dynamic>? brands,
    bool? isPurchased,
    List<AttributesDatum>? attributesData,
    ProductUnits? productUnits,
    WcfmProductPolicyData? wcfmProductPolicyData,
    bool? showAdditionalInfoTab,
    String? productRestirctionMessage,
  }) =>
      ProductDetails(
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
        isPurchased: isPurchased ?? this.isPurchased,
        attributesData: attributesData ?? this.attributesData,
        productUnits: productUnits ?? this.productUnits,
        wcfmProductPolicyData:
            wcfmProductPolicyData ?? this.wcfmProductPolicyData,
        showAdditionalInfoTab:
            showAdditionalInfoTab ?? this.showAdditionalInfoTab,
        productRestirctionMessage:
            productRestirctionMessage ?? this.productRestirctionMessage,
      );

  factory ProductDetails.fromJson(Map<String, dynamic> json) => ProductDetails(
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
            : List<Category>.from(
                json["categories"]!.map((x) => Category.fromJson(x))),
        tags: json["tags"] == null
            ? []
            : List<dynamic>.from(json["tags"]!.map((x) => x)),
        images: json["images"] == null
            ? []
            : List<Image>.from(json["images"]!.map((x) => Image.fromJson(x))),
        attributes: json["attributes"] == null
            ? []
            : List<Attribute>.from(
                json["attributes"]!.map((x) => Attribute.fromJson(x))),
        defaultAttributes: json["default_attributes"] == null
            ? []
            : List<dynamic>.from(json["default_attributes"]!.map((x) => x)),
        variations: json["variations"] == null
            ? []
            : List<dynamic>.from(json["variations"]!.map((x) => x)),
        groupedProducts: json["grouped_products"] == null
            ? []
            : List<int>.from(json["grouped_products"]!.map((x) => x)),
        menuOrder: json["menu_order"],
        priceHtml: json["price_html"],
        relatedIds: json["related_ids"] == null
            ? []
            : List<int>.from(json["related_ids"]!.map((x) => x)),
        metaData: json["meta_data"] == null
            ? []
            : List<MetaDatum>.from(
                json["meta_data"]!.map((x) => MetaDatum.fromJson(x))),
        stockStatus: json["stock_status"],
        hasOptions: json["has_options"],
        postPassword: json["post_password"],
        globalUniqueId: json["global_unique_id"],
  
        isPurchased: json["is_purchased"],
        attributesData: json["attributesData"] == null
            ? []
            : List<AttributesDatum>.from(json["attributesData"]!
                .map((x) => AttributesDatum.fromJson(x))),
        productUnits: json["product_units"] == null
            ? null
            : ProductUnits.fromJson(json["product_units"]),
        wcfmProductPolicyData: json["wcfm_product_policy_data"] == null
            ? null
            : WcfmProductPolicyData.fromJson(json["wcfm_product_policy_data"]),
        showAdditionalInfoTab: json["showAdditionalInfoTab"],
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
            : List<dynamic>.from(attributes!.map((x) => x.toJson())),
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
        "is_purchased": isPurchased,
        "attributesData": attributesData == null
            ? []
            : List<dynamic>.from(attributesData!.map((x) => x.toJson())),
        "product_units": productUnits?.toJson(),
        "wcfm_product_policy_data": wcfmProductPolicyData?.toJson(),
        "showAdditionalInfoTab": showAdditionalInfoTab,
        "product_restirction_message": productRestirctionMessage,
      };
}

class Attribute {
  int? id;
  String? name;
  String? slug;
  int? position;
  bool? visible;
  bool? variation;
  List<String>? options;

  Attribute({
    this.id,
    this.name,
    this.slug,
    this.position,
    this.visible,
    this.variation,
    this.options,
  });

  Attribute copyWith({
    int? id,
    String? name,
    String? slug,
    int? position,
    bool? visible,
    bool? variation,
    List<String>? options,
  }) =>
      Attribute(
        id: id ?? this.id,
        name: name ?? this.name,
        slug: slug ?? this.slug,
        position: position ?? this.position,
        visible: visible ?? this.visible,
        variation: variation ?? this.variation,
        options: options ?? this.options,
      );

  factory Attribute.fromJson(Map<String, dynamic> json) => Attribute(
        id: json["id"],
        name: json["name"],
        slug: json["slug"],
        position: json["position"],
        visible: json["visible"],
        variation: json["variation"],
        options: json["options"] == null
            ? []
            : List<String>.from(json["options"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
        "position": position,
        "visible": visible,
        "variation": variation,
        "options":
            options == null ? [] : List<dynamic>.from(options!.map((x) => x)),
      };
}

class AttributesDatum {
  int? id;
  String? name;
  List<Option>? options;
  int? position;
  bool? visible;
  bool? variation;
  int? isVisible;
  int? isVariation;
  int? isTaxonomy;
  String? value;
  String? label;
  bool? isImageType;

  AttributesDatum({
    this.id,
    this.name,
    this.options,
    this.position,
    this.visible,
    this.variation,
    this.isVisible,
    this.isVariation,
    this.isTaxonomy,
    this.value,
    this.label,
    this.isImageType,
  });

  AttributesDatum copyWith({
    int? id,
    String? name,
    List<Option>? options,
    int? position,
    bool? visible,
    bool? variation,
    int? isVisible,
    int? isVariation,
    int? isTaxonomy,
    String? value,
    String? label,
    bool? isImageType,
  }) =>
      AttributesDatum(
        id: id ?? this.id,
        name: name ?? this.name,
        options: options ?? this.options,
        position: position ?? this.position,
        visible: visible ?? this.visible,
        variation: variation ?? this.variation,
        isVisible: isVisible ?? this.isVisible,
        isVariation: isVariation ?? this.isVariation,
        isTaxonomy: isTaxonomy ?? this.isTaxonomy,
        value: value ?? this.value,
        label: label ?? this.label,
        isImageType: isImageType ?? this.isImageType,
      );

  factory AttributesDatum.fromJson(Map<String, dynamic> json) =>
      AttributesDatum(
        id: json["id"],
        name: json["name"],
        options: json["options"] == null
            ? []
            : List<Option>.from(
                json["options"]!.map((x) => Option.fromJson(x))),
        position: json["position"],
        visible: json["visible"],
        variation: json["variation"],
        isVisible: json["is_visible"],
        isVariation: json["is_variation"],
        isTaxonomy: json["is_taxonomy"],
        value: json["value"],
        label: json["label"],
        isImageType: json["is_image_type"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "options": options == null
            ? []
            : List<dynamic>.from(options!.map((x) => x.toJson())),
        "position": position,
        "visible": visible,
        "variation": variation,
        "is_visible": isVisible,
        "is_variation": isVariation,
        "is_taxonomy": isTaxonomy,
        "value": value,
        "label": label,
        "is_image_type": isImageType,
      };
}

class Option {
  int? termId;
  String? name;
  String? slug;
  int? termGroup;
  int? termTaxonomyId;
  String? taxonomy;
  String? description;
  int? parent;
  int? count;
  String? filter;

  Option({
    this.termId,
    this.name,
    this.slug,
    this.termGroup,
    this.termTaxonomyId,
    this.taxonomy,
    this.description,
    this.parent,
    this.count,
    this.filter,
  });

  Option copyWith({
    int? termId,
    String? name,
    String? slug,
    int? termGroup,
    int? termTaxonomyId,
    String? taxonomy,
    String? description,
    int? parent,
    int? count,
    String? filter,
  }) =>
      Option(
        termId: termId ?? this.termId,
        name: name ?? this.name,
        slug: slug ?? this.slug,
        termGroup: termGroup ?? this.termGroup,
        termTaxonomyId: termTaxonomyId ?? this.termTaxonomyId,
        taxonomy: taxonomy ?? this.taxonomy,
        description: description ?? this.description,
        parent: parent ?? this.parent,
        count: count ?? this.count,
        filter: filter ?? this.filter,
      );

  factory Option.fromJson(Map<String, dynamic> json) => Option(
        termId: json["term_id"],
        name: json["name"],
        slug: json["slug"],
        termGroup: json["term_group"],
        termTaxonomyId: json["term_taxonomy_id"],
        taxonomy: json["taxonomy"],
        description: json["description"],
        parent: json["parent"],
        count: json["count"],
        filter: json["filter"],
      );

  Map<String, dynamic> toJson() => {
        "term_id": termId,
        "name": name,
        "slug": slug,
        "term_group": termGroup,
        "term_taxonomy_id": termTaxonomyId,
        "taxonomy": taxonomy,
        "description": description,
        "parent": parent,
        "count": count,
        "filter": filter,
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

  Category copyWith({
    int? id,
    String? name,
    String? slug,
  }) =>
      Category(
        id: id ?? this.id,
        name: name ?? this.name,
        slug: slug ?? this.slug,
      );

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

class Image {
  int? id;
  DateTime? dateCreated;
  DateTime? dateCreatedGmt;
  DateTime? dateModified;
  DateTime? dateModifiedGmt;
  String? src;
  String? name;
  String? alt;

  Image({
    this.id,
    this.dateCreated,
    this.dateCreatedGmt,
    this.dateModified,
    this.dateModifiedGmt,
    this.src,
    this.name,
    this.alt,
  });

  Image copyWith({
    int? id,
    DateTime? dateCreated,
    DateTime? dateCreatedGmt,
    DateTime? dateModified,
    DateTime? dateModifiedGmt,
    String? src,
    String? name,
    String? alt,
  }) =>
      Image(
        id: id ?? this.id,
        dateCreated: dateCreated ?? this.dateCreated,
        dateCreatedGmt: dateCreatedGmt ?? this.dateCreatedGmt,
        dateModified: dateModified ?? this.dateModified,
        dateModifiedGmt: dateModifiedGmt ?? this.dateModifiedGmt,
        src: src ?? this.src,
        name: name ?? this.name,
        alt: alt ?? this.alt,
      );

  factory Image.fromJson(Map<String, dynamic> json) => Image(
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

class MetaDatum {
  int? id;
  String? key;
  dynamic value;

  MetaDatum({
    this.id,
    this.key,
    this.value,
  });

  MetaDatum copyWith({
    int? id,
    String? key,
    dynamic value,
  }) =>
      MetaDatum(
        id: id ?? this.id,
        key: key ?? this.key,
        value: value ?? this.value,
      );

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

class ValueClass {
  String? commissionMode;
  String? commissionPercent;
  String? commissionFixed;
  String? taxName;
  String? taxPercent;

  ValueClass({
    this.commissionMode,
    this.commissionPercent,
    this.commissionFixed,
    this.taxName,
    this.taxPercent,
  });

  ValueClass copyWith({
    String? commissionMode,
    String? commissionPercent,
    String? commissionFixed,
    String? taxName,
    String? taxPercent,
  }) =>
      ValueClass(
        commissionMode: commissionMode ?? this.commissionMode,
        commissionPercent: commissionPercent ?? this.commissionPercent,
        commissionFixed: commissionFixed ?? this.commissionFixed,
        taxName: taxName ?? this.taxName,
        taxPercent: taxPercent ?? this.taxPercent,
      );

  factory ValueClass.fromJson(Map<String, dynamic> json) => ValueClass(
        commissionMode: json["commission_mode"],
        commissionPercent: json["commission_percent"],
        commissionFixed: json["commission_fixed"],
        taxName: json["tax_name"],
        taxPercent: json["tax_percent"],
      );

  Map<String, dynamic> toJson() => {
        "commission_mode": commissionMode,
        "commission_percent": commissionPercent,
        "commission_fixed": commissionFixed,
        "tax_name": taxName,
        "tax_percent": taxPercent,
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
  int? vendorReviewsCount;
  dynamic vendorId;
  dynamic vendorDisplayName;
  dynamic vendorShopName;
  dynamic vendorEmail;
  dynamic vendorAddress;
  bool? disableVendor;
  dynamic isStoreOffline;
  dynamic emailVerified;
  dynamic settings;
  List<dynamic>? vendorAdditionalInfo;
  dynamic shopUrl;

  Store({
    this.vendorReviewsCount,
    this.vendorId,
    this.vendorDisplayName,
    this.vendorShopName,
    this.vendorEmail,
    this.vendorAddress,
    this.disableVendor,
    this.isStoreOffline,
    this.emailVerified,
    this.settings,
    this.vendorAdditionalInfo,
    this.shopUrl,
  });

  Store copyWith({
    int? vendorReviewsCount,
    String? vendorId,
    dynamic vendorDisplayName,
    String? vendorShopName,
    String? vendorEmail,
    String? vendorAddress,
    bool? disableVendor,
    String? isStoreOffline,
    String? emailVerified,
    dynamic settings,
    List<dynamic>? vendorAdditionalInfo,
    String? shopUrl,
  }) =>
      Store(
        vendorReviewsCount: vendorReviewsCount ?? this.vendorReviewsCount,
        vendorId: vendorId ?? this.vendorId,
        vendorDisplayName: vendorDisplayName ?? this.vendorDisplayName,
        vendorShopName: vendorShopName ?? this.vendorShopName,
        vendorEmail: vendorEmail ?? this.vendorEmail,
        vendorAddress: vendorAddress ?? this.vendorAddress,
        disableVendor: disableVendor ?? this.disableVendor,
        isStoreOffline: isStoreOffline ?? this.isStoreOffline,
        emailVerified: emailVerified ?? this.emailVerified,
        settings: settings ?? this.settings,
        vendorAdditionalInfo: vendorAdditionalInfo ?? this.vendorAdditionalInfo,
        shopUrl: shopUrl ?? this.shopUrl,
      );

  factory Store.fromJson(Map<String, dynamic> json) => Store(
        vendorReviewsCount: json["vendor_reviews_count"],
        vendorId: json["vendor_id"],
        vendorDisplayName: json["vendor_display_name"],
        vendorShopName: json["vendor_shop_name"],
        vendorEmail: json["vendor_email"],
        vendorAddress: json["vendor_address"],
        disableVendor: json["disable_vendor"],
        isStoreOffline: json["is_store_offline"],
        emailVerified: json["email_verified"],
        settings: json["settings"],
        vendorAdditionalInfo: null,
        shopUrl: json["shop_url"],
      );

  Map<String, dynamic> toJson() => {
        "vendor_reviews_count": vendorReviewsCount,
        "vendor_id": vendorId,
        "vendor_display_name": vendorDisplayName,
        "vendor_shop_name": vendorShopName,
        "vendor_email": vendorEmail,
        "vendor_address": vendorAddress,
        "disable_vendor": disableVendor,
        "is_store_offline": isStoreOffline,
        "email_verified": emailVerified,
        "settings": settings,
        "vendor_additional_info": vendorAdditionalInfo == null
            ? []
            : List<dynamic>.from(vendorAdditionalInfo!.map((x) => x)),
        "shop_url": shopUrl,
      };
}

class WcfmProductPolicyData {
  bool? visible;
  String? shippingPolicy;
  String? shippingPolicyHeading;
  String? refundPolicy;
  String? refundPolicyHeading;
  String? cancellationPolicy;
  String? cancellationPolicyHeading;
  String? tabTitle;

  WcfmProductPolicyData({
    this.visible,
    this.shippingPolicy,
    this.shippingPolicyHeading,
    this.refundPolicy,
    this.refundPolicyHeading,
    this.cancellationPolicy,
    this.cancellationPolicyHeading,
    this.tabTitle,
  });

  WcfmProductPolicyData copyWith({
    bool? visible,
    String? shippingPolicy,
    String? shippingPolicyHeading,
    String? refundPolicy,
    String? refundPolicyHeading,
    String? cancellationPolicy,
    String? cancellationPolicyHeading,
    String? tabTitle,
  }) =>
      WcfmProductPolicyData(
        visible: visible ?? this.visible,
        shippingPolicy: shippingPolicy ?? this.shippingPolicy,
        shippingPolicyHeading:
            shippingPolicyHeading ?? this.shippingPolicyHeading,
        refundPolicy: refundPolicy ?? this.refundPolicy,
        refundPolicyHeading: refundPolicyHeading ?? this.refundPolicyHeading,
        cancellationPolicy: cancellationPolicy ?? this.cancellationPolicy,
        cancellationPolicyHeading:
            cancellationPolicyHeading ?? this.cancellationPolicyHeading,
        tabTitle: tabTitle ?? this.tabTitle,
      );

  factory WcfmProductPolicyData.fromJson(Map<String, dynamic> json) =>
      WcfmProductPolicyData(
        visible: json["visible"],
        shippingPolicy: json["shipping_policy"],
        shippingPolicyHeading: json["shipping_policy_heading"],
        refundPolicy: json["refund_policy"],
        refundPolicyHeading: json["refund_policy_heading"],
        cancellationPolicy: json["cancellation_policy"],
        cancellationPolicyHeading: json["cancellation_policy_heading"],
        tabTitle: json["tab_title"],
      );

  Map<String, dynamic> toJson() => {
        "visible": visible,
        "shipping_policy": shippingPolicy,
        "shipping_policy_heading": shippingPolicyHeading,
        "refund_policy": refundPolicy,
        "refund_policy_heading": refundPolicyHeading,
        "cancellation_policy": cancellationPolicy,
        "cancellation_policy_heading": cancellationPolicyHeading,
        "tab_title": tabTitle,
      };
}


