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

  /// Multipart upload (e.g. `photo` file). Do not set JSON `Content-Type`; Dio sets boundary.
  Future<dynamic> postMultipart(
    String endpoint, {
    required Map<String, String> fields,
    required String fileFieldName,
    required String filePath,
    Map<String, dynamic>? queryParameters,
    bool showErrorToast = true,
  }) async {
    try {
      final multipartFile = await MultipartFile.fromFile(
        filePath,
        filename: _basenameFromPath(filePath),
      );
      final formData = FormData.fromMap({
        ...fields,
        fileFieldName: multipartFile,
      });

      final response = await _dio.post<dynamic>(
        endpoint,
        data: formData,
        queryParameters: queryParameters,
        options: Options(
          contentType: null,
          headers: <String, dynamic>{
            HttpHeaders.acceptHeader: 'application/json',
          },
        ),
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

      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        if (map['message'] != null) {
          message = map['message'].toString();
        } else if (map['error'] != null) {
          message = map['error'].toString();
        }
      } else if (data is String && data.isNotEmpty) {
        message = data;
      } else {
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

      if (!showErrorToast && statusCode == 400) {
        LogHelper.instance.debug(
          'API POST multipart $endpoint → 400 $message',
        );
      } else {
        LogHelper.instance.error(
          "API Error: POST multipart $endpoint",
          "[$statusCode] $message",
          error.stackTrace,
        );
      }

      if (showErrorToast) {
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
    } on ApiException {
      rethrow;
    } catch (e, stackTrace) {
      LogHelper.instance.error(
        "Unexpected Error during POST multipart $endpoint",
        e,
        stackTrace,
      );
      if (showErrorToast) {
        ToastHelper.showError("An unexpected error occurred.");
      }
      rethrow;
    }
  }

  static String _basenameFromPath(String path) {
    final i = path.replaceAll('\\', '/').lastIndexOf('/');
    return i >= 0 ? path.substring(i + 1) : path;
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

      // Parse error message from response (Dio JSON is often Map<dynamic, dynamic>)
      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        if (map['message'] != null) {
          message = map['message'].toString();
        } else if (map['error'] != null) {
          message = map['error'].toString();
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

      // 400 + no toast: often "no data" from CMS endpoints; avoid ERROR-level noise
      if (!showErrorToast && statusCode == 400) {
        LogHelper.instance.debug(
          'API $method $endpoint → 400 $message',
        );
      } else {
        LogHelper.instance.error(
          "API Error: $method $endpoint",
          "[$statusCode] $message",
          error.stackTrace,
        );
      }

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
    } on ApiException {
      // Thrown from Dio handler above; do not log as "unexpected"
      rethrow;
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
