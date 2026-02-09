class VerifyOtpResponseModel {
  final String? token;

  VerifyOtpResponseModel({this.token});

  factory VerifyOtpResponseModel.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponseModel(token: json['message']);
  }
} 