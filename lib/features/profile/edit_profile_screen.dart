import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_button.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text_filed.dart';
import 'package:travel_app_abdelhamid/core/widgets/nationality_dropdown.dart';
import 'package:travel_app_abdelhamid/core/widgets/network_avatar.dart';
import 'package:travel_app_abdelhamid/core/utils/date_format_helper.dart';
import 'package:travel_app_abdelhamid/core/utils/server_media_url.dart';
import 'package:travel_app_abdelhamid/core/utils/toast_helper.dart';
import 'package:travel_app_abdelhamid/model/profile/user_profile_model.dart';
import 'package:travel_app_abdelhamid/provider/profile/profile_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _fullName = TextEditingController();
  final _dob = TextEditingController();
  final _age = TextEditingController();
  final _gender = TextEditingController(text: 'male');
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
    final derived = ageFromDateOfBirth(p.dateOfBirth);
    _age.text = derived?.toString() ?? (p.age?.toString() ?? '');
    final savedGender = p.gender.trim().toLowerCase();
    _gender.text = savedGender.isEmpty ? 'male' : savedGender;
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
      helpText: 'Select date of birth'.tr(),
    );
    if (picked == null) return;
    // Keep a stable format for backend: YYYY-MM-DD
    final y = picked.year.toString().padLeft(4, '0');
    final m = picked.month.toString().padLeft(2, '0');
    final d = picked.day.toString().padLeft(2, '0');
    _dob.text = '$y-$m-$d';
    _age.text = (ageFromDateOfBirth(_dob.text)?.toString() ?? '');
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

  String? _profileAvatarUrl(ProfileProvider provider) {
    final raw = provider.profile?.profileImageRaw.trim();
    if (raw == null || raw.isEmpty) return null;
    return serverMediaUrl(raw);
  }

  Future<void> _pickAndUploadImage(ProfileProvider provider) async {
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 80,
    );
    if (x == null) return;
    await provider.updateProfileImage(x.path);
  }

  Future<void> _save(ProfileProvider provider) async {
    final fullName = _fullName.text.trim();

    if (fullName.isEmpty) {
      ToastHelper.showError('Full name is required'.tr());
      return;
    }
    if (provider.selectedLanguages.isEmpty) {
      ToastHelper.showError('Select a language'.tr());
      return;
    }

    final current = provider.profile;
    final base =
        current ??
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
    final computedAge = ageFromDateOfBirth(_dob.text);
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

  Future<void> _changeLanguage(ProfileProvider provider, String lang) async {
    if (lang == 'Dutch') {
      context.setLocale(const Locale('nl'));
    } else if (lang == 'English') {
      context.setLocale(const Locale('en'));
    } else if (lang == 'French') {
      context.setLocale(const Locale('fr'));
    } else if (lang == 'Arabic') {
      context.setLocale(const Locale('ar'));
    }

    provider.updateSelectedLanguages([lang]);

    if (provider.profile != null) {
      final updated = provider.profile!.copyWith(languages: [lang]);
      await provider.saveProfile(updated, showSuccess: false);
    }
  }

  List<String> _genderOptions() {
    const options = ['male', 'female', 'other'];
    final current = _gender.text.trim();
    if (current.isEmpty) return options;

    final alreadyListed = options.any(
      (item) => item.toLowerCase() == current.toLowerCase(),
    );
    if (alreadyListed) return options;
    return [current, ...options];
  }

  (String, String) _splitName(String v) {
    final parts = v
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return ('', '');
    if (parts.length == 1) return (parts.first, '');
    return (parts.first, parts.sublist(1).join(' '));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          _prefill(provider);
          return SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 11.w),
                child: Column(
                  children: [
                    SizedBox(
                      height: 60.h,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Center(
                            child: AppText(
                              text: "Edit Profile".tr(),
                              style: textStyle32Bold.copyWith(
                                fontSize: 26.sp,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        NetworkAvatar(
                          imageUrl: _profileAvatarUrl(provider),
                          radius: 55.r,
                        ),
                        if (provider.isUpdatingProfileImage)
                          Container(
                            width: 110.r,
                            height: 110.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withValues(alpha: 0.45),
                            ),
                            child: Center(
                              child: SizedBox(
                                width: 32.w,
                                height: 32.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap:
                                provider.isUpdatingProfileImage ||
                                    provider.isLoading
                                ? null
                                : () => _pickAndUploadImage(provider),
                            child: Container(
                              height: 32.w,
                              width: 32.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).colorScheme.surface,
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outline.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Center(
                                child: SvgIcon(AppAssets.camera, size: 18.w),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    6.h.verticalSpace,
                    GestureDetector(
                      onTap:
                          provider.isUpdatingProfileImage || provider.isLoading
                          ? null
                          : () => _pickAndUploadImage(provider),
                      child: AppText(
                        text: provider.isUpdatingProfileImage
                            ? 'Updating picture...'.tr()
                            : 'Change Photo'.tr(),
                        style: textStyle14Medium.copyWith(
                          fontSize: 16.sp,
                          color: provider.isUpdatingProfileImage
                              ? Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.5)
                              : AppColors.skyblueColor,
                        ),
                      ),
                    ),
                    22.h.verticalSpace,
                    Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: AppText(
                            text: "Personal Information".tr(),
                            style: textStyle16SemiBold.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        16.h.verticalSpace,
                        Column(
                          children: [
                            AppTextField(
                              hintText: "Full Name".tr(),
                              controller: _fullName,
                            ),
                            18.h.verticalSpace,
                            AppTextField(
                              hintText: "Date of Birth".tr(),
                              controller: _dob,
                              readOnly: true,
                              onTap: _pickDob,
                              suffixIcon: GestureDetector(
                                onTap: _pickDob,
                                child: Padding(
                                  padding: EdgeInsets.all(13),
                                  child: SvgIcon(
                                    AppAssets.calendar,
                                    size: 24.w,
                                  ),
                                ),
                              ),
                            ),
                            18.h.verticalSpace,

                            AppTextField(
                              hintText: "Age (Auto Generated)".tr(),
                              controller: _age,
                              readOnly: true,
                            ),
                            18.h.verticalSpace,
                            _LanguagePicker(
                              hint: 'gender',
                              options: _genderOptions(),
                              selected: _gender.text.trim().isEmpty
                                  ? null
                                  : _gender.text.trim(),
                              onSelected: (value) {
                                setState(() {
                                  _gender.text = value;
                                });
                              },
                            ),
                            18.h.verticalSpace,

                            NationalityDropdown(
                              hintText: 'Select nationality'.tr(),
                              controller: _nationality,
                            ),
                            18.h.verticalSpace,

                            AppTextField(
                              hintText: "Passport Number".tr(),
                              controller: _passport,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(7),
                              ],
                            ),
                            18.h.verticalSpace,

                            _LanguagePicker(
                              hint: 'Language'.tr(),
                              options: provider.languageOptions,
                              selected: provider.selectedLanguages.isEmpty
                                  ? null
                                  : provider.selectedLanguages.first,
                              onSelected: (value) {
                                _changeLanguage(provider, value);
                              },
                            ),
                          ],
                        ),
                        22.h.verticalSpace,
                        AppButton(
                          title: "Save".tr(),
                          isLoading: provider.isLoading,
                          onTap: provider.isLoading
                              ? null
                              : () => _save(provider),
                        ),
                        22.h.verticalSpace,
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

class _LanguagePicker extends StatefulWidget {
  final String hint;
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelected;

  const _LanguagePicker({
    required this.hint,
    required this.options,
    required this.selected,
    required this.onSelected,
  });
  @override
  State<_LanguagePicker> createState() => _LanguagePickerState();
}

class _LanguagePickerState extends State<_LanguagePicker> {
  bool _isOpen = false;

  void _select(String value) {
    widget.onSelected(value);
    setState(() {
      _isOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final hasSelection = selected != null && selected.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isOpen = !_isOpen;
              });
            },
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Row(
                children: [
                  Expanded(
                    child: AppText(
                      text: hasSelection ? selected : widget.hint,
                      style: textStyle14Regular.copyWith(
                        color: hasSelection
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _isOpen
                ? Column(
                    children: [
                      Divider(
                        height: 1,
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.2),
                      ),
                      for (var i = 0; i < widget.options.length; i++)
                        _languageRow(
                          widget.options[i],
                          widget.options[i].toLowerCase() ==
                              (selected ?? '').toLowerCase(),
                          i < widget.options.length - 1,
                        ),
                    ],
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _languageRow(String title, bool isSelected, bool showDivider) {
    return InkWell(
      onTap: () => _select(title),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  size: 22.w,
                  color: isSelected
                      ? AppColors.secondary
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.45),
                ),
                12.w.horizontalSpace,
                Expanded(
                  child: AppText(
                    text: title,
                    style: textStyle14Medium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (showDivider)
            Divider(
              height: 1,
              indent: 16.w,
              endIndent: 16.w,
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.15),
            ),
        ],
      ),
    );
  }
}
