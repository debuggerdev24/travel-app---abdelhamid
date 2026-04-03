import 'package:trael_app_abdelhamid/core/constants/app_constants.dart';

/// Builds a full URL for files served under `/uploads/` (same rules as [TripModel.imageUrl]).
String? serverMediaUrl(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  final trimmed = raw.trim();
  if (trimmed.startsWith('http')) return trimmed;

  final baseUrl = AppConstants.imageBaseUrl;
  final normalized = _normalizeUploadPath(trimmed);

  if (normalized.startsWith('/')) {
    return '$baseUrl$normalized';
  }
  return '$baseUrl/uploads/$normalized';
}

String _normalizeUploadPath(String raw) {
  var v = raw.trim();
  if (v.isEmpty) return v;

  v = v.replaceAll('\\', '/');

  final idx = v.lastIndexOf('/uploads/');
  if (idx != -1) {
    return v.substring(idx);
  }

  final lastSlash = v.lastIndexOf('/');
  if (lastSlash != -1 && lastSlash < v.length - 1) {
    return v.substring(lastSlash + 1);
  }
  return v;
}
