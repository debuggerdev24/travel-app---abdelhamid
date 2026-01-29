import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';


class EmergencyContactsScreen extends StatelessWidget {
  const EmergencyContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 31.w, vertical: 27.h),
              child: Row(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: SvgIcon(AppAssets.backIcon, size: 28.5.w),
                    ),
                  ),
                  13.w.horizontalSpace,
                  AppText(
                    text: "Emergency Contacts",
                    style: textStyle32Bold.copyWith(
                      fontSize: 26.sp,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),

            // Cards
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 27.w),
                children: [
                  _contactCard(
                    title: "Medical",
                    rows: [
                      ["Local Hospital (Makkah)", "+966 12 572 3333"],
                      ["Ambulance", "997"],
                    ],
                  ),
                  _contactCard(
                    title: "Police",
                    rows: [
                      ["Makkah Police Helpline", "999"],
                    ],
                  ),
                  _contactCard(
                    title: "Group Leader",
                    rows: [
                      ["Sheikh Abdullah", "+966 55 123 4567"],
                      ["WhatsApp Support", "+91 98765 43210"],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------ Contact Card Widget ---------------
  Widget _contactCard({
    required String title,
    required List<List<String>> rows,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primaryColor.setOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueColor.setOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + Call Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                text: title,
                style: textStyle16SemiBold.copyWith(
                  fontSize: 18.sp,
                  color: AppColors.primaryColor.setOpacity(0.8),
                ),
              ),
              SvgIcon(AppAssets.phone, color: AppColors.secondary, size: 24.w),
            ],
          ),
          12.h.verticalSpace,
          // Contact Rows
          ...rows.map(
            (e) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120.w, // adjust if needed
                    child: AppText(
                      text: e[0],
                      style: textStyle14Regular.copyWith(
                        fontSize: 16.sp,
                        color: AppColors.primaryColor.setOpacity(0.8),
                      ),
                    ),
                  ),

                  // Colon
                  AppText(
                    text: " : ",
                    style: textStyle14Regular.copyWith(
                      fontSize: 16.sp,
                      color: AppColors.primaryColor.setOpacity(0.8),
                    ),
                  ),
                  16.w.horizontalSpace,
                  Expanded(
                    child: AppText(
                      text: e[1],
                      style: textStyle14Regular.copyWith(
                        fontSize: 16.sp,
                        color: AppColors.primaryColor.setOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
