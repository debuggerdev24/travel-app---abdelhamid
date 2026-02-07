class UserModel {
  final String id;
  final String email;
  final String phoneNumber;
  final String travellerCode;

  UserModel({
    required this.id,
    required this.email,
    required this.phoneNumber,
    required this.travellerCode,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      travellerCode: json['travellerCode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'phoneNumber': phoneNumber,
      'travellerCode': travellerCode,
    };
  }
}
