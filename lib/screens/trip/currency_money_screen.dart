import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';


class CurrencyMoneyScreen extends StatelessWidget {
  const CurrencyMoneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 27.w),
              child: _contentSection(),
            ),
            _bullet("ATMs available near Haram", 37.w),
            40.h.verticalSpace,
            Image.asset(AppAssets.currency),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 27.w, vertical: 27.h),
      child: Row(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: SvgIcon(AppAssets.backIcon, size: 28.5.w),
            ),
          ),
          9.w.horizontalSpace,
          AppText(
            text: "Currency & Money",
            style: textStyle32Bold.copyWith(
              fontSize: 26.sp,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _contentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _priceRow("Recommended", "Saudi Riyal (SAR)"),
        _priceRow("Exchange Rate", "1 SAR ≈ 22 INR"),
        40.h.verticalSpace,
        AppText(
          text: "Payment Options",
          style: textStyle14Medium.copyWith(
            color: AppColors.primaryColor.setOpacity(0.8),
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.h),
          child: _bullet("International Debit/Credit Cards accepted", 0),
        ),
      ],
    );
  }

  Widget _bullet(String text, double leftPadding) {
    return Padding(
      padding: EdgeInsets.only(left: leftPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: "•  ",
            style: textStyle14Regular.copyWith(
              fontSize: 16.sp,
              color: AppColors.primaryColor.setOpacity(0.6),
            ),
          ),
          Expanded(
            child: AppText(
              text: text,
              style: textStyle14Regular.copyWith(
                fontSize: 16.sp,
                color: AppColors.primaryColor.setOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          AppText(
            text: title,
            style: textStyle14Medium.copyWith(
              color: AppColors.primaryColor.setOpacity(0.8),
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          24.w.horizontalSpace,
          AppText(
            text: ":",
            style: textStyle14Regular.copyWith(
              color: AppColors.primaryColor.setOpacity(0.8),
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          24.w.horizontalSpace,
          AppText(
            text: value,
            style: textStyle14Regular.copyWith(
              color: AppColors.primaryColor.setOpacity(0.7),
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
