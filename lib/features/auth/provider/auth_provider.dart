import 'package:flutter/material.dart';
import 'package:trael_app_abdelhamid/core/network/network_errors.dart';
import 'package:trael_app_abdelhamid/core/utils/pref_helper.dart';
import 'package:trael_app_abdelhamid/features/auth/model/login_response_model.dart';
import 'package:trael_app_abdelhamid/features/auth/model/verify_otp_response_model.dart';
import 'package:trael_app_abdelhamid/features/auth/service/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  /// Registration logic
  Future<bool> register({
    required String email,
    required String phoneNumber,
    required String password,
    required Function(String error) omError,
  }) async {
    _setLoading(true);
    try {
      await _authService.register(
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
  Future<bool> login({
    required String travellerCode,
    required String emailOrPhone,
    required String password,
    required Function(String error) omError,
  }) async {
    _setLoading(true);
    try {
      LoginResponseModel response = await _authService.login(
        travellerCode: travellerCode,
        emailOrPhone: emailOrPhone,
        password: password,
      );
      PrefHelper.saveAccessToken(response.accessToken);
      PrefHelper.saveRefreshToken(response.refreshToken);
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

  Future<bool> forgetPassword({
    required String emnail,
    required Function(String error) onError,
  }) async {
    _setLoading(true);
    try {
      await _authService.forgetPasswrod(email: emnail);
      _setLoading(false);
      return true;
    } catch (e) {
      if (e is ApiException) {
        onError(e.message);
      } else {
        onError(e.toString());
      }
      _setLoading(false);
      return false;
    }
  }

  Future<void> verifyOtp({
    required String email,
    required String otp,
    required Function(String error) onError,
    required Function(VerifyOtpResponseModel data) onSuccess,
  }) async {
    _setLoading(true);
    try {
      VerifyOtpResponseModel response = await _authService.verifyOtp(
        email: email,
        otp: otp,
      );
      _setLoading(false);
      onSuccess(response);
    } catch (e) {
      if (e is ApiException) {
        onError(e.message);
      } else {
        onError(e.toString());
      }
      _setLoading(false);
    }
  }

  Future<void> resetPassword({
    required String email,
    required String password,
    required Function(String error) onError,
    required VoidCallback onSuccess,
  }) async {
    _setLoading(true);
    try {
      await _authService.resetPassword(email: email, password: password);
      _setLoading(false);
      onSuccess();
    } catch (e) {
      if (e is ApiException) {
        onError(e.message);
      } else {
        onError(e.toString());
      }
      _setLoading(false);
    }
  }

  Future<void> resendOtp({
    required String email,
    required Function(String error) onError,
    required VoidCallback onSuccess,
  }) async {
    _setLoading(true);
    try {
      await _authService.resendOtp(email: email);
      _setLoading(false);
      onSuccess();
    } catch (e) {
      if (e is ApiException) {
        onError(e.message);
      } else {
        onError(e.toString());
      }
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
