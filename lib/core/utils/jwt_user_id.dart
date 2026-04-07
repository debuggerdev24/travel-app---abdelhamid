import 'dart:convert';

import 'package:trael_app_abdelhamid/core/utils/pref_helper.dart';

/// Reads `userId` from the JWT payload (matches backend [helpers/utility.js]).
String? userIdFromAccessToken(String? token) {
  if (token == null || token.isEmpty) return null;
  final parts = token.split('.');
  if (parts.length != 3) return null;
  try {
    final normalized = base64Url.normalize(parts[1]);
    final payload =
        jsonDecode(utf8.decode(base64Url.decode(normalized))) as Map<String, dynamic>;
    final uid = payload['userId'];
    if (uid == null) return null;
    return uid.toString();
  } catch (_) {
    return null;
  }
}

/// Persisted user id from login, or JWT fallback for older sessions.
String? currentUserIdOrNull() {
  final stored = PrefHelper.getUserId();
  if (stored != null && stored.isNotEmpty) return stored;
  return userIdFromAccessToken(PrefHelper.getAccessToken());
}
