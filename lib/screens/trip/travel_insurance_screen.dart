import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_button.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:go_router/go_router.dart';

class TravelInsuranceScreen extends StatelessWidget {
  final String? imageFile;
  final String hotelName;
  final String address;

  const TravelInsuranceScreen({
    super.key,
    this.imageFile,
    required this.hotelName,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 26.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: SvgIcon(AppAssets.backIcon, size: 28.w),
                      ),
                    ),
                    AppText(
                      text: "Travel Insurance",
                      style: textStyle32Bold.copyWith(
                        fontSize: 24.sp,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),

              Image.asset(
                height: 300.h,
                imageFile ?? AppAssets.hotelvoucher,
                width: double.infinity,
              ),

              18.h.verticalSpace,

              /// ---------- Policy Number & Coverage ----------
              _infoSmallRow("Policy No.", "TRV2025"),
              _infoSmallRow("Coverage", "10 Feb – 20 Feb 2025"),

              18.h.verticalSpace,

              /// ---------- Coverage Box ----------
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blueColor.setOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: "Coverage Details:",
                      style: textStyle16SemiBold.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                    12.h.verticalSpace,
                    _coverageItem("Emergency Medical – \$10,000"),
                    _coverageItem("Trip Cancellation – \$500"),
                    _coverageItem("Lost Baggage – \$250"),
                    _coverageItem("Passport Loss – Covered"),
                    _coverageItem("Repatriation – Covered"),
                  ],
                ),
              ),

              20.h.verticalSpace,

              /// ---------- Emergency Contact ----------
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blueColor.setOpacity(0.1),
                      blurRadius: 6,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: "Emergency Contact:",
                      style: textStyle16SemiBold.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                    12.h.verticalSpace,
                    Row(
                      children: [
                        AppText(
                          text: "+91 22 6196 1234",
                          style: textStyle14Regular.copyWith(
                            color: AppColors.primaryColor,
                          ),
                        ),
                        Spacer(),
                        SvgIcon(AppAssets.call, size: 20.sp),
                      ],
                    ),
                    8.h.verticalSpace,
                    Row(
                      children: [
                        AppText(
                          text: "travelhelp@icicilombard.com",
                          style: textStyle14Regular.copyWith(
                            color: AppColors.primaryColor,
                          ),
                        ),
                        Spacer(),
                        SvgIcon(AppAssets.alarm, size: 20.sp),
                      ],
                    ),
                  ],
                ),
              ),

              25.h.verticalSpace,
            ],
          ),
        ),
      ),

      /// ---------- Bottom Download Button ----------
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 22.h),
        child: SizedBox(
          height: 50.h,
          width: double.infinity,
          child: AppButton(title: "Download", onTap: () {}),
        ),
      ),
    );
  }

  // Small info row
  Widget _infoSmallRow(String key, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          SizedBox(
            width: 90.w,
            child: AppText(
              text: key,
              style: textStyle14Regular.copyWith(
                fontSize: 14.sp,
                color: AppColors.primaryColor.setOpacity(0.8),
              ),
            ),
          ),
          AppText(text: ":", style: textStyle14Regular),
          4.w.horizontalSpace,
          Expanded(
            child: AppText(
              text: value,
              style: textStyle14Regular.copyWith(color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  // Coverage item
  Widget _coverageItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          SvgIcon(AppAssets.checkmark, size: 18.w),
          10.w.horizontalSpace,
          Expanded(
            child: AppText(
              text: text,
              style: textStyle14Regular.copyWith(color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
