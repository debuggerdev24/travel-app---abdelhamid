import 'package:shared_preferences/shared_preferences.dart';

class PrefHelper {
  static late SharedPreferences _prefs;
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

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

  /// Clears both access and refresh tokens (useful for logout)
  static Future<void> clearTokens() async {
    await _prefs.remove(_accessTokenKey);
  }

  /// Checks if the user is logged in by checking for an access token
  static bool isLoggedIn() {
    final token = getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
