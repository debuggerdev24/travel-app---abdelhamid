import 'package:trael_app_abdelhamid/model/user_model.dart';
import 'package:trael_app_abdelhamid/services/base_api_service.dart';
import 'package:trael_app_abdelhamid/services/endpoints.dart';

class AuthService {
  final BaseApiService _apiService = BaseApiService.instance;

  /// Registers a new user with the provided [email], [phoneNumber], and [password].
  Future<UserModel> register({
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

      // Assuming the response structure is { "status": true, "message": "...", "data": { ... } }
      // based on the provided backend snippet using apiResponse.successResponseWithData
      if (response['data'] != null) {
        return UserModel.fromJson(response['data']);
      } else {
        throw Exception('Response data is null');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Logs in a user with the provided [email] and [password].
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        Endpoints.signIn,
        body: {'email': email, 'password': password},
      );

      // Save token if it's returned in the response
      if (response['token'] != null) {
        await BaseApiService.saveAuthToken(response['token']);
      } else if (response['data'] != null &&
          response['data']['token'] != null) {
        await BaseApiService.saveAuthToken(response['data']['token']);
      }

      if (response['data'] != null) {
        return UserModel.fromJson(response['data']);
      } else {
        throw Exception('Response data is null');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Logout clears the auth token from local storage.
  Future<void> logout() async {
    await BaseApiService.clearAuthToken();
  }
}
