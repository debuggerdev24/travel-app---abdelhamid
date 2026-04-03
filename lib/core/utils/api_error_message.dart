import 'package:trael_app_abdelhamid/core/network/network_errors.dart';

/// Short, user-facing copy for API and parse failures (avoid exposing raw exceptions).
String userFacingApiError(Object error) {
  if (error is ApiException) return error.message;
  return 'Something went wrong. Please try again.';
}
