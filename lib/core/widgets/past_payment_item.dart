import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';

class PastPaymentItem extends StatelessWidget {
  final String id;
  final String amount;
  final String date;
  final VoidCallback onViewReceiptTap;

  const PastPaymentItem({
    super.key,
    required this.id,
    required this.amount,
    required this.date,
    required this.onViewReceiptTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 30.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgIcon(AppAssets.pastcheck, size: 18.w),
                    15.w.horizontalSpace,
                    AppText(
                      text: "$id - $amount",
                      style: textStyle14Regular.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
                8.h.verticalSpace,
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 37.w),
                  child: AppText(
                    text: "Paid $date",
                    style: textStyle14Regular.copyWith(
                      color: AppColors.primaryColor.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onViewReceiptTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.secondary, width: 1),
                borderRadius: BorderRadius.circular(26.r),
              ),
              child: AppText(
                text: "View Receipt",
                style: textStyle14Medium.copyWith(
                  color: AppColors.secondary,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
