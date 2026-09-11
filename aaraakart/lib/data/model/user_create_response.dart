class CustomerCreateResult {
  final UserCreateResponseModel? data;
  final String? error;

  CustomerCreateResult.success(this.data) : error = null;
  CustomerCreateResult.failure(this.error) : data = null;
}

class UserCreateResponseModel {
  UserCreateResponseModel({
    required this.id,
    required this.dateCreated,
    required this.dateCreatedGmt,
    required this.dateModified,
    required this.dateModifiedGmt,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.username,
    required this.billing,
    required this.shipping,
    required this.isPayingCustomer,
    required this.avatarUrl,
    // required this.metaData,
    // required this.links,
  });

  final int? id;
  final DateTime? dateCreated;
  final DateTime? dateCreatedGmt;
  final DateTime? dateModified;
  final DateTime? dateModifiedGmt;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? role;
  final String? username;
  final Ing? billing;
  final Ing? shipping;
  final bool? isPayingCustomer;
  final String? avatarUrl;
  // final List<MetaDatum> metaData;
  // final Links? links;

  factory UserCreateResponseModel.fromJson(Map<String, dynamic> json) {
    return UserCreateResponseModel(
      id: json["id"],
      dateCreated: DateTime.tryParse(json["date_created"] ?? ""),
      dateCreatedGmt: DateTime.tryParse(json["date_created_gmt"] ?? ""),
      dateModified: DateTime.tryParse(json["date_modified"] ?? ""),
      dateModifiedGmt: DateTime.tryParse(json["date_modified_gmt"] ?? ""),
      email: json["email"],
      firstName: json["first_name"],
      lastName: json["last_name"],
      role: json["role"],
      username: json["username"],
      billing: json["billing"] == null ? null : Ing.fromJson(json["billing"]),
      shipping:
          json["shipping"] == null ? null : Ing.fromJson(json["shipping"]),
      isPayingCustomer: json["is_paying_customer"],
      avatarUrl: json["avatar_url"],
      // metaData: json["meta_data"] == null
      //     ? []
      //     : List<MetaDatum>.from(
      //         json["meta_data"]!.map((x) => MetaDatum.fromJson(x))),
      // links: json["_links"] == null ? null : Links.fromJson(json["_links"]),
    );
  }
}

class Ing {
  Ing({
    required this.firstName,
    required this.lastName,
    required this.company,
    required this.address1,
    required this.address2,
    required this.city,
    required this.postcode,
    required this.country,
    required this.state,
    required this.email,
    required this.phone,
  });

  final String? firstName;
  final String? lastName;
  final String? company;
  final String? address1;
  final String? address2;
  final String? city;
  final String? postcode;
  final String? country;
  final String? state;
  final String? email;
  final String? phone;

  factory Ing.fromJson(Map<String, dynamic> json) {
    return Ing(
      firstName: json["first_name"],
      lastName: json["last_name"],
      company: json["company"],
      address1: json["address_1"],
      address2: json["address_2"],
      city: json["city"],
      postcode: json["postcode"],
      country: json["country"],
      state: json["state"],
      email: json["email"],
      phone: json["phone"],
    );
  }
}

class Links {
  Links({
    required this.self,
    required this.collection,
  });

  final List<Self> self;
  final List<Collection> collection;

  factory Links.fromJson(Map<String, dynamic> json) {
    return Links(
      self: json["self"] == null
          ? []
          : List<Self>.from(json["self"]!.map((x) => Self.fromJson(x))),
      collection: json["collection"] == null
          ? []
          : List<Collection>.from(
              json["collection"]!.map((x) => Collection.fromJson(x))),
    );
  }
}

class Collection {
  Collection({
    required this.href,
  });

  final String? href;

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      href: json["href"],
    );
  }
}

class Self {
  Self({
    required this.href,
    required this.targetHints,
  });

  final String? href;
  final TargetHints? targetHints;

  factory Self.fromJson(Map<String, dynamic> json) {
    return Self(
      href: json["href"],
      targetHints: json["targetHints"] == null
          ? null
          : TargetHints.fromJson(json["targetHints"]),
    );
  }
}

class TargetHints {
  TargetHints({
    required this.allow,
  });

  final List<String> allow;

  factory TargetHints.fromJson(Map<String, dynamic> json) {
    return TargetHints(
      allow: json["allow"] == null
          ? []
          : List<String>.from(json["allow"]!.map((x) => x)),
    );
  }
}

class MetaDatum {
  MetaDatum({
    required this.id,
    required this.key,
    required this.value,
  });

  final int? id;
  final String? key;
  final String? value;

  factory MetaDatum.fromJson(Map<String, dynamic> json) {
    return MetaDatum(
      id: json["id"],
      key: json["key"],
      value: json["value"],
    );
  }
}


