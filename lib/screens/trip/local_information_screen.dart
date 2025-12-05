import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';

class LocalInformationScreen extends StatelessWidget {
  const LocalInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- Header ----------------
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
                  14.w.horizontalSpace,
                  AppText(
                    text: "Local Information",
                    style: textStyle32Bold.copyWith(
                      fontSize: 26.sp,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 27.w),
                children: [
                  // ---------------- Link Card ----------------
                  _linkCard(),

                  20.h.verticalSpace,

                  // ---------------- Info Card ----------------
                  _infoCard(),
                ],
              ),
            ),
            AppText(
              text: "",
              style: textStyle14Regular.copyWith(
                fontSize: 14.sp,
                color: AppColors.primaryColor.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------- LINK CARD -------------------------
  Widget _linkCard() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AppText(
                  text: "https://sar.hhr.sa/timetable.",
                  style: textStyle16SemiBold.copyWith(
                    decoration: TextDecoration.underline,
                    decorationStyle: TextDecorationStyle.solid,
                    decorationThickness: 2,
                    decorationColor: AppColors.primaryColor.withOpacity(0.2),
                    color: AppColors.primaryColor,
                    fontSize: 16.sp,
                  ),
                ),
              ),
              SvgIcon(AppAssets.share, size: 24.w),
            ],
          ),
          8.h.verticalSpace,
          AppText(
            text: "Haramain High-Speed Train \nwebsite:",
            style: textStyle14Regular.copyWith(
              fontSize: 14.sp,
              color: AppColors.primaryColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------- INFO CARD -------------------------
  Widget _infoCard() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 18.w),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(AppAssets.landmark, "Prayer Times"),
          AppText(
            text: "Auto fetch based on location",
            style: textStyle14Regular.copyWith(
              fontSize: 16.sp,
              color: AppColors.primaryColor.withOpacity(0.65),
            ),
          ),
          36.h.verticalSpace,

          _infoRow(AppAssets.weather, "Weather"),

          AppText(
            text: "Avg. 25–32°C in Feb",
            style: textStyle14Regular.copyWith(
              fontSize: 16.sp,
              color: AppColors.primaryColor.withOpacity(0.65),
            ),
          ),
          36.h.verticalSpace,

          _infoRow(AppAssets.sim, "SIM Cards"),

          AppText(
            text: "STC, Mobily (available at airport)",
            style: textStyle14Regular.copyWith(
              fontSize: 16.sp,
              color: AppColors.primaryColor.withOpacity(0.65),
            ),
          ),
          36.h.verticalSpace,
          _infoRow(AppAssets.alarm, "Time Zone"),
          AppText(
            text: "GMT+3 (2.5 hrs behind IST)",
            style: textStyle14Regular.copyWith(
              fontSize: 16.sp,
              color: AppColors.primaryColor.withOpacity(0.65),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------- INFO ROW -------------------------
  Widget _infoRow(String icon, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgIcon(icon, size: 24.w),
          14.w.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: title,
                  style: textStyle16SemiBold.copyWith(
                    fontSize: 18.sp,
                    color: AppColors.primaryColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
    color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.blueColor.withOpacity(0.1),
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
    );
  }
}
