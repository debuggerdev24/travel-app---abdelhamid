import 'package:easy_localization/easy_localization.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:travel_app_abdelhamid/core/constants/app_constants.dart';
import 'package:travel_app_abdelhamid/core/utils/log_helper.dart';
import 'package:travel_app_abdelhamid/core/utils/pref_helper.dart';
import 'package:travel_app_abdelhamid/core/utils/toast_helper.dart';
import 'package:travel_app_abdelhamid/core/network/endpoints.dart';
import 'package:travel_app_abdelhamid/core/network/network_errors.dart';

class BaseApiService {
  BaseApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        // headers: <String, dynamic>{
        //   HttpHeaders.acceptHeader: 'application/json',
        //   HttpHeaders.contentTypeHeader: 'application/json',
        // },
        responseType: ResponseType.json,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            // Never send a stale Bearer token on login/register — the server may
            // reject the request with 401 before it even reads credentials.
            if (!_isAuthPath(options.uri.path)) {
              final token = PrefHelper.getAccessToken();

              if (token != null && token.isNotEmpty) {
                options.headers[HttpHeaders.authorizationHeader] =
                    'Bearer $token';
              }
            }
            handler.next(options);
          } catch (e) {
            handler.next(options);
          }
        },
        onError: (error, handler) async {
          final response = await _retryAfterRefresh(error);
          if (response != null) {
            return handler.resolve(response);
          }
          handler.next(error);
        },
      ),
    );

    _dio.interceptors.add(
      TalkerDioLogger(
        settings: const TalkerDioLoggerSettings(
          printRequestHeaders: true,
          printRequestData: true,
          printResponseData: true,
          printResponseHeaders: false,
          printResponseMessage: true,
          //* Expected 404s (e.g. empty CMS) still throw; LogHelper covers those.
          printErrorData: true,
          printErrorHeaders: true,
          printErrorMessage: true,
          // hiddenHeaders: {'Authorization'},
        ),
      ),
    );
  }

  static final BaseApiService instance = BaseApiService._internal();

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

        if (map['errors'] != null) {
          final errors = map['errors'];
          if (errors is Map) {
            final errorMessages = errors.values
                .expand((v) {
                  if (v is List) return v.map((e) => e.toString());
                  return [v.toString()];
                })
                .join('\n');
            if (errorMessages.isNotEmpty) {
              message = '$message\n$errorMessages';
            }
          } else {
            message = '$message\n$errors';
          }
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
        LogHelper.instance.debug('API POST multipart $endpoint → 400 $message');
        LogHelper.instance.debug('API POST multipart $endpoint → 400 $message');
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
        ToastHelper.showError("An unexpected error occurred.".tr());
      }
      rethrow;
    }
  }

  /// Multipart PATCH (e.g. profile image update).
  Future<dynamic> patchMultipart(
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

      final response = await _dio.patch<dynamic>(
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

        if (map['errors'] != null) {
          final errors = map['errors'];
          if (errors is Map) {
            final errorMessages = errors.values
                .expand((v) {
                  if (v is List) return v.map((e) => e.toString());
                  return [v.toString()];
                })
                .join('\n');
            if (errorMessages.isNotEmpty) {
              message = '$message\n$errorMessages';
            }
          } else {
            message = '$message\n$errors';
          }
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

      LogHelper.instance.error(
        "API Error: PATCH multipart $endpoint",
        "[$statusCode] $message",
        error.stackTrace,
      );

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
        "Unexpected Error during PATCH multipart $endpoint",
        e,
        stackTrace,
      );
      if (showErrorToast) {
        ToastHelper.showError("An unexpected error occurred.".tr());
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

        // Also check for specific field validation errors (e.g. {"errors": {"email": ["..."]}})
        if (map['errors'] != null) {
          final errors = map['errors'];
          if (errors is Map) {
            final errorMessages = errors.values
                .expand((v) {
                  if (v is List) return v.map((e) => e.toString());
                  return [v.toString()];
                })
                .join('\n');
            if (errorMessages.isNotEmpty) {
              message = '$message\n$errorMessages';
            }
          } else {
            message = '$message\n$errors';
          }
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

      // 400 / 404 + no toast: CMS "not found" or empty content; avoid ERROR-level noise
      if (!showErrorToast && (statusCode == 400 || statusCode == 404)) {
        LogHelper.instance.debug(
          'API $method $endpoint → $statusCode $message',
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
        ToastHelper.showError("An unexpected error occurred.".tr());
      }
      rethrow;
    }
  }

  /// One refresh at a time, so many failed calls do not all refresh together.
  Future<String?>? _refreshCall;

  static bool _isAuthPath(String path) {
    return path.contains('/auth/');
  }

  bool _isInvalidToken(DioException error) {
    if (error.response?.statusCode != 401) return false;
    final data = error.response?.data;
    if (data is! Map) return false;
    return data['message']?.toString().trim() == 'Invalid or Expired Token';
  }

  /// Gets a new access token, then sends the failed request one more time.
  Future<Response<dynamic>?> _retryAfterRefresh(DioException error) async {
    if (!_isInvalidToken(error)) return null;
    if (error.requestOptions.extra['retried'] == true) return null;
    if (error.requestOptions.path.contains('refresh-token')) return null;

    try {
      final accessToken = await _refreshAccessToken();
      if (accessToken == null || accessToken.isEmpty) return null;

      final options = error.requestOptions;
      options.extra['retried'] = true;
      options.headers[HttpHeaders.authorizationHeader] = 'Bearer $accessToken';
      return await _dio.fetch<dynamic>(options);
    } catch (e) {
      LogHelper.instance.error('Retry after refresh token failed', e);
      return null;
    }
  }

  Future<String?> _refreshAccessToken() async {
    if (_refreshCall != null) {
      return _refreshCall;
    }

    _refreshCall = _requestNewAccessToken();
    try {
      return await _refreshCall;
    } finally {
      _refreshCall = null;
    }
  }

  Future<String?> _requestNewAccessToken() async {
    final refreshToken = PrefHelper.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return null;

    try {
      final response = await _dio.post<dynamic>(
        '${AppConstants.apiPublicRoot}${Endpoints.refreshToken}',
        data: {'token': refreshToken},
      );
      final body = response.data;
      if (body is! Map || body['status'] != 1) return null;

      final data = body['data'];
      if (data is! Map) return null;

      final accessToken = data['accessToken']?.toString() ?? '';
      final newRefreshToken = data['refreshToken']?.toString() ?? '';
      if (accessToken.isEmpty) return null;

      await PrefHelper.saveAccessToken(accessToken);
      if (newRefreshToken.isNotEmpty) {
        await PrefHelper.saveRefreshToken(newRefreshToken);
      }
      return accessToken;
    } catch (e) {
      LogHelper.instance.error('Refresh token API failed', e);
      return null;
    }
  }
}
