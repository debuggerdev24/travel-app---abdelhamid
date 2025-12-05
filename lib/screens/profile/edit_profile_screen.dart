import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_button.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text_filed.dart';
import 'package:trael_app_abdelhamid/core/widgets/dropdown_text_filed.dart';
import 'package:trael_app_abdelhamid/provider/home/home_provider.dart';
import 'package:trael_app_abdelhamid/provider/profile/profile_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
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
                      backgroundImage: AssetImage(AppAssets.profilephoto),
                    ),
                    6.h.verticalSpace,
                    AppText(
                      text: "Change Picture",
                      style: textStyle14Medium.copyWith(
                        fontSize: 16.sp,
                        color: AppColors.blueColor,
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
                            AppTextField(hintText: "Full Name"),
                            18.h.verticalSpace,
                            AppTextField(hintText: "Email"),
                            18.h.verticalSpace,

                            AppTextField(hintText: "Date of Birth"),
                            18.h.verticalSpace,

                            AppTextField(hintText: "Age (Auto Generated)"),
                            18.h.verticalSpace,

                            AppTextField(hintText: "Gender"),
                            18.h.verticalSpace,

                            AppTextField(hintText: "Nationality"),
                            18.h.verticalSpace,

                            AppTextField(hintText: "Passport Number"),
                            18.h.verticalSpace,

                            AppTextField(hintText: "Contact"),
                            18.h.verticalSpace,

                            AppTextField(hintText: "Password"),

                            CustomMultiSelectDropdown(
                              hintText: "Language",
                              items: provider.languageOptions,
                              selectedItems: provider.selectedLanguages,
                              onChanged: provider.updateSelectedLanguages,
                              titletext: "Language",
                            ),
                          ],
                        ),
                        42.h.verticalSpace,
                        AppButton(title: "Save", onTap: () {

                        }),
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
