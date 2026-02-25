import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trael_app_abdelhamid/core/constants/app_constants.dart';
import 'package:trael_app_abdelhamid/core/utils/log_helper.dart';
import 'package:trael_app_abdelhamid/core/utils/pref_helper.dart';
import 'package:trael_app_abdelhamid/core/utils/toast_helper.dart';
import 'package:trael_app_abdelhamid/core/extensions/routes_extensions.dart';
import 'package:trael_app_abdelhamid/core/network/network_errors.dart';
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
          try {
            final token = PrefHelper.getAccessToken();

            if (token != null && token.isNotEmpty) {
              options.headers[HttpHeaders.authorizationHeader] =
                  'Bearer $token';
            }

            handler.next(options);
          } catch (e) {
            handler.next(options);
          }
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
    bool showErrorToast = false,
  }) {
    return _request(
      method: 'GET',
      endpoint: endpoint,
      queryParameters: queryParameters,
      showErrorToast: showErrorToast,
    );
  }

  Future<dynamic> post(
    String endpoint, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    bool showErrorToast = true,
  }) {
    return _request(
      method: 'POST',
      endpoint: endpoint,
      body: body,
      queryParameters: queryParameters,
      showErrorToast: showErrorToast,
    );
  }

  Future<dynamic> patch(
    String endpoint, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    bool showErrorToast = true,
  }) {
    return _request(
      method: 'PATCH',
      endpoint: endpoint,
      body: body,
      queryParameters: queryParameters,
      showErrorToast: showErrorToast,
    );
  }

  Future<dynamic> put(
    String endpoint, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    bool showErrorToast = true,
  }) {
    return _request(
      method: 'PUT',
      endpoint: endpoint,
      body: body,
      queryParameters: queryParameters,
      showErrorToast: showErrorToast,
    );
  }

  Future<dynamic> delete(
    String endpoint, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    bool showErrorToast = true,
  }) {
    return _request(
      method: 'DELETE',
      endpoint: endpoint,
      body: body,
      queryParameters: queryParameters,
      showErrorToast: showErrorToast,
    );
  }

  Future<dynamic> _request({
    required String method,
    required String endpoint,
    Object? body,
    Map<String, dynamic>? queryParameters,
    bool showErrorToast = false,
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
      String message = 'Something went wrong';

      // Parse error message from response
      if (data is Map<String, dynamic>) {
        if (data.containsKey('message') && data['message'] != null) {
          message = data['message'].toString();
        } else if (data.containsKey('error') && data['error'] != null) {
          message = data['error'].toString();
        }
      } else if (data is String && data.isNotEmpty) {
        message = data;
      } else {
        // Map DioException types to human-readable messages
        switch (error.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            message = 'Connection timed out. Please try again later.';
            break;
          case DioExceptionType.connectionError:
            message =
                'Unable to connect to the server. Please check your internet.';
            break;
          case DioExceptionType.badResponse:
            message = 'Server responded with an error ($statusCode).';
            break;
          case DioExceptionType.cancel:
            message = 'Request was cancelled.';
            break;
          default:
            message = 'A network error occurred. Please try again.';
        }
      }

      // Explicit log in terminal
      LogHelper.instance.error(
        "API Error: $method $endpoint",
        "[$statusCode] $message",
        error.stackTrace,
      );

      if (showErrorToast) {
        // Show human readable message to user
        ToastHelper.showError(message);
      }

      if (statusCode == HttpStatus.unauthorized) {
        throw UnauthorizedException(
          statusCode: statusCode,
          message: message,
          data: data,
        );
      }

      throw ApiException(statusCode: statusCode, message: message, data: data);
    } catch (e, stackTrace) {
      LogHelper.instance.error(
        "Unexpected Error during $method $endpoint",
        e,
        stackTrace,
      );
      if (showErrorToast) {
        ToastHelper.showError("An unexpected error occurred.");
      }
      rethrow;
    }
  }

  Future<void> _handleUnauthorized() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);

    UserAppRoute.goRouter.go(UserAppRoutes.signInScreen.path);
  }
}
