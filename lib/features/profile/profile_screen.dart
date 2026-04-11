import 'dart:developer';
import 'package:trael_app_abdelhamid/core/core.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_button.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/core/widgets/custom_switch_button.dart';
import 'package:trael_app_abdelhamid/core/utils/server_media_url.dart';
import 'package:trael_app_abdelhamid/core/widgets/shimmer_box.dart';
import 'package:trael_app_abdelhamid/provider/profile/profile_provider.dart';
import 'package:trael_app_abdelhamid/routes/user_routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 60.h,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: AppText(
                      text: "Profile",
                      style: textStyle32Bold.copyWith(
                        fontSize: 26.sp,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 27.w),
                child: Consumer<ProfileProvider>(
                  builder: (context, provider, _) {
                    final p = provider.profile;
                    final name =
                        p?.fullName.isNotEmpty == true ? p!.fullName : '—';
                    final email = p?.email.isNotEmpty == true ? p!.email : '—';

                    ImageProvider avatarImage =
                        const AssetImage(AppAssets.profilePhoto);
                    final raw = p?.profileImageRaw.trim();
                    if (raw != null && raw.isNotEmpty) {
                      avatarImage = NetworkImage(serverMediaUrl(raw) ?? raw);
                    }

                    return Column(
                      children: [
                        if (provider.isLoading && p == null)
                          ShimmerBox(
                            width: (50.r * 2),
                            height: (50.r * 2),
                            shape: BoxShape.circle,
                          )
                        else
                          CircleAvatar(
                            radius: 50.r,
                            backgroundImage: avatarImage,
                          ),
                        10.h.verticalSpace,
                        AppText(
                          text: name,
                          style: textStyle16SemiBold.copyWith(
                            fontSize: 18.sp,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        4.h.verticalSpace,
                        AppText(
                          text: provider.isLoading && p == null ? '—' : email,
                          style: textStyle14Regular.copyWith(
                            fontSize: 14.sp,
                            color: AppColors.primaryColor.setOpacity(0.8),
                          ),
                        ),

                    24.h.verticalSpace,
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AppText(
                        text: "Personal Information",
                        style: textStyle16SemiBold.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    10.h.verticalSpace,
                    _infoCard([
                      _infoRow(
                        "Date of Birth",
                        p?.dateOfBirth.isNotEmpty == true ? p!.dateOfBirth : "—",
                      ),
                      Divider(color: AppColors.primaryColor.setOpacity(0.2)),
                      _infoRow("Age", "—"),
                      Divider(color: AppColors.primaryColor.setOpacity(0.2)),

                      _infoRow(
                        "Gender",
                        p?.gender.isNotEmpty == true ? p!.gender : "—",
                      ),
                      Divider(color: AppColors.primaryColor.setOpacity(0.2)),

                      _infoRow(
                        "Nationality",
                        p?.nationality.isNotEmpty == true
                            ? p!.nationality
                            : "—",
                      ),
                      Divider(color: AppColors.primaryColor.setOpacity(0.2)),

                      _infoRow(
                        "Passport Number",
                        p?.passportNumber.isNotEmpty == true
                            ? p!.passportNumber
                            : "—",
                      ),
                      Divider(color: AppColors.primaryColor.setOpacity(0.2)),

                      _infoRow(
                        "Contact",
                        p?.phoneNumber.isNotEmpty == true ? p!.phoneNumber : "—",
                      ),
                      Divider(color: AppColors.primaryColor.setOpacity(0.2)),

                      _infoRow(
                        "Language",
                        p?.languages.isNotEmpty == true
                            ? p!.languages.join(', ')
                            : "—",
                      ),
                    ]),

                    20.h.verticalSpace,
                    GestureDetector(
                      onTap: () {
                        context.pushNamed(UserAppRoutes.prayerTimesScreen.name);
                      },
                      child: _menuTile("Prayer Times"),
                    ),

                    22.h.verticalSpace,

                    /// ---------------- HELP & SUPPORT ----------------
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AppText(
                        text: "Help & Support",
                        style: textStyle16SemiBold.copyWith(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    16.h.verticalSpace,
                    _infoCard([
                      _menuitems("FAQs", () {
                        context.pushNamed(UserAppRoutes.faqScreen.name);
                      }),
                      Divider(color: AppColors.primaryColor.setOpacity(0.2)),

                      _menuitems("Social Media Links", () {
                        context.pushNamed(UserAppRoutes.socialMediaScreen.name);
                      }),
                      Divider(color: AppColors.primaryColor.setOpacity(0.2)),

                      _menuitems("Terms & Conditions", () {
                        context.pushNamed(
                          UserAppRoutes.termsConditionScreen.name,
                        );
                      }),
                      Divider(color: AppColors.primaryColor.setOpacity(0.2)),

                      _menuitems("Privacy Policy", () {
                        context.pushNamed(
                          UserAppRoutes.privacyPolicyScreen.name,
                        );
                      }),
                      Divider(color: AppColors.primaryColor.setOpacity(0.2)),

                      _menuitems("Our Locations", () {
                        context.pushNamed(
                          UserAppRoutes.ourLocationsScreen.name,
                        );
                      }),
                      Divider(color: AppColors.primaryColor.setOpacity(0.2)),

                      _menuitems("Meet Our Team", () {
                        context.pushNamed(UserAppRoutes.meetOurTeamScreen.name);
                      }),
                      Divider(color: AppColors.primaryColor.setOpacity(0.2)),

                      _menuitems("Feedback", () {
                        context.pushNamed(
                          UserAppRoutes.profileFeedbackScreen.name,
                        );
                      }),
                      Divider(color: AppColors.primaryColor.setOpacity(0.2)),

                      _menuitems("App Settings", () {
                        context.pushNamed(UserAppRoutes.appSettignScreen.name);
                      }),
                    ]),

                    20.h.verticalSpace,
                    _buildNotificationSwitch(),

                    22.h.verticalSpace,
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AppText(
                        text: "Copyright Notice - Tawheed App",
                        style: textStyle16SemiBold.copyWith(),
                      ),
                    ),
                    16.h.verticalSpace,

                    /// ---------------- COPYRIGHT BLOCK ----------------
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 20.h,
                      ),
                      decoration: _boxDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            text: "© Temheed Reizen - All rights reserved.",
                            style: textStyle14Regular.copyWith(
                              color: AppColors.primaryColor,
                            ),
                          ),
                          8.h.verticalSpace,
                          AppText(
                            text: "Version: 2025",
                            style: textStyle14Medium.copyWith(
                              fontSize: 14.sp,
                              color: AppColors.primaryColor.setOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    22.h.verticalSpace,
                    AppText(
                      text:
                          "The Temheed App and all related content, including (but not limited to) its design, structure, text, functionalities, images, logos, icons, documents, and database structure, are protected by copyright and are the property of Temheed.",
                      style: textStyle14Regular.copyWith(
                        fontSize: 14.sp,
                        color: AppColors.primaryColor.setOpacity(0.8),
                      ),
                    ),
                    10.h.verticalSpace,
                    AppText(
                      text:
                          "It is strictly prohibited, without prior written permission from Temheed Reizen, to:\n• Copy or reproduce the app, in whole or in part;• Reuse, publish, or distribute any content from the app;• Commercially exploit or imitate any functionalities, concepts, or designs.\nAny infringement of this copyright or unauthorized use of any part of the app may result in legal action and/or claims for damages.",
                      style: textStyle14Regular.copyWith(
                        fontSize: 14.sp,
                        color: AppColors.primaryColor.setOpacity(0.8),
                      ),
                    ),
                    10.h.verticalSpace,

                    22.h.verticalSpace,

                    Row(
                      children: [
                        Expanded(
                          child: AppActionButton(
                            label: "Edit Profile",
                            icon: AppAssets.exit,
                            color: AppColors.blueColor,
                            onTap: () {
                              context.pushNamed(
                                UserAppRoutes.editProfileScreen.name,
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 15.w),
                        Expanded(
                          child: AppActionButton(
                            label: "Logout",
                            icon: AppAssets.exit,
                            color: AppColors.redColor,
                            onTap: () async {
                              await PrefHelper.clearTokens();
                              context.pushReplacementNamed(
                                UserAppRoutes.signInScreen.name,
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 40.h),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------- WIDGETS ----------------

  Widget _infoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: _boxDecoration(),
      child: Column(children: children),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        children: [
          Expanded(
            child: AppText(
              text: title,
              style: textStyle14Medium.copyWith(
                color: AppColors.primaryColor.setOpacity(0.5),
              ),
            ),
          ),
          AppText(
            text: value,
            style: textStyle14Regular.copyWith(color: AppColors.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _menuTile(String title) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 16.h),
      decoration: _boxDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            text: title,
            style: textStyle16SemiBold.copyWith(
              fontSize: 16.sp,
              color: AppColors.primaryColor,
            ),
          ),
          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 20.w),
            child: SvgIcon(AppAssets.arrow, size: 10.w),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSwitch() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 17.h),
      decoration: _boxDecoration(),
      child: StatefulBuilder(
        builder: (context, setState) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                text: "Notification",
                style: textStyle16SemiBold.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),

              CustomSwitchButton(
                initialValue: true,

                onChanged: (value) {
                  log("Notification status: $value");
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _menuitems(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          children: [
            Expanded(
              child: AppText(
                text: title,
                style: textStyle14Medium.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: SvgIcon(AppAssets.arrow, size: 10.w),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      border: BoxBorder.all(color: AppColors.primaryColor.setOpacity(0.2)),
      borderRadius: BorderRadius.circular(12.r),
      boxShadow: [
        BoxShadow(
          color: AppColors.blueColor.setOpacity(0.1),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
