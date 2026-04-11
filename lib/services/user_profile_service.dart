import 'package:trael_app_abdelhamid/core/network/base_api_service.dart';
import 'package:trael_app_abdelhamid/core/network/endpoints.dart';
import 'package:trael_app_abdelhamid/model/profile/user_profile_model.dart';

class UserProfileService {
  UserProfileService._internal();
  static final UserProfileService instance = UserProfileService._internal();

  Future<UserProfile?> getUserDetails({bool showErrorToast = false}) async {
    final response = await BaseApiService.instance.get(
      Endpoints.bookingGetUserDetails,
      showErrorToast: showErrorToast,
    );
    if (response is! Map) return null;
    final map = Map<String, dynamic>.from(response);
    if (map['status'] != 1 || map['data'] == null) return null;
    final data = map['data'];
    if (data is! Map) return null;
    return UserProfile.fromJson(Map<String, dynamic>.from(data));
  }

  /// Full PATCH body for `PUT/PATCH .../booking/edit-profile` — all fields the app tracks.
  static Map<String, dynamic> profileToUpdateBody(UserProfile profile) {
    final map = <String, dynamic>{
      'firstName': profile.firstName,
      'surName': profile.surName,
      'surname': profile.surName,
      'fullName': profile.fullName,
      'email': profile.email,
      'contact': profile.phoneNumber,
      'phoneNumber': profile.phoneNumber,
      'dateOfBirth': profile.dateOfBirth,
      'gender': profile.gender,
      'nationality': profile.nationality,
      'passportNumber': profile.passportNumber,
      'languages': profile.languages,
      'language': profile.primaryLanguage,
      'travellerCode': profile.travellerCode,
      'isVerified': profile.isVerified,
      'address': profile.address,
      'houseNumber': profile.houseNumber,
      'placeOfBirth': profile.placeOfBirth,
      'placeOfResidence': profile.placeOfResidence,
      'postalCode': profile.postalCode,
    };
    if (profile.age != null) map['age'] = profile.age;
    return map;
  }

  Future<UserProfile?> editProfile({
    required UserProfile profile,
    bool showErrorToast = true,
  }) async {
    final body = profileToUpdateBody(profile);
    final response = await BaseApiService.instance.patch(
      Endpoints.bookingEditProfile,
      body: body,
      showErrorToast: showErrorToast,
    );
    if (response is! Map) return null;
    final map = Map<String, dynamic>.from(response);
    final data = map['data'];
    if (map['status'] == 1 && data is Map) {
      return UserProfile.fromJson(Map<String, dynamic>.from(data));
    }
    // Some APIs return profile under `user` etc; keep current if not returned.
    return profile;
  }

  Future<String?> changeProfileImage({
    required String filePath,
    bool showErrorToast = true,
  }) async {
    final response = await BaseApiService.instance.patchMultipart(
      Endpoints.bookingChangeProfileImage,
      fields: const {},
      // Backend expects: multipart field name `profileImage`
      fileFieldName: 'profileImage',
      filePath: filePath,
      showErrorToast: showErrorToast,
    );
    if (response is! Map) return null;
    final map = Map<String, dynamic>.from(response);
    if (map['status'] != 1) return null;
    final data = map['data'];
    if (data is Map) {
      final m = Map<String, dynamic>.from(data);
      final url = (m['profileImage'] ?? m['profilePicture'] ?? m['image'])?.toString();
      if (url != null && url.trim().isNotEmpty) return url;
    }
    return null;
  }
}

