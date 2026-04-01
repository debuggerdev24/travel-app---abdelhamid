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
import 'package:trael_app_abdelhamid/provider/home/person_details_provider.dart';
import 'package:trael_app_abdelhamid/routes/user_routes.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  late final PersonDetailsProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = PersonDetailsProvider();
    debugPrint('✅ [PersonalDetailsScreen] Provider initialized');
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
                          ),
                          AppTextField(
                            labelText: "Surname",
                            hintText: "Enter Your Surname",
                            controller: provider.surnameController,
                          ),
                          AppTextField(
                            labelText: "Date of Birth",
                            hintText: "Select Date of Birth",
                            controller: provider.dateOfBirthController,
                            suffixIcon: Padding(
                              padding: EdgeInsets.all(13.0),
                              child: SvgIcon(AppAssets.date, size: 24.w),
                            ),
                          ),
                          AppTextField(
                            labelText: "Place of birth",
                            hintText: "Enter Your Place of birth",
                            controller: provider.placeOfBirthController,
                          ),
                          AppTextField(
                            labelText: "Nationality",
                            hintText: "Enter Your Nationality",
                            controller: provider.nationalityController,
                          ),
                          AppTextField(
                            labelText: "Email Address",
                            hintText: "Enter Your Email Address",
                            controller: provider.emailController,
                          ),
                          AppTextField(
                            labelText: "Address",
                            hintText: "Enter Your Address",
                            controller: provider.addressController,
                          ),
                          AppTextField(
                            labelText: "House number",
                            hintText: "Enter Your House number",
                            controller: provider.houseNumberController,
                          ),
                          AppTextField(
                            labelText: "Postal code",
                            hintText: "Enter Postal code",
                            controller: provider.postalCodeController,
                          ),
                          AppTextField(
                            labelText: "Place of residence",
                            hintText: "Enter Place of residence",
                            controller: provider.placeOfResidenceController,
                          ),
                          AppTextField(
                            labelText: "Phone Number",
                            hintText: "Enter Your Phone Number",
                            controller: provider.phoneNumberController,
                          ),

                          2.h.verticalSpace,
                          AppButton(
                            title: provider.isLoading
                                ? "Saving..."
                                : "Add Second Person Details",
                            onTap: provider.isLoading
                                ? null
                                : () async {
                                    debugPrint('🔵 [PersonalDetailsScreen] Button tapped');
                                    debugPrint('🔵 firstName: ${provider.firstNameController.text}');
                                    debugPrint('🔵 surname: ${provider.surnameController.text}');
                                    debugPrint('🔵 dateOfBirth: ${provider.dateOfBirthController.text}');
                                    debugPrint('🔵 placeOfBirth: ${provider.placeOfBirthController.text}');
                                    debugPrint('🔵 nationality: ${provider.nationalityController.text}');
                                    debugPrint('🔵 email: ${provider.emailController.text}');
                                    debugPrint('🔵 address: ${provider.addressController.text}');
                                    debugPrint('🔵 houseNumber: ${provider.houseNumberController.text}');
                                    debugPrint('🔵 postalCode: ${provider.postalCodeController.text}');
                                    debugPrint('🔵 placeOfResidence: ${provider.placeOfResidenceController.text}');
                                    debugPrint('🔵 phoneNumber: ${provider.phoneNumberController.text}');

                                    final success =
                                        await provider.savePersonDetails();

                                    debugPrint(success
                                        ? '✅ [PersonalDetailsScreen] Save successful'
                                        : '❌ [PersonalDetailsScreen] Save failed');

                                    if (success && context.mounted) {
                                      context.pushNamed(
                                        UserAppRoutes
                                            .personalDetailsScreen2.name,
                                      );
                                    }
                                  },
                          ),
                          10.h.verticalSpace,
                        ],
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