import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';


class AppChip extends StatelessWidget {
  final bool isSelected;
  final String title;
  final String icon;
  final VoidCallback onTap;

  const AppChip({
    super.key,
    required this.isSelected,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(80.w),
          border: Border.all(
            width: 0.5,
            color: isSelected
                ? AppColors.secondary.setOpacity(0.3)
                : AppColors.primaryColor.setOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            SvgIcon(
              icon,
              color: isSelected
                  ? AppColors.secondary
                  : AppColors.primaryColor.setOpacity(0.8),
              size: 24.w,
            ),
            10.w.horizontalSpace,
            AppText(
              text: title,
              style: textPopinnsMeidium.copyWith(
                color: isSelected
                    ? AppColors.secondary
                    : AppColors.primaryColor.setOpacity(0.8),
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
