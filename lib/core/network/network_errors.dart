class ApiException implements Exception {
  ApiException({required this.statusCode, required this.message, this.data});

  final int statusCode;
  final String message;
  final dynamic data;

  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({
    required super.statusCode,
    required super.message,
    super.data,
  });
}