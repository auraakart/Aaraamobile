// To parse this JSON data, do
//
//     final orderCreateResponseModel = orderCreateResponseModelFromJson(jsonString);

import 'dart:convert';

OrderCreateResponseModel orderCreateResponseModelFromJson(String str) => OrderCreateResponseModel.fromJson(json.decode(str));

String orderCreateResponseModelToJson(OrderCreateResponseModel data) => json.encode(data.toJson());

class OrderCreateResponseModel {
    OrderCreateProducts? products;
    dynamic total;
    dynamic totalPages;
    dynamic perPage;
    dynamic currentPage;
    Links? links;
    String? status;

    OrderCreateResponseModel({
        this.products,
        this.total,
        this.totalPages,
        this.perPage,
        this.currentPage,
        this.links,
        this.status
    });

    OrderCreateResponseModel copyWith({
        OrderCreateProducts? products,
        dynamic total,
        dynamic totalPages,
        dynamic perPage,
        dynamic currentPage,
        Links? links,
        String? status
    }) => 
        OrderCreateResponseModel(
            products: products ?? this.products,
            total: total ?? this.total,
            totalPages: totalPages ?? this.totalPages,
            perPage: perPage ?? this.perPage,
            currentPage: currentPage ?? this.currentPage,
            links: links ?? this.links,
            status:status ??  this.status
        );

    factory OrderCreateResponseModel.fromJson(Map<String, dynamic> json) => OrderCreateResponseModel(
        products: json["products"] == null ? null : OrderCreateProducts.fromJson(json["products"]),
        total: json["total"],
        totalPages: json["total_pages"],
        perPage: json["per_page"],
        currentPage: json["current_page"],
        status: json["status"],
        links: json["_links"] == null ? null : Links.fromJson(json["_links"]),
    );

