import 'package:trael_app_abdelhamid/core/utils/pref_helper.dart';
import 'package:trael_app_abdelhamid/core/network/base_api_service.dart';
import 'package:trael_app_abdelhamid/core/network/endpoints.dart';
import 'package:trael_app_abdelhamid/features/auth/model/login_response_model.dart';
import 'package:trael_app_abdelhamid/features/auth/model/verify_otp_response_model.dart';

class AuthService {
  final BaseApiService _apiService = BaseApiService.instance;

  Future<void> register({
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        Endpoints.signUp,
        body: {
          'email': email,
          'phoneNumber': phoneNumber,
          'password': password,
        },
      );

      if (response['data'] != null) {
        return;
      } else {
        throw Exception('Response data is null');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<LoginResponseModel> login({
    required String travellerCode,
    required String emailOrPhone,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        Endpoints.signIn,
        body: {
          'travellerCode': travellerCode,
          'identifier': emailOrPhone,
          'password': password,
        },
      );

      // Save token if it's returned in the response
      if (response['data'] != null &&
          response['data']['accessToken'] != null &&
          response['data']['refreshToken'] != null) {
        await PrefHelper.saveAccessToken(response['data']['accessToken']);
        await PrefHelper.saveRefreshToken(response['data']['refreshToken']);
      }

      if (response['data'] != null) {
        return LoginResponseModel.fromJson(response['data']);
      } else {
        throw Exception('Response data is null');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> forgetPasswrod({required String email}) async {
    try {
      final response = await _apiService.post(
        Endpoints.forgetPaswrod,
        body: {'email': email},
      );

      // Save token if it's returned in the response
      if (response['status'] != null && response['status'].toString() == '1') {
        return;
      } else {
        throw Exception('Response data is null');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<VerifyOtpResponseModel> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _apiService.post(
        Endpoints.verifyOtp,
        body: {'email': email, 'otp': otp},
      );

      // Save token if it's returned in the response
      if (response['status'] != null &&
          response['data'] != null &&
          response['data']['token'] != null &&
          response['data']['token'].toString().isNotEmpty) {
        return VerifyOtpResponseModel.fromJson(response['data']);
      } else {
        throw Exception('Response data is null');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        Endpoints.resetPassword,
        body: {'email': email, 'password': password},
      );

      // Save token if it's returned in the response
      if (response['status'] != null && response['status'].toString() == '1') {
        return;
      } else {
        throw Exception('Response data is null');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resendOtp({required String email}) async {
    try {
      final response = await _apiService.post(
        Endpoints.resendOtp,
        body: {'email': email},
      );

      if (response['status'] != null && response['status'].toString() == '1') {
        return;
      } else {
        throw Exception('Response data is null');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Logout clears the auth token from local storage.
  Future<void> logout() async {
    await PrefHelper.clearTokens();
  }
}
