import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';

class HealthSafetyScreen extends StatelessWidget {
  const HealthSafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 27.w,vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 35.h),
                        child: GestureDetector(
                          onTap: () => context.pop(),
                          child: SvgIcon(AppAssets.backIcon, size: 28.5.w),
                        ),
                      ),
                      50.w.horizontalSpace,
                      AppText(
                        textAlign: TextAlign.center,
                        text: "Health & Safety \nTips",
                        style: textStyle16SemiBold.copyWith(
                          fontSize: 26.sp,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  20.h.verticalSpace,
              AppText(
                text: "Heat & Group Safety",
                style: textStyle16SemiBold.copyWith(
                  fontSize: 18.sp,
                  color: AppColors.primaryColor.withOpacity(0.8),
                ),
              ),
            20.h.verticalSpace,
              _tipCard(
                AppAssets.health1,
                "Tip 1 : Stay hydrated",
              ),
              SizedBox(height: 14.h),

              _tipCard(
                AppAssets.health2,
                "Tip 2 : Use umbrella during daytime",
              ),
              SizedBox(height: 14.h),

              _tipCard(
                AppAssets.health3,
                "Tip 3 : Always carry hotel card",
              ),
              SizedBox(height: 14.h),

              _tipCard(
                AppAssets.health4,
                "Tip 4 : Stay with group during ziyarat",
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tipCard(String image, String title) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18.r),

      boxShadow: [
        BoxShadow(
          color: Colors.grey,
          blurRadius: 16,
          spreadRadius: 0,
          offset: const Offset(0, 7), 
        ),
      ],
    ),

    child: ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Stack(
        children: [
          SizedBox(
            height: 180.h,
            width: double.infinity,
            child: Image.asset(
              image,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.55),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned(
            left: 24.w,
            bottom: 12.h,
            child: AppText(
              text: title,
              style: textStyle14Italic.copyWith(
                color: Colors.white,
                fontSize: 15.sp,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

}
