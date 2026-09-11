// To parse this JSON data, do
//
//     final userCreateRequest = userCreateRequestFromJson(jsonString);

import 'dart:convert';

UserCreateRequest userCreateRequestFromJson(String str) => UserCreateRequest.fromJson(json.decode(str));

String userCreateRequestToJson(UserCreateRequest data) => json.encode(data.toJson());

class UserCreateRequest {
    String? email;
    String? password;
    String? firstName;
    String? lastName;
    String? username;
    UserCreateRequestBilling? billing;
    List<UserCreateMetaDatum>? metaData;

    UserCreateRequest({
        this.email,
        this.password,
        this.firstName,
        this.lastName,
        this.username,
        this.billing,
        this.metaData,
    });

    UserCreateRequest copyWith({
        String? email,
        String? password,
        String? firstName,
        String? lastName,
        String? username,
        UserCreateRequestBilling? billing,
        List<UserCreateMetaDatum>? metaData,
    }) => 
        UserCreateRequest(
            email: email ?? this.email,
            password: password ?? this.password,
            firstName: firstName ?? this.firstName,
            lastName: lastName ?? this.lastName,
            username: username ?? this.username,
            billing: billing ?? this.billing,
            metaData: metaData ?? this.metaData,
        );

    factory UserCreateRequest.fromJson(Map<String, dynamic> json) => UserCreateRequest(
        email: json["email"],
        password: json["password"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        username: json["username"],
        billing: json["billing"] == null ? null : UserCreateRequestBilling.fromJson(json["billing"]),
        metaData: json["meta_data"] == null ? [] : List<UserCreateMetaDatum>.from(json["meta_data"]!.map((x) => UserCreateMetaDatum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "email": email,
        "password": password,
        "first_name": firstName,
        "last_name": lastName,
        "username": username,
        "billing": billing?.toJson(),
        "meta_data": metaData == null ? [] : List<dynamic>.from(metaData!.map((x) => x.toJson())),
    };
}

class UserCreateRequestBilling {
    String? firstName;
    // String? lastName;
    // String? company;
    // String? address1;
    // String? address2;
    // String? city;
    // String? state;
    // String? postcode;
    // String? country;
    // String? email;
    String? phone;

    UserCreateRequestBilling({
        this.firstName,
        // this.lastName,
        // this.company,
        // this.address1,
        // this.address2,
        // this.city,
        // this.state,
        // this.postcode,
        // this.country,
        // this.email,
        this.phone,
    });

    UserCreateRequestBilling copyWith({
        String? firstName,
        // String? lastName,
        // String? company,
        // String? address1,
        // String? address2,
        // String? city,
        // String? state,
        // String? postcode,
        // String? country,
        // String? email,
        String? phone,
    }) => 
        UserCreateRequestBilling(
            firstName: firstName ?? this.firstName,
           // lastName: lastName ?? this.lastName,
            // company: company ?? this.company,
            // address1: address1 ?? this.address1,
            // address2: address2 ?? this.address2,
            // city: city ?? this.city,
            // state: state ?? this.state,
            // postcode: postcode ?? this.postcode,
            // country: country ?? this.country,
            // email: email ?? this.email,
            phone: phone ?? this.phone,
        );

    factory UserCreateRequestBilling.fromJson(Map<String, dynamic> json) => UserCreateRequestBilling(
        firstName: json["first_name"],
        // lastName: json["last_name"],
        // company: json["company"],
        // address1: json["address_1"],
        // address2: json["address_2"],
        // city: json["city"],
        // state: json["state"],
        // postcode: json["postcode"],
        // country: json["country"],
        // email: json["email"],
        phone: json["phone"],
    );

    Map<String, dynamic> toJson() => {
        "first_name": firstName,
        // "last_name": lastName,
        // "company": company,
        // "address_1": address1,
        // "address_2": address2,
        // "city": city,
        // "state": state,
        // "postcode": postcode,
        // "country": country,
        // "email": email,
        "phone": phone,
    };
}

class UserCreateMetaDatum {
    String? key;
    String? value;

    UserCreateMetaDatum({
        this.key,
        this.value,
    });

    UserCreateMetaDatum copyWith({
        String? key,
        String? value,
    }) => 
        UserCreateMetaDatum(
            key: key ?? this.key,
            value: value ?? this.value,
        );

    factory UserCreateMetaDatum.fromJson(Map<String, dynamic> json) => UserCreateMetaDatum(
        key: json["key"],
        value: json["value"],
    );

    Map<String, dynamic> toJson() => {
        "key": key,
        "value": value,
    };
}


