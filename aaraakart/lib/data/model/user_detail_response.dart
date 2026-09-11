class UserDetail {
  final String? phoneNumber;
  final bool? isVerified;
  final String? name;
  final String? email;
  final String? customerID;

  UserDetail({
    required this.phoneNumber,
    required this.isVerified,
    required this.name,
    required this.email,
    this.customerID,
  });

  // Convert from JSON
  factory UserDetail.fromJson(Map<String, dynamic> json) {
    return UserDetail(
      phoneNumber: json["phoneNumber"],
      isVerified: json["isVerified"],
      name: json["name"],
      email: json["email"],
      customerID: json["customerID"],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      "phoneNumber": phoneNumber,
      "isVerified": isVerified,
      "name": name,
      "email": email,
      "customerID": customerID,
    };
  }
}


