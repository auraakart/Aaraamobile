import 'dart:convert';

List<GetAddressResponse> getAddressResponseFromJson(String str) =>
    List<GetAddressResponse>.from(
      json.decode(str).map((x) => GetAddressResponse.fromJson(x)),
    );

String getAddressResponseToJson(List<GetAddressResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetAddressResponse {
  int? id;
  String? name;
  String? mobileNumber;
  int? customerId;
  String? label;
  String? address1;
  String? address2;
  String? landmark;
  String? city;
  String? state;
  String? postcode;
  String? country;
  String? latitude;
  String? longitude;
  int? isPrimary;
  String? createdAt;
  String? updatedAt;

  GetAddressResponse({
    this.id,
    this.name,
    this.mobileNumber,
    this.customerId,
    this.label,
    this.address1,
    this.address2,
    this.landmark,
    this.city,
    this.state,
    this.postcode,
    this.country,
    this.latitude,
    this.longitude,
    this.isPrimary,
    this.createdAt,
    this.updatedAt,
  });

  GetAddressResponse copyWith({
    int? id,
    String? name,
    String? mobileNumber,
    int? customerId,
    String? label,
    String? address1,
    String? address2,
    String? landmark,
    String? city,
    String? state,
    String? postcode,
    String? country,
    String? latitude,
    String? longitude,
    int? isPrimary,
    String? createdAt,
    String? updatedAt,
  }) =>
      GetAddressResponse(
        id: id ?? this.id,
        name: name ?? this.name,
        mobileNumber: mobileNumber ?? this.mobileNumber,
        customerId: customerId ?? this.customerId,
        label: label ?? this.label,
        address1: address1 ?? this.address1,
        address2: address2 ?? this.address2,
        landmark: landmark ?? this.landmark,
        city: city ?? this.city,
        state: state ?? this.state,
        postcode: postcode ?? this.postcode,
        country: country ?? this.country,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        isPrimary: isPrimary ?? this.isPrimary,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  factory GetAddressResponse.fromJson(Map<String, dynamic> json) =>
      GetAddressResponse(
        id: json["id"],
        name: json["name"],
        mobileNumber: json["mobile_number"],
        customerId: json["customer_id"],
        label: json["label"],
        address1: json["address_1"],
        address2: json["address_2"],
        landmark: json["landmark"],
        city: json["city"],
        state: json["state"],
        postcode: json["postcode"],
        country: json["country"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        isPrimary: json["is_primary"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "mobile_number": mobileNumber,
        "customer_id": customerId,
        "label": label,
        "address_1": address1,
        "address_2": address2,
        "landmark": landmark,
        "city": city,
        "state": state,
        "postcode": postcode,
        "country": country,
        "latitude": latitude,
        "longitude": longitude,
        "is_primary": isPrimary,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}


