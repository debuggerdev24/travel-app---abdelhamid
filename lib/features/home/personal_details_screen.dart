import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_button.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text_filed.dart';
import 'package:trael_app_abdelhamid/core/utils/validators.dart';
import 'package:trael_app_abdelhamid/provider/home/person_details_provider.dart';
import 'package:trael_app_abdelhamid/provider/profile/profile_provider.dart';
import 'package:trael_app_abdelhamid/routes/user_routes.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  late final PersonDetailsProvider _provider;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _didPrefillFromProfile = false;

  DateTime? _tryParseDob(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;
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

  Future<void> _pickDob(PersonDetailsProvider provider) async {
    final initial =
        _tryParseDob(provider.dateOfBirthController.text) ?? DateTime(2000, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime.now(),
      helpText: 'Select date of birth',
    );
    if (picked == null) return;
    final y = picked.year.toString().padLeft(4, '0');
    final m = picked.month.toString().padLeft(2, '0');
    final d = picked.day.toString().padLeft(2, '0');
    provider.dateOfBirthController.text = '$y-$m-$d';
    // Keep cursor stable
    provider.dateOfBirthController.selection = TextSelection.fromPosition(
      TextPosition(offset: provider.dateOfBirthController.text.length),
    );
  }

  @override
  void initState() {
    super.initState();
    _provider = PersonDetailsProvider();
    debugPrint('✅ [PersonalDetailsScreen] Provider initialized');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final profile = context.read<ProfileProvider>().profile;
      if (profile != null) {
        _provider.prefillFromUserProfile(profile);
        _didPrefillFromProfile = true;
      }
    });
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: ChangeNotifierProvider.value(
        value: _provider,
        child: Consumer<PersonDetailsProvider>(
          builder: (context, provider, child) {
            // If profile arrives after this screen, prefill once.
            if (!_didPrefillFromProfile) {
              final profile = context.watch<ProfileProvider>().profile;
              if (profile != null) {
                _provider.prefillFromUserProfile(profile);
                _didPrefillFromProfile = true;
              }
            }
            return SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  40.h.verticalSpace,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 31.w),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () => context.pop(),
                            child: SvgIcon(AppAssets.backIcon, size: 28.5.w),
                          ),
                        ),
                        AppText(
                          text: "Person Details",
                          style: textStyle32Bold.copyWith(
                            fontSize: 26.sp,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 31.w),
                        child: Column(
                          spacing: 22.h,
                          children: [
                            4.h.verticalSpace,
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: AppText(
                                text: "Personal details of the main booker",
                                style: textStyle14Medium.copyWith(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            AppTextField(
                              labelText: "First Name",
                              hintText: "Enter Your First Name",
                              controller: provider.firstNameController,
                              validator: (v) =>
                                  Validator.validatePersonName(v, 'First name'),
                            ),
                            AppTextField(
                              labelText: "Surname",
                              hintText: "Enter Your Surname",
                              controller: provider.surnameController,
                              validator: (v) =>
                                  Validator.validatePersonName(v, 'Surname'),
                            ),
                            AppTextField(
                              labelText: "Date of Birth",
                              hintText: "Select Date of Birth",
                              controller: provider.dateOfBirthController,
                              validator: Validator.validateIsoDateOfBirth,
                              readOnly: true,
                              onTap: () => _pickDob(provider),
                              suffixIcon: Padding(
                                padding: EdgeInsets.all(13.0),
                                child: SvgIcon(AppAssets.date, size: 24.w),
                              ),
                            ),
                            AppTextField(
                              labelText: "Place of birth",
                              hintText: "Enter Your Place of birth",
                              controller: provider.placeOfBirthController,
                              validator: (v) => Validator.validateRequiredText(
                                v,
                                'Place of birth',
                              ),
                            ),
                            AppTextField(
                              labelText: "Nationality",
                              hintText: "Enter Your Nationality",
                              controller: provider.nationalityController,
                              validator: (v) => Validator.validateRequiredText(
                                v,
                                'Nationality',
                              ),
                            ),
                            AppTextField(
                              labelText: "Email Address",
                              hintText: "Enter Your Email Address",
                              controller: provider.emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: Validator.validateEmail,
                            ),
                            AppTextField(
                              labelText: "Address",
                              hintText: "Enter Your Address",
                              controller: provider.addressController,
                              validator: (v) =>
                                  Validator.validateRequiredText(v, 'Address'),
                            ),
                            AppTextField(
                              labelText: "House number",
                              hintText: "Enter Your House number",
                              controller: provider.houseNumberController,
                              validator: (v) => Validator.validateRequiredText(
                                v,
                                'House number',
                                minLen: 1,
                                maxLen: 20,
                              ),
                            ),
                            AppTextField(
                              labelText: "Postal code",
                              hintText: "Enter Postal code",
                              controller: provider.postalCodeController,
                              validator: (v) => Validator.validateRequiredText(
                                v,
                                'Postal code',
                                minLen: 2,
                                maxLen: 20,
                              ),
                            ),
                            AppTextField(
                              labelText: "Place of residence",
                              hintText: "Enter Place of residence",
                              controller: provider.placeOfResidenceController,
                              validator: (v) => Validator.validateRequiredText(
                                v,
                                'Place of residence',
                              ),
                            ),
                            AppTextField(
                              labelText: "Phone Number",
                              hintText: "Enter Your Phone Number",
                              controller: provider.phoneNumberController,
                              keyboardType: TextInputType.phone,
                              validator: Validator.validatePersonPhoneFlexible,
                            ),

                            2.h.verticalSpace,
                            AppButton(
                              title: provider.isLoading
                                  ? "Saving..."
                                  : "Add Second Person Details",
                              onTap: provider.isLoading
                                  ? null
                                  : () async {
                                      if (!(_formKey.currentState?.validate() ??
                                          false)) {
                                        return;
                                      }

                                      final success = await provider
                                          .savePersonDetails();

                                      debugPrint(
                                        success
                                            ? '✅ [PersonalDetailsScreen] Save successful'
                                            : '❌ [PersonalDetailsScreen] Save failed',
                                      );

                                      if (success && context.mounted) {
                                        context.pushNamed(
                                          UserAppRoutes
                                              .personalDetailsScreen2
                                              .name,
                                        );
                                      }
                                    },
                            ),
                            10.h.verticalSpace,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
