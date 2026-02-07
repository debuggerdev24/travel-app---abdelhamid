import 'package:flutter/material.dart';
import 'package:trael_app_abdelhamid/core/widgets/toast_service.dart';
import 'package:trael_app_abdelhamid/model/user_model.dart';
import 'package:trael_app_abdelhamid/services/auth_service.dart';
import 'package:trael_app_abdelhamid/services/base_api_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Registration logic
  Future<bool> register({
    required String email,
    required String phoneNumber,
    required String password,
    required Function(String error) omError,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      _user = await _authService.register(
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      if (e is ApiException) {
        omError(e.message);
      } else {
        omError(e.toString());
      }
      _setLoading(false);
      return false;
    }
  }

  /// Login logic
  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    _error = null;
    try {
      _user = await _authService.login(email: email, password: password);
      _setLoading(false);
      return true;
    } catch (e) {
      if (e is ApiException) {
        _error = e.message;
      } else {
        _error = e.toString();
      }
      _setLoading(false);
      return false;
    }
  }

  /// Logout logic
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
