import 'package:flutter/material.dart';
import 'package:travel_app_abdelhamid/core/network/network_errors.dart';
import 'package:travel_app_abdelhamid/core/utils/image_compress_helper.dart';
import 'package:travel_app_abdelhamid/core/utils/toast_helper.dart';
import 'package:travel_app_abdelhamid/model/profile/user_profile_model.dart';
import 'package:travel_app_abdelhamid/services/user_profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  UserProfile? _profile;
  UserProfile? get profile => _profile;

  bool _loading = false;
  bool get isLoading => _loading;

  bool _updatingProfileImage = false;
  bool get isUpdatingProfileImage => _updatingProfileImage;

  String? _error;
  String? get error => _error;

  List<String> languageOptions = [
    "English",
    "Arabic",
    "Hindi",
    "Gujarati",
    "Spanish",
    "French",
    "Urdu",
  ];

  List<String> selectedLanguages = [];

  /// Maps API values like `english` to dropdown label `English`.
  String? canonicalLanguage(String raw) {
    final lower = raw.trim().toLowerCase();
    if (lower.isEmpty) return null;
    for (final opt in languageOptions) {
      if (opt.toLowerCase() == lower) return opt;
    }
    return null;
  }

  List<String> normalizeSelectedLanguages(List<String> raw) {
    for (final item in raw) {
      final canonical = canonicalLanguage(item);
      if (canonical != null) return [canonical];
    }
    return [];
  }

  void updateSelectedLanguages(List<String> values) {
    if (values.isEmpty) {
      selectedLanguages = [];
    } else {
      final pick = values.length == 1 ? values.first : values.last;
      final canonical = canonicalLanguage(pick);
      selectedLanguages = canonical != null ? [canonical] : [];
    }
    notifyListeners();
  }

  Future<void> loadProfile({bool force = false}) async {
    if (_loading) return;
    if (!force && _profile != null) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final p = await UserProfileService.instance.getUserDetails();
      _profile = p;
      if (p != null) {
        selectedLanguages = normalizeSelectedLanguages(p.languages);
      }
    } catch (e) {
      _error = e.toString();
      // Do not spam toasts on startup; UI can show placeholders.
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> saveProfile(UserProfile updated) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final p = await UserProfileService.instance.editProfile(profile: updated);
      _profile = p ?? updated;
      selectedLanguages = normalizeSelectedLanguages(
        _profile?.languages ?? selectedLanguages,
      );
      ToastHelper.showSuccess('Profile updated');
      return true;
    } catch (e) {
      _error = e.toString();
      ToastHelper.showError('Failed to update profile');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfileImage(String filePath) async {
    if (_updatingProfileImage) return false;
    _updatingProfileImage = true;
    _error = null;
    notifyListeners();
    try {
      final uploadPath = await compressImageForUpload(filePath);
      final url = await UserProfileService.instance.changeProfileImage(
        filePath: uploadPath,
        showErrorToast: false,
      );
      if (url != null && url.isNotEmpty && _profile != null) {
        _profile = _profile!.copyWith(profileImageRaw: url);
      }
      if (url != null && url.isNotEmpty) {
        ToastHelper.showSuccess('Profile image updated');
        return true;
      }
      ToastHelper.showError('Failed to update profile image');
      return false;
    } on ApiException catch (e) {
      _error = e.message;
      if (e.statusCode == 413) {
        ToastHelper.showError(
          'Image is too large. Please choose a smaller photo.',
        );
      } else {
        ToastHelper.showError('Failed to update profile image');
      }
      return false;
    } catch (e) {
      _error = e.toString();
      ToastHelper.showError('Failed to update profile image');
      return false;
    } finally {
      _updatingProfileImage = false;
      notifyListeners();
    }
  }
}
