import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';

class AppButton extends StatelessWidget {
  final String? title;
  final EdgeInsets? margin;
  final double? width, fontSize, verticalPadding, horizontalPadding;
  final Color? buttonColor, titleColor;
  final VoidCallback? onTap, onLongPress;
  final Widget? child;
  final bool isLoading;

  const AppButton({
    super.key,
    this.title,
    this.margin,
    this.onTap,
    this.width,
    this.buttonColor,
    this.child,
    this.fontSize,
    this.verticalPadding,
    this.onLongPress,
    this.horizontalPadding,
    this.titleColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: isLoading ? null : onLongPress,
      onTap: isLoading ? null : onTap,
      child: Container(
        width: width ?? double.infinity,
        alignment: Alignment.center,
        margin: margin,
        padding: EdgeInsets.symmetric(
          vertical: verticalPadding == null ? 14.h : verticalPadding!.h,
          horizontal: horizontalPadding == null ? 0 : horizontalPadding!.w,
        ),
        decoration: BoxDecoration(
          color: (isLoading || onTap == null)
              ? (buttonColor ?? AppColors.blueColor).setOpacity(0.6)
              : buttonColor ?? AppColors.blueColor,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.blueColor.setOpacity(0.1),
              blurRadius: 3,
              spreadRadius: 0,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: isLoading
            ? SizedBox(
                height: 20.h,
                width: 20.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : (title == null)
            ? child
            : AppText(
                overflow: TextOverflow.ellipsis,
                text: title ?? "",
                style: textStyle18Bold.copyWith(
                  fontSize: fontSize ?? 18.sp,
                  color: titleColor ?? AppColors.whiteColor,
                ),
              ),
      ),
    );
  }
}

class AppActionButton extends StatelessWidget {
  final String label;
  final String icon;
  final Color color;
  final VoidCallback onTap;

  const AppActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(vertical: 15.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.r),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgIcon(icon, size: 24.w),
          8.w.horizontalSpace,
          AppText(
            text: label,
            style: textStyle14Medium.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
