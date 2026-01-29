import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';


class ItineraryStep extends StatelessWidget {
  final String icon;
  final String title;
  final String time;
  final bool isLast;
  final bool isCompleted;

  const ItineraryStep({
    super.key,
    required this.icon,
    required this.title,
    required this.time,
    this.isLast = false,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor = AppColors.blueColor.setOpacity(0.8);
    final Color inactiveColor = AppColors.primaryColor.setOpacity(0.2);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Timeline + Icon
        Column(
          children: [
            /// Icon
            SvgIcon(
              icon,
              size: 32.w,
              color: isCompleted
                  ? activeColor
                  : AppColors.primaryColor.setOpacity(0.8),
            ),

            /// Connector Line
            if (!isLast)
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.h),
                height: 30.h,
                width: 1.5,
                color: isCompleted ? activeColor : inactiveColor,
              ),
          ],
        ),

        22.w.horizontalSpace,

        /// Title + Time
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: title,
                style: textStyle14Medium.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 16.sp,
                  color: AppColors.primaryColor.setOpacity(0.8),
                ),
              ),

              4.h.verticalSpace,

              AppText(
                text: time,
                style: textStyle14Medium.copyWith(
                  fontSize: 14.sp,
                  color: AppColors.primaryColor.setOpacity(0.8),
                ),
              ),
            ],
          ),
        ),

        /// Checkmark on the right if completed
        if (isCompleted) SvgIcon(AppAssets.checkmark, size: 26.w),
      ],
    );
  }
}
