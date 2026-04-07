import 'package:trael_app_abdelhamid/core/constants/app_constants.dart';

/// Turns `/uploads/...` into a full URL using [AppConstants.imageBaseUrl].
String? resolveMediaUrl(String? path) {
  if (path == null || path.isEmpty) return null;
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  return '${AppConstants.imageBaseUrl}$path';
}
