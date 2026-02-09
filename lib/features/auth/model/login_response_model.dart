class LoginResponseModel {
  final String email;
  final String phoneNumber;
  final String travellerCode;
  final String accessToken;
  final String refreshToken;

  LoginResponseModel({
    required this.email,
    required this.phoneNumber,
    required this.travellerCode,
    required this.accessToken,
    required this.refreshToken,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      travellerCode: json['travellerCode'],
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }
}
