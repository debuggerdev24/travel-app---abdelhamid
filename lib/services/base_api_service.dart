import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trael_app_abdelhamid/core/constants/app_constants.dart';
import 'package:trael_app_abdelhamid/core/extensions/routes_extensions.dart';
import 'package:trael_app_abdelhamid/routes/go_routes.dart';
import 'package:trael_app_abdelhamid/routes/user_routes.dart';

class BaseApiService {
  BaseApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: <String, dynamic>{
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        responseType: ResponseType.json,
      ),
    );

    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(_authTokenKey);

          if (token != null && token.isNotEmpty) {
            options.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
          }

          handler.next(options);
        },
        onError: (DioException error, handler) async {
          final statusCode = error.response?.statusCode;

          if (statusCode == HttpStatus.unauthorized) {
            await _handleUnauthorized();
          }

          handler.next(error);
        },
      ),
    );
  }

  static final BaseApiService instance = BaseApiService._internal();

  static const String _authTokenKey = 'auth_token';

  late final Dio _dio;

  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _request(
      method: 'GET',
      endpoint: endpoint,
      queryParameters: queryParameters,
    );
  }

  Future<dynamic> post(
    String endpoint, {
    Object? body,
    Map<String, dynamic>? queryParameters,
  }) {
    return _request(
      method: 'POST',
      endpoint: endpoint,
      body: body,
      queryParameters: queryParameters,
    );
  }

  Future<dynamic> patch(
    String endpoint, {
    Object? body,
    Map<String, dynamic>? queryParameters,
  }) {
    return _request(
      method: 'PATCH',
      endpoint: endpoint,
      body: body,
      queryParameters: queryParameters,
    );
  }

  Future<dynamic> put(
    String endpoint, {
    Object? body,
    Map<String, dynamic>? queryParameters,
  }) {
    return _request(
      method: 'PUT',
      endpoint: endpoint,
      body: body,
      queryParameters: queryParameters,
    );
  }

  Future<dynamic> delete(
    String endpoint, {
    Object? body,
    Map<String, dynamic>? queryParameters,
  }) {
    return _request(
      method: 'DELETE',
      endpoint: endpoint,
      body: body,
      queryParameters: queryParameters,
    );
  }

  Future<dynamic> _request({
    required String method,
    required String endpoint,
    Object? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.request<dynamic>(
        endpoint,
        data: body,
        queryParameters: queryParameters,
        options: Options(method: method),
      );

      final statusCode = response.statusCode ?? 0;

      if (statusCode < 200 || statusCode >= 300) {
        throw ApiException(
          statusCode: statusCode,
          message: 'Request failed with status $statusCode',
          data: response.data,
        );
      }

      return response.data;
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode ?? -1;
      final data = error.response?.data;
      String message = 'Something went wrong ($statusCode)';

      if (data is Map<String, dynamic> && data.containsKey('message')) {
        message = data['message'].toString();
      } else if (data is String && data.isNotEmpty) {
        message = data;
      } else if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        message = 'Connection timed out. Please check your internet.';
      } else if (error.type == DioExceptionType.connectionError) {
        message = 'No internet connection.';
      }

      if (statusCode == HttpStatus.unauthorized) {
        throw UnauthorizedException(
          statusCode: statusCode,
          message: message,
          data: data,
        );
      }

      throw ApiException(statusCode: statusCode, message: message, data: data);
    }
  }

  Future<void> _handleUnauthorized() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);

    UserAppRoute.goRouter.go(UserAppRoutes.signInScreen.path);
  }

  static Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
  }

  static Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
  }
}

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
