import 'package:flutter/material.dart';
import 'package:trael_app_abdelhamid/model/profile/user_profile_model.dart';
import 'package:trael_app_abdelhamid/services/user_profile_service.dart';
import 'package:trael_app_abdelhamid/core/utils/toast_helper.dart';

class ProfileProvider extends ChangeNotifier {
  UserProfile? _profile;
  UserProfile? get profile => _profile;

  bool _loading = false;
  bool get isLoading => _loading;

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

  void updateSelectedLanguages(List<String> values) {
    selectedLanguages = values;
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
        selectedLanguages = p.languages;
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
      selectedLanguages = _profile?.languages ?? selectedLanguages;
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
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final url = await UserProfileService.instance.changeProfileImage(
        filePath: filePath,
      );
      if (url != null && url.isNotEmpty && _profile != null) {
        _profile = _profile!.copyWith(profileImageRaw: url);
      }
      if (url != null && url.isNotEmpty) {
        ToastHelper.showSuccess('Profile image updated');
      }
      return url != null;
    } catch (e) {
      _error = e.toString();
      ToastHelper.showError('Failed to update profile image');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
