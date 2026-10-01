import 'package:travel_app_abdelhamid/core/constants/app_constants.dart';
import 'package:travel_app_abdelhamid/core/utils/pref_helper.dart';
import 'package:travel_app_abdelhamid/core/network/base_api_service.dart';
import 'package:travel_app_abdelhamid/core/network/endpoints.dart';
import 'package:travel_app_abdelhamid/features/auth/model/login_response_model.dart';
import 'package:travel_app_abdelhamid/features/auth/model/verify_otp_response_model.dart';

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
        showErrorToast: false,
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

        showErrorToast: false,
      );

      if (response is! Map) {
        throw Exception('Invalid login response');
      }
      final payload = LoginResponseModel.fromApiResponse(
        Map<String, dynamic>.from(response),
      );
      if (payload.accessToken.isEmpty) {
        throw Exception('Login succeeded but no access token was returned');
      }
      await PrefHelper.saveAccessToken(payload.accessToken);
      if (payload.refreshToken.isNotEmpty) {
        await PrefHelper.saveRefreshToken(payload.refreshToken);
      }
      if (payload.id.isNotEmpty) {
        await PrefHelper.saveUserId(payload.id);
      }
      return payload;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refreshToken() async {
    final savedToken = PrefHelper.getRefreshToken();
    if (savedToken == null || savedToken.isEmpty) {
      throw Exception('Refresh token is missing');
    }

    final response = await _apiService.post(
      '${AppConstants.apiPublicRoot}${Endpoints.refreshToken}',
      body: {'token': savedToken},
      showErrorToast: false,
    );
    final data = response['data'];
    if (data is! Map) {
      throw Exception('Invalid refresh token response');
    }

    final accessToken = data['accessToken']?.toString() ?? '';
    final newRefreshToken = data['refreshToken']?.toString() ?? '';
    if (accessToken.isEmpty) {
      throw Exception('Refresh token response has no access token');
    }

    await PrefHelper.saveAccessToken(accessToken);
    if (newRefreshToken.isNotEmpty) {
      await PrefHelper.saveRefreshToken(newRefreshToken);
    }
  }

  Future<void> forgetPasswrod({required String email}) async {
    try {
      final response = await _apiService.post(
        Endpoints.forgetPassword,
        body: {'email': email},
        showErrorToast: false,
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
        showErrorToast: false,
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
        showErrorToast: false,
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
        showErrorToast: false,
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
