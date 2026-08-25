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
    final user = _asMap(json['user']);
    final tokens = _asMap(json['tokens']);

    return LoginResponseModel(
      id: _firstNonEmpty([
        json['_id'],
        json['id'],
        json['userId'],
        user?['_id'],
        user?['id'],
        user?['userId'],
      ]),
      email: _firstNonEmpty([json['email'], user?['email']]),
      phoneNumber: _firstNonEmpty([
        json['phoneNumber'],
        json['phone'],
        user?['phoneNumber'],
        user?['phone'],
      ]),
      travellerCode: _firstNonEmpty([
        json['travellerCode'],
        user?['travellerCode'],
      ]),
      accessToken: _firstNonEmpty([
        json['accessToken'],
        json['access_token'],
        json['token'],
        json['jwt'],
        tokens?['accessToken'],
        tokens?['access_token'],
        tokens?['token'],
      ]),
      refreshToken: _firstNonEmpty([
        json['refreshToken'],
        json['refresh_token'],
        tokens?['refreshToken'],
        tokens?['refresh_token'],
      ]),
    );
  }

  /// Merges top-level response fields with `data` so tokens can live in either place.
  factory LoginResponseModel.fromApiResponse(Map<String, dynamic> response) {
    final data = _asMap(response['data']);
    final merged = <String, dynamic>{...response};
    if (data != null) {
      merged.addAll(data);
    }
    return LoginResponseModel.fromJson(merged);
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static String _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty && text != 'null') return text;
    }
    return '';
  }
}
