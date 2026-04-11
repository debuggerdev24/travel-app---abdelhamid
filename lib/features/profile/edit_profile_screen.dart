import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_button.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text_filed.dart';
import 'package:trael_app_abdelhamid/core/widgets/dropdown_text_filed.dart';
import 'package:trael_app_abdelhamid/core/utils/server_media_url.dart';
import 'package:trael_app_abdelhamid/core/utils/toast_helper.dart';
import 'package:trael_app_abdelhamid/model/profile/user_profile_model.dart';
import 'package:trael_app_abdelhamid/provider/profile/profile_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _fullName = TextEditingController();
  final _dob = TextEditingController();
  final _age = TextEditingController();
  final _gender = TextEditingController();
  final _nationality = TextEditingController();
  final _passport = TextEditingController();

  bool _didPrefill = false;

  @override
  void dispose() {
    _fullName.dispose();
    _dob.dispose();
    _age.dispose();
    _gender.dispose();
    _nationality.dispose();
    _passport.dispose();
    super.dispose();
  }

  void _prefill(ProfileProvider provider) {
    if (_didPrefill) return;
    final p = provider.profile;
    if (p == null) return;
    _didPrefill = true;
    _fullName.text = p.fullName;
    _dob.text = p.dateOfBirth;
    final derived = _computeAgeFromDob(_tryParseDob(p.dateOfBirth));
    _age.text = derived?.toString() ?? (p.age?.toString() ?? '');
    _gender.text = p.gender;
    _nationality.text = p.nationality;
    _passport.text = p.passportNumber;
  }

  Future<void> _pickDob() async {
    final initial = _tryParseDob(_dob.text) ?? DateTime(2000, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime.now(),
      helpText: 'Select date of birth',
    );
    if (picked == null) return;
    // Keep a stable format for backend: YYYY-MM-DD
    final y = picked.year.toString().padLeft(4, '0');
    final m = picked.month.toString().padLeft(2, '0');
    final d = picked.day.toString().padLeft(2, '0');
    setState(() {
      _dob.text = '$y-$m-$d';
      _age.text = (_computeAgeFromDob(picked)?.toString() ?? '');
    });
  }

  DateTime? _tryParseDob(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;
    // Common cases: `YYYY-MM-DD` or full ISO `YYYY-MM-DDTHH:mm:ss...`
    try {
      return DateTime.parse(s);
    } catch (_) {
      final only = s.split(' ').first;
      try {
        return DateTime.parse(only);
      } catch (_) {
        return null;
      }
    }
  }

  int? _computeAgeFromDob(DateTime? dob) {
    if (dob == null) return null;
    final now = DateTime.now();
    var age = now.year - dob.year;
    final hadBirthdayThisYear =
        (now.month > dob.month) || (now.month == dob.month && now.day >= dob.day);
    if (!hadBirthdayThisYear) age -= 1;
    if (age < 0 || age > 130) return null;
    return age;
  }

  ImageProvider _avatar(ProfileProvider provider) {
    final raw = provider.profile?.profileImageRaw.trim();
    if (raw == null || raw.isEmpty) {
      return const AssetImage(AppAssets.profilePhoto);
    }
    final url = serverMediaUrl(raw);
    if (url == null || url.isEmpty) {
      return const AssetImage(AppAssets.profilePhoto);
    }
    return NetworkImage(url);
  }

  Future<void> _pickAndUploadImage(ProfileProvider provider) async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery);
    if (x == null) return;
    await provider.updateProfileImage(x.path);
  }

  Future<void> _save(ProfileProvider provider) async {
    final fullName = _fullName.text.trim();

    if (fullName.isEmpty) {
      ToastHelper.showError('Full name is required');
      return;
    }
    if (provider.selectedLanguages.isEmpty) {
      ToastHelper.showError('Select at least one language');
      return;
    }

    final current = provider.profile;
    final base = current ??
        const UserProfile(
          firstName: '',
          surName: '',
          email: '',
          phoneNumber: '',
          age: null,
          dateOfBirth: '',
          gender: '',
          nationality: '',
          passportNumber: '',
          languages: [],
          profileImageRaw: '',
        );

    final split = _splitName(fullName);
    final computedAge = _computeAgeFromDob(_tryParseDob(_dob.text));
    final updated = base.copyWith(
      firstName: split.$1,
      surName: split.$2,
      age: computedAge,
      dateOfBirth: _dob.text.trim(),
      gender: _gender.text.trim(),
      nationality: _nationality.text.trim(),
      passportNumber: _passport.text.trim(),
      languages: provider.selectedLanguages,
    );
    final ok = await provider.saveProfile(updated);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    }
  }

  (String, String) _splitName(String v) {
    final parts =
        v.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return ('', '');
    if (parts.length == 1) return (parts.first, '');
    return (parts.first, parts.sublist(1).join(' '));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          _prefill(provider);
          return SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 27.w),
                child: Column(
                  children: [
                    SizedBox(
                      height: 60.h,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Center(
                            child: AppText(
                              text: "Edit Profile",
                              style: textStyle32Bold.copyWith(
                                fontSize: 26.sp,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: 55.r,
                      backgroundImage: _avatar(provider),
                    ),
                    6.h.verticalSpace,
                    GestureDetector(
                      onTap: provider.isLoading
                          ? null
                          : () => _pickAndUploadImage(provider),
                      child: AppText(
                        text: "Change Picture",
                        style: textStyle14Medium.copyWith(
                          fontSize: 16.sp,
                          color: AppColors.blueColor,
                        ),
                      ),
                    ),
                    22.h.verticalSpace,
                    Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: AppText(
                            text: "Personal Information",
                            style: textStyle16SemiBold.copyWith(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                        16.h.verticalSpace,
                        Column(
                          children: [
                            AppTextField(
                              hintText: "Full Name",
                              controller: _fullName,
                            ),
                            18.h.verticalSpace,
                            AppTextField(
                              hintText: "Date of Birth",
                              controller: _dob,
                              readOnly: true,
                              onTap: _pickDob,
                            ),
                            18.h.verticalSpace,

                            AppTextField(
                              hintText: "Age (Auto Generated)",
                              controller: _age,
                              readOnly: true,
                            ),
                            18.h.verticalSpace,

                            AppTextField(
                              hintText: "Gender",
                              controller: _gender,
                            ),
                            18.h.verticalSpace,

                            AppTextField(
                              hintText: "Nationality",
                              controller: _nationality,
                            ),
                            18.h.verticalSpace,

                            AppTextField(
                              hintText: "Passport Number",
                              controller: _passport,
                            ),
                            18.h.verticalSpace,

                            CustomMultiSelectDropdown(
                              hintText: "Language",
                              items: provider.languageOptions,
                              selectedItems: provider.selectedLanguages,
                              onChanged: provider.updateSelectedLanguages,
                              titleText: "Language",
                            ),
                          ],
                        ),
                        42.h.verticalSpace,
                        AppButton(
                          title: "Save",
                          isLoading: provider.isLoading,
                          onTap: provider.isLoading ? null : () => _save(provider),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
