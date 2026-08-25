import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PrefHelper {
  static late SharedPreferences _prefs;
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _themeModeKey = 'theme_mode';

  /// Initialize the shared preferences instance
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Saves the access token to local storage
  static Future<bool> saveAccessToken(String token) async {
    return await _prefs.setString(_accessTokenKey, token);
  }

  /// Retrieves the access token from local storage
  static String? getAccessToken() {
    return _prefs.getString(_accessTokenKey);
  }

  /// Saves the refresh token to local storage
  static Future<bool> saveRefreshToken(String token) async {
    return await _prefs.setString(_refreshTokenKey, token);
  }

  /// Retrieves the refresh token from local storage
  static String? getRefreshToken() {
    return _prefs.getString(_refreshTokenKey);
  }

  static Future<bool> saveUserId(String id) async {
    return await _prefs.setString(_userIdKey, id);
  }

  static String? getUserId() {
    return _prefs.getString(_userIdKey);
  }

  /// Clears access token, refresh token, and user ID (useful for logout / session expiry)
  static Future<void> clearTokens() async {
    await _prefs.remove(_accessTokenKey);
    await _prefs.remove(_refreshTokenKey);
    await _prefs.remove(_userIdKey);
  }

  /// Helper to check if a JWT token is expired
  static bool isJwtExpired(String token) {
    if (token == 'static_guide_token') return false;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;
      final normalized = base64Url.normalize(parts[1]);
      final payload =
          jsonDecode(utf8.decode(base64Url.decode(normalized)))
              as Map<String, dynamic>;
      final exp = payload['exp'];
      final expSeconds = exp is int
          ? exp
          : exp is num
          ? exp.toInt()
          : null;
      if (expSeconds != null) {
        final expDate = DateTime.fromMillisecondsSinceEpoch(
          expSeconds * 1000,
          isUtc: true,
        );
        // 30s clock-skew leeway so a freshly issued token is not treated as expired.
        return DateTime.now().toUtc().isAfter(
          expDate.add(const Duration(seconds: 30)),
        );
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Checks if the user is logged in by checking for a valid, non-expired access token
  static bool isLoggedIn() {
    final token = getAccessToken();
    if (token == null || token.isEmpty) return false;
    if (isJwtExpired(token)) {
      clearTokens();
      return false;
    }
    return true;
  }

  /// Saves the theme mode to local storage
  static Future<bool> saveThemeMode(String themeMode) async {
    return await _prefs.setString(_themeModeKey, themeMode);
  }

  /// Retrieves the theme mode from local storage
  static String? getThemeMode() {
    return _prefs.getString(_themeModeKey);
  }
}