    Map<String, dynamic> toJson() => {
        "products": products?.toJson(),
        "total": total,
        "total_pages": totalPages,
        "per_page": perPage,
        "current_page": currentPage,
        "_links": links?.toJson(),
        "status":status
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
        self: json["self"] == null ? [] : List<Self>.from(json["self"]!.map((x) => Self.fromJson(x))),
        collection: json["collection"] == null ? [] : List<Collection>.from(json["collection"]!.map((x) => Collection.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "self": self == null ? [] : List<dynamic>.from(self!.map((x) => x.toJson())),
        "collection": collection == null ? [] : List<dynamic>.from(collection!.map((x) => x.toJson())),
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
        targetHints: json["targetHints"] == null ? null : TargetHints.fromJson(json["targetHints"]),
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
        allow: json["allow"] == null ? [] : List<String>.from(json["allow"]!.map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "allow": allow == null ? [] : List<dynamic>.from(allow!.map((x) => x)),
    };
}

class OrderCreateProducts {
    int? id;
    int? parentId;
    String? status;
    String? currency;
    String? version;
    bool? pricesIncludeTax;
    DateTime? dateCreated;
    DateTime? dateModified;
    dynamic discountTotal;
    dynamic discountTax;
    dynamic shippingTotal;
    dynamic shippingTax;
    dynamic cartTax;
    dynamic total;
    dynamic totalTax;
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
    List<MetaDatum>? metaData;
    List<LineItem>? lineItems;
    List<dynamic>? taxLines;
    List<dynamic>? shippingLines;
    List<dynamic>? feeLines;
    List<dynamic>? couponLines;
    List<dynamic>? refunds;
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

    OrderCreateProducts({
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
    });

    OrderCreateProducts copyWith({
        int? id,
        int? parentId,
        String? status,
        String? currency,
        String? version,
        bool? pricesIncludeTax,
        DateTime? dateCreated,
        DateTime? dateModified,
        dynamic discountTotal,
        dynamic discountTax,
        dynamic shippingTotal,
        dynamic shippingTax,
        dynamic cartTax,
        dynamic total,
        dynamic totalTax,
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
        List<MetaDatum>? metaData,
        List<LineItem>? lineItems,
        List<dynamic>? taxLines,
        List<dynamic>? shippingLines,
        List<dynamic>? feeLines,
        List<dynamic>? couponLines,
        List<dynamic>? refunds,
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
    }) => 
        OrderCreateProducts(
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
        );

    factory OrderCreateProducts.fromJson(Map<String, dynamic> json) => OrderCreateProducts(
        id: json["id"],
        parentId: json["parent_id"],
        status: json["status"],
        currency: json["currency"],
        version: json["version"],
        pricesIncludeTax: json["prices_include_tax"],
        dateCreated: json["date_created"] == null ? null : DateTime.parse(json["date_created"]),
        dateModified: json["date_modified"] == null ? null : DateTime.parse(json["date_modified"]),
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
        shipping: json["shipping"] == null ? null : Ing.fromJson(json["shipping"]),
        paymentMethod: json["payment_method"],
        paymentMethodTitle: json["payment_method_title"],
        transactionId: json["transaction_id"],
        customerIpAddress: json["customer_ip_address"],
        customerUserAgent: json["customer_user_agent"],
        createdVia: json["created_via"],
        customerNote: json["customer_note"],
        dateCompleted: json["date_completed"] == null ? null : DateTime.parse(json["date_completed"]),
        datePaid: json["date_paid"] == null ? null : DateTime.parse(json["date_paid"]),
        cartHash: json["cart_hash"],
        number: json["number"],
        metaData: json["meta_data"] == null ? [] : List<MetaDatum>.from(json["meta_data"]!.map((x) => MetaDatum.fromJson(x))),
        lineItems: json["line_items"] == null ? [] : List<LineItem>.from(json["line_items"]!.map((x) => LineItem.fromJson(x))),
        taxLines: json["tax_lines"] == null ? [] : List<dynamic>.from(json["tax_lines"]!.map((x) => x)),
        shippingLines: json["shipping_lines"] == null ? [] : List<dynamic>.from(json["shipping_lines"]!.map((x) => x)),
        feeLines: json["fee_lines"] == null ? [] : List<dynamic>.from(json["fee_lines"]!.map((x) => x)),
        couponLines: json["coupon_lines"] == null ? [] : List<dynamic>.from(json["coupon_lines"]!.map((x) => x)),
        refunds: json["refunds"] == null ? [] : List<dynamic>.from(json["refunds"]!.map((x) => x)),
        paymentUrl: json["payment_url"],
        isEditable: json["is_editable"],
        needsPayment: json["needs_payment"],
        needsProcessing: json["needs_processing"],
        dateCreatedGmt: json["date_created_gmt"] == null ? null : DateTime.parse(json["date_created_gmt"]),
        dateModifiedGmt: json["date_modified_gmt"] == null ? null : DateTime.parse(json["date_modified_gmt"]),
        dateCompletedGmt: json["date_completed_gmt"] == null ? null : DateTime.parse(json["date_completed_gmt"]),
        datePaidGmt: json["date_paid_gmt"] == null ? null : DateTime.parse(json["date_paid_gmt"]),
        currencySymbol: json["currency_symbol"],
        deliveryStatus: json["delivery_status"],
    );

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
        "meta_data": metaData == null ? [] : List<dynamic>.from(metaData!.map((x) => x.toJson())),
        "line_items": lineItems == null ? [] : List<dynamic>.from(lineItems!.map((x) => x.toJson())),
        "tax_lines": taxLines == null ? [] : List<dynamic>.from(taxLines!.map((x) => x)),
        "shipping_lines": shippingLines == null ? [] : List<dynamic>.from(shippingLines!.map((x) => x)),
        "fee_lines": feeLines == null ? [] : List<dynamic>.from(feeLines!.map((x) => x)),
        "coupon_lines": couponLines == null ? [] : List<dynamic>.from(couponLines!.map((x) => x)),
        "refunds": refunds == null ? [] : List<dynamic>.from(refunds!.map((x) => x)),
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
    dynamic id;
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
    List<dynamic>? metaData;
    dynamic sku;
    dynamic price;
    Image? image;
    dynamic parentName;
    dynamic productData;

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
       dynamic id,
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
        List<dynamic>? metaData,
        dynamic sku,
        dynamic price,
        Image? image,
        dynamic parentName,
        dynamic productData,
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
        taxes: json["taxes"] == null ? [] : List<dynamic>.from(json["taxes"]!.map((x) => x)),
        metaData: json["meta_data"] == null ? [] : List<dynamic>.from(json["meta_data"]!.map((x) => x)),
        sku: json["sku"],
        price: json["price"],
        image: json["image"] == null ? null : Image.fromJson(json["image"]),
        parentName: json["parent_name"],
        productData: json["product_data"],
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
        "meta_data": metaData == null ? [] : List<dynamic>.from(metaData!.map((x) => x)),
        "sku": sku,
        "price": price,
        "image": image?.toJson(),
        "parent_name": parentName,
        "product_data": productData,
    };
}

class Image {
    dynamic id;
    String? src;

    Image({
        this.id,
        this.src,
    });

    Image copyWith({
       dynamic id,
        String? src,
    }) => 
        Image(
            id: id ?? this.id,
            src: src ?? this.src,
        );

    factory Image.fromJson(Map<String, dynamic> json) => Image(
        id: json["id"],
        src: json["src"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "src": src,
    };
}

class MetaDatum {
    dynamic id;
    String? key;
    dynamic value;

    MetaDatum({
        this.id,
        this.key,
        this.value,
    });

    MetaDatum copyWith({
        dynamic id,
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
    String? displayShippingAddress;
    String? displayEmail;
    String? displayPhone;
    String? displayDate;
    String? displayNumber;
    String? headerLogo;
    String? headerLogoHeight;
    String? vatNumber;
    String? cocNumber;
    Extra1? shopName;
    String? shopPhoneNumber;
    Extra1? shopAddress;
    Extra1? footer;
    Extra1? extra1;
    Extra1? extra2;
    Extra1? extra3;
    int? number;
    String? formattedNumber;
    dynamic prefix;
    dynamic suffix;
    String? documentType;
    int? orderId;
    dynamic padding;

    ValueClass({
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

    ValueClass copyWith({
        String? displayShippingAddress,
        String? displayEmail,
        String? displayPhone,
        String? displayDate,
        String? displayNumber,
        String? headerLogo,
        String? headerLogoHeight,
        String? vatNumber,
        String? cocNumber,
        Extra1? shopName,
        String? shopPhoneNumber,
        Extra1? shopAddress,
        Extra1? footer,
        Extra1? extra1,
        Extra1? extra2,
        Extra1? extra3,
        int? number,
        String? formattedNumber,
        dynamic prefix,
        dynamic suffix,
        String? documentType,
        int? orderId,
        dynamic padding,
    }) => 
        ValueClass(
            displayShippingAddress: displayShippingAddress ?? this.displayShippingAddress,
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

    factory ValueClass.fromJson(Map<String, dynamic> json) => ValueClass(
        displayShippingAddress: json["display_shipping_address"],
        displayEmail: json["display_email"],
        displayPhone: json["display_phone"],
        displayDate: json["display_date"],
        displayNumber: json["display_number"],
        headerLogo: json["header_logo"],
        headerLogoHeight: json["header_logo_height"],
        vatNumber: json["vat_number"],
        cocNumber: json["coc_number"],
        shopName: json["shop_name"] == null ? null : Extra1.fromJson(json["shop_name"]),
        shopPhoneNumber: json["shop_phone_number"],
        shopAddress: json["shop_address"] == null ? null : Extra1.fromJson(json["shop_address"]),
        footer: json["footer"] == null ? null : Extra1.fromJson(json["footer"]),
        extra1: json["extra_1"] == null ? null : Extra1.fromJson(json["extra_1"]),
        extra2: json["extra_2"] == null ? null : Extra1.fromJson(json["extra_2"]),
        extra3: json["extra_3"] == null ? null : Extra1.fromJson(json["extra_3"]),
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

class Extra1 {
    String? extra1Default;

    Extra1({
        this.extra1Default,
    });

    Extra1 copyWith({
        String? extra1Default,
    }) => 
        Extra1(
            extra1Default: extra1Default ?? this.extra1Default,
        );

    factory Extra1.fromJson(Map<String, dynamic> json) => Extra1(
        extra1Default: json["default"],
    );

    Map<String, dynamic> toJson() => {
        "default": extra1Default,
    };
}


