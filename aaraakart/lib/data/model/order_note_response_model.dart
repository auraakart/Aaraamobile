// To parse this JSON data, do
//
//     final orderNoteResponeModel = orderNoteResponeModelFromJson(jsonString);

import 'dart:convert';

OrderNoteResponeModel orderNoteResponeModelFromJson(String str) => OrderNoteResponeModel.fromJson(json.decode(str));

String orderNoteResponeModelToJson(OrderNoteResponeModel data) => json.encode(data.toJson());

class OrderNoteResponeModel {
    List<OrderNoteProduct>? products;
    int? total;
    int? totalPages;
    int? perPage;
    int? currentPage;

    OrderNoteResponeModel({
        this.products,
        this.total,
        this.totalPages,
        this.perPage,
        this.currentPage,
    });

    OrderNoteResponeModel copyWith({
        List<OrderNoteProduct>? products,
        int? total,
        int? totalPages,
        int? perPage,
        int? currentPage,
    }) => 
        OrderNoteResponeModel(
            products: products ?? this.products,
            total: total ?? this.total,
            totalPages: totalPages ?? this.totalPages,
            perPage: perPage ?? this.perPage,
            currentPage: currentPage ?? this.currentPage,
        );

    factory OrderNoteResponeModel.fromJson(Map<String, dynamic> json) => OrderNoteResponeModel(
        products: json["products"] == null ? [] : List<OrderNoteProduct>.from(json["products"]!.map((x) => OrderNoteProduct.fromJson(x))),
        total: json["total"],
        totalPages: json["total_pages"],
        perPage: json["per_page"],
        currentPage: json["current_page"],
    );

    Map<String, dynamic> toJson() => {
        "products": products == null ? [] : List<dynamic>.from(products!.map((x) => x.toJson())),
        "total": total,
        "total_pages": totalPages,
        "per_page": perPage,
        "current_page": currentPage,
    };
}

class OrderNoteProduct {
    int? id;
    String? author;
    DateTime? dateCreated;
    DateTime? dateCreatedGmt;
    String? note;
    bool? customerNote;
    Links? links;

    OrderNoteProduct({
        this.id,
        this.author,
        this.dateCreated,
        this.dateCreatedGmt,
        this.note,
        this.customerNote,
        this.links,
    });

    OrderNoteProduct copyWith({
        int? id,
        String? author,
        DateTime? dateCreated,
        DateTime? dateCreatedGmt,
        String? note,
        bool? customerNote,
        Links? links,
    }) => 
        OrderNoteProduct(
            id: id ?? this.id,
            author: author ?? this.author,
            dateCreated: dateCreated ?? this.dateCreated,
            dateCreatedGmt: dateCreatedGmt ?? this.dateCreatedGmt,
            note: note ?? this.note,
            customerNote: customerNote ?? this.customerNote,
            links: links ?? this.links,
        );

    factory OrderNoteProduct.fromJson(Map<String, dynamic> json) => OrderNoteProduct(
        id: json["id"],
        author: json["author"],
        dateCreated: json["date_created"] == null ? null : DateTime.parse(json["date_created"]),
        dateCreatedGmt: json["date_created_gmt"] == null ? null : DateTime.parse(json["date_created_gmt"]),
        note: json["note"],
        customerNote: json["customer_note"],
        links: json["_links"] == null ? null : Links.fromJson(json["_links"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "author": author,
        "date_created": dateCreated?.toIso8601String(),
        "date_created_gmt": dateCreatedGmt?.toIso8601String(),
        "note": note,
        "customer_note": customerNote,
        "_links": links?.toJson(),
    };
}

class Links {
    List<Self>? self;
    List<Collection>? collection;
    List<Collection>? up;

    Links({
        this.self,
        this.collection,
        this.up,
    });

    Links copyWith({
        List<Self>? self,
        List<Collection>? collection,
        List<Collection>? up,
    }) => 
        Links(
            self: self ?? this.self,
            collection: collection ?? this.collection,
            up: up ?? this.up,
        );

    factory Links.fromJson(Map<String, dynamic> json) => Links(
        self: json["self"] == null ? [] : List<Self>.from(json["self"]!.map((x) => Self.fromJson(x))),
        collection: json["collection"] == null ? [] : List<Collection>.from(json["collection"]!.map((x) => Collection.fromJson(x))),
        up: json["up"] == null ? [] : List<Collection>.from(json["up"]!.map((x) => Collection.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "self": self == null ? [] : List<dynamic>.from(self!.map((x) => x.toJson())),
        "collection": collection == null ? [] : List<dynamic>.from(collection!.map((x) => x.toJson())),
        "up": up == null ? [] : List<dynamic>.from(up!.map((x) => x.toJson())),
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


