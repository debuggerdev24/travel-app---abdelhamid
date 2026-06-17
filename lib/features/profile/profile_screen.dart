import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:travel_app_abdelhamid/core/core.dart';
import 'package:travel_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_button.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';
import 'package:travel_app_abdelhamid/core/widgets/custom_switch_button.dart';
import 'package:travel_app_abdelhamid/core/utils/server_media_url.dart';
import 'package:travel_app_abdelhamid/core/widgets/network_avatar.dart';
import 'package:travel_app_abdelhamid/core/widgets/shimmer_box.dart';
import 'package:travel_app_abdelhamid/provider/profile/profile_provider.dart';
import 'package:travel_app_abdelhamid/routes/user_routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                      text: "profile.title".tr(),
                      style: textStyle32Bold.copyWith(
                        fontSize: 26.sp,
                        color: Theme.of(context).colorScheme.onSurface,
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
                    final name = p?.fullName.isNotEmpty == true
                        ? p!.fullName
                        : '—';
                    final email = p?.email.isNotEmpty == true ? p!.email : '—';

                    final raw = p?.profileImageRaw.trim();
                    final avatarUrl = raw != null && raw.isNotEmpty
                        ? serverMediaUrl(raw)
                        : null;

                    return Column(
                      children: [
                        if (provider.isLoading && p == null)
                          ShimmerBox(
                            width: (50.r * 2),
                            height: (50.r * 2),
                            shape: BoxShape.circle,
                          )
                        else
                          NetworkAvatar(imageUrl: avatarUrl, radius: 50.r),
                        10.h.verticalSpace,
                        AppText(
                          text: name,
                          style: textStyle16SemiBold.copyWith(
                            fontSize: 18.sp,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        4.h.verticalSpace,
                        AppText(
                          text: provider.isLoading && p == null ? '—' : email,
                          style: textStyle14Regular.copyWith(
                            fontSize: 14.sp,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.8),
                          ),
                        ),

                        24.h.verticalSpace,
                        Align(
                          alignment: Alignment.centerLeft,
                          child: AppText(
                            text: "profile.personal_information".tr(),
                            style: textStyle16SemiBold.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        10.h.verticalSpace,
                        _infoCard(context, [
                          _infoRow(
                            context,
                            "profile.date_of_birth".tr(),
                            p != null ? p.displayDateOfBirth : "—",
                          ),
                          Divider(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.2),
                          ),
                          _infoRow(context, "profile.age".tr(), p?.displayAgeLabel ?? "—"),
                          Divider(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.2),
                          ),

                          _infoRow(
                            context,
                            "profile.gender".tr(),
                            p?.gender.isNotEmpty == true ? p!.gender : "—",
                          ),
                          Divider(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.2),
                          ),

                          _infoRow(
                            context,
                            "profile.nationality".tr(),
                            p?.nationality.isNotEmpty == true
                                ? p!.nationality
                                : "—",
                          ),
                          Divider(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.2),
                          ),

                          _infoRow(
                            context,
                            "profile.passport_number".tr(),
                            p?.passportNumber.isNotEmpty == true
                                ? p!.passportNumber
                                : "—",
                          ),
                          Divider(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.2),
                          ),

                          _infoRow(
                            context,
                            "profile.contact".tr(),
                            p?.phoneNumber.isNotEmpty == true
                                ? p!.phoneNumber
                                : "—",
                          ),
                          Divider(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.2),
                          ),

                          _infoRow(
                            context,
                            "profile.language".tr(),
                            p?.languages.isNotEmpty == true
                                ? p!.languages.join(', ')
                                : "—",
                          ),
                        ]),

                        20.h.verticalSpace,
                        GestureDetector(
                          onTap: () {
                            context.pushNamed(
                              UserAppRoutes.prayerTimesScreen.name,
                            );
                          },
                          child: _menuTile(context, "profile.prayer_times".tr()),
                        ),

                        22.h.verticalSpace,
                        GestureDetector(
                          onTap: () {
                            context.pushNamed(
                              UserAppRoutes.currencyMoneyScreen.name,
                              extra: DateTime.now().millisecondsSinceEpoch,
                            );
                          },
                          child: _menuTile(context, "profile.currency_converter".tr()),
                        ),

                        22.h.verticalSpace,
                        GestureDetector(
                          onTap: () {
                            _showLanguageBottomSheet(context, provider);
                          },
                          child: _menuTile(context, "profile.language".tr()),
                        ),

                        22.h.verticalSpace,

                        /// ---------------- HELP & SUPPORT ----------------
                        Align(
                          alignment: Alignment.centerLeft,
                          child: AppText(
                            text: "profile.help_support".tr(),
                            style: textStyle16SemiBold.copyWith(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        16.h.verticalSpace,
                        _infoCard(context, [
                          _menuitems(context, "profile.faqs".tr(), () {
                            context.pushNamed(UserAppRoutes.faqScreen.name);
                          }),
                          Divider(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.2),
                          ),

                          _menuitems(context, "profile.social_media_links".tr(), () {
                            context.pushNamed(
                              UserAppRoutes.socialMediaScreen.name,
                            );
                          }),
                          Divider(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.2),
                          ),

                          _menuitems(context, "profile.terms_conditions".tr(), () {
                            context.pushNamed(
                              UserAppRoutes.termsConditionScreen.name,
                            );
                          }),
                          Divider(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.2),
                          ),

                          _menuitems(context, "profile.privacy_policy".tr(), () {
                            context.pushNamed(
                              UserAppRoutes.privacyPolicyScreen.name,
                            );
                          }),
                          Divider(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.2),
                          ),

                          _menuitems(context, "profile.our_locations".tr(), () {
                            context.pushNamed(
                              UserAppRoutes.ourLocationsScreen.name,
                            );
                          }),
                          Divider(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.2),
                          ),

                          _menuitems(context, "profile.meet_our_team".tr(), () {
                            context.pushNamed(
                              UserAppRoutes.meetOurTeamScreen.name,
                            );
                          }),
                          Divider(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.2),
                          ),

                          _menuitems(context, "profile.feedback".tr(), () {
                            context.pushNamed(
                              UserAppRoutes.profileFeedbackScreen.name,
                            );
                          }),
                          Divider(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.2),
                          ),

                          _menuitems(context, "profile.app_settings".tr(), () {
                            context.pushNamed(
                              UserAppRoutes.appSettignScreen.name,
                            );
                          }),
                        ]),

                        20.h.verticalSpace,
                        _buildNotificationSwitch(context),

                        22.h.verticalSpace,
                        Align(
                          alignment: Alignment.centerLeft,
                          child: AppText(
                            text: "Copyright Notice - Tawheed App".tr(),
                            style: textStyle16SemiBold.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
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
                          decoration: _boxDecoration(context),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                text: "© Temheed Reizen - All rights reserved.".tr(),
                                style: textStyle14Regular.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                              8.h.verticalSpace,
                              AppText(
                                text: "Version: 2025".tr(),
                                style: textStyle14Medium.copyWith(
                                  fontSize: 14.sp,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        22.h.verticalSpace,
                        AppText(
                          text:
                              "The Temheed App and all related content, including (but not limited to) its design, structure, text, functionalities, images, logos, icons, documents, and database structure, are protected by copyright and are the property of Temheed.".tr(),
                          style: textStyle14Regular.copyWith(
                            fontSize: 14.sp,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.8),
                          ),
                        ),
                        10.h.verticalSpace,
                        AppText(
                          text:
                              "It is strictly prohibited, without prior written permission from Temheed Reizen, to:\n• Copy or reproduce the app, in whole or in part;• Reuse, publish, or distribute any content from the app;• Commercially exploit or imitate any functionalities, concepts, or designs.\nAny infringement of this copyright or unauthorized use of any part of the app may result in legal action and/or claims for damages.".tr(),
                          style: textStyle14Regular.copyWith(
                            fontSize: 14.sp,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.8),
                          ),
                        ),
                        10.h.verticalSpace,

                        22.h.verticalSpace,

                        Row(
                          children: [
                            Expanded(
                              child: AppActionButton(
                                label: "profile.edit_profile".tr(),
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
                                label: "profile.logout".tr(),
                                icon: AppAssets.exit,
                                color: AppColors.redColor,
                                onTap: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Logout'.tr()),
                                      content: Text(
                                        'Are you sure you want to logout?'.tr(),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: Text('Cancel'.tr()),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: Text('Yes'.tr()),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true) {
                                    await PrefHelper.clearTokens();
                                    if (context.mounted) {
                                      context.pushReplacementNamed(
                                        UserAppRoutes.signInScreen.name,
                                      );
                                    }
                                  }
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

  Widget _infoCard(BuildContext context, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: _boxDecoration(context),
      child: Column(children: children),
    );
  }

  Widget _infoRow(BuildContext context, String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        children: [
          Expanded(
            child: AppText(
              text: title,
              style: textStyle14Medium.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
          AppText(
            text: value,
            style: textStyle14Regular.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuTile(BuildContext context, String title) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 16.h),
      decoration: _boxDecoration(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            text: title,
            style: textStyle16SemiBold.copyWith(
              fontSize: 16.sp,
              color: Theme.of(context).colorScheme.onSurface,
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

  Widget _buildNotificationSwitch(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 17.h),
      decoration: _boxDecoration(context),
      child: StatefulBuilder(
        builder: (context, setState) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                text: "profile.notification".tr(),
                style: textStyle16SemiBold.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),

              CustomSwitchButton(
                value: true,

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

  Widget _menuitems(BuildContext context, String title, VoidCallback onTap) {
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
                  color: Theme.of(context).colorScheme.onSurface,
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

  void _showLanguageBottomSheet(BuildContext context, ProfileProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
            children: [
              AppText(
                text: "profile.select_language".tr(),
                style: textStyle16SemiBold.copyWith(
                  fontSize: 18.sp,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              20.h.verticalSpace,
              ...provider.languageOptions.map((lang) {
                final isSelected =
                    provider.profile?.languages.contains(lang) ?? false;
                return ListTile(
                  title: AppText(
                    text: lang,
                    style: textStyle14Medium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: AppColors.blueColor)
                      : null,
                  onTap: () async {
                    if (lang == 'Dutch') {
                      context.setLocale(const Locale('nl'));
                    } else if (lang == 'English') {
                      context.setLocale(const Locale('en'));
                    } else if (lang == 'French') {
                      context.setLocale(const Locale('fr'));
                    } else if (lang == 'Arabic') {
                      context.setLocale(const Locale('ar'));
                    }
                    
                    Navigator.pop(context);
                    
                    if (provider.profile != null) {
                      final updated = provider.profile!.copyWith(
                        languages: [lang],
                      );
                      await provider.saveProfile(updated);
                    }
                  },
                );
              }),
            ],
          ),
         ),
        );
      },
    );
  }

  BoxDecoration _boxDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: BoxBorder.all(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
      ),
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
