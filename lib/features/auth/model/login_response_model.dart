class LoginResponseModel {
  /// Mongo user id (backend field `_id`).
  final String id;
  final String email;
  final String phoneNumber;
  final String travellerCode;
  final String accessToken;
  final String refreshToken;

  LoginResponseModel({
    required this.id,
    required this.email,
    required this.phoneNumber,
    required this.travellerCode,
    required this.accessToken,
    required this.refreshToken,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      id: json['_id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      travellerCode: json['travellerCode']?.toString() ?? '',
      accessToken: json['accessToken']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? '',
    );
  }
}
