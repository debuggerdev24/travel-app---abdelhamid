import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/utils/pref_helper.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_button.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';
import 'package:travel_app_abdelhamid/routes/user_routes.dart';

class GuideProfileScreen extends StatelessWidget {
  const GuideProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            20.h.verticalSpace,
            Center(child: SvgIcon(AppAssets.homeIcon, size: 100.w)),
            20.h.verticalSpace,
            Center(
              child: AppText(
                text: "Guide Profile",
                style: textStyle32Bold.copyWith(color: AppColors.secondary),
              ),
            ),
            40.h.verticalSpace,
            _buildProfileItem(
              title: "Name",
              value: "Guide User",
              icon: Icons.person,
            ),
            20.h.verticalSpace,
            _buildProfileItem(
              title: "Email",
              value: "guide@gmail.com",
              icon: Icons.email,
            ),
            20.h.verticalSpace,
            _buildProfileItem(
              title: "Role",
              value: "Tour Guide",
              icon: Icons.work,
            ),
            20.h.verticalSpace,
            _buildProfileItem(
              title: "Experience",
              value: "5+ Years",
              icon: Icons.star,
            ),
            40.h.verticalSpace,
            AppText(text: "Settings", style: textStyle18Bold),
            20.h.verticalSpace,
            _buildSettingItem(
              title: "Edit Profile",
              icon: Icons.edit,
              onTap: () {
                // Static action - no API
              },
            ),
            10.h.verticalSpace,
            _buildSettingItem(
              title: "Notifications",
              icon: Icons.notifications,
              onTap: () {
                // Static action - no API
              },
            ),
            10.h.verticalSpace,
            _buildSettingItem(
              title: "Privacy Policy",
              icon: Icons.privacy_tip,
              onTap: () {
                // Static action - no API
              },
            ),
            40.h.verticalSpace,
            AppButton(
              title: "Logout",
              onTap: () async {
                await PrefHelper.clearTokens();
                if (context.mounted) {
                  context.pushReplacementNamed(UserAppRoutes.signInScreen.name);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24.sp, color: AppColors.secondary),
          16.w.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: title,
                  style: textStyle14Regular.copyWith(color: Colors.grey),
                ),
                4.h.verticalSpace,
                AppText(text: value, style: textStyle16SemiBold),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.secondary, size: 24.sp),
            16.w.horizontalSpace,
            Expanded(
              child: AppText(text: title, style: textStyle16SemiBold),
            ),
            Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
