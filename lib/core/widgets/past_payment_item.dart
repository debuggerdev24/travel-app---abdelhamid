import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';

/// One row: badge, `#id - amount`, date line, [View Receipt].
/// When [isConfirmed] is false (e.g. API status still `pending`), shows a neutral badge and “Pending” copy.
class PastPaymentItem extends StatelessWidget {
  final String id;
  final String amount;
  final String date;
  final VoidCallback onViewReceiptTap;
  final bool isConfirmed;

  const PastPaymentItem({
    super.key,
    required this.id,
    required this.amount,
    required this.date,
    required this.onViewReceiptTap,
    this.isConfirmed = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 4.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: isConfirmed
                  ? AppColors.blueColor
                  : AppColors.primaryColor.setOpacity(0.35),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              isConfirmed ? Icons.check : Icons.schedule,
              color: Colors.white,
              size: 20.sp,
            ),
          ),
          12.w.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: '$id - $amount',
                  style: textStyle14Medium.copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15.sp,
                  ),
                ),
                4.h.verticalSpace,
                AppText(
                  text: isConfirmed ? 'Paid $date' : 'Pending · $date',
                  style: textStyle14Regular.copyWith(
                    color: AppColors.primaryColor.setOpacity(0.55),
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onViewReceiptTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.secondary, width: 1),
                borderRadius: BorderRadius.circular(26.r),
              ),
              child: AppText(
                text: 'View Receipt',
                style: textStyle14Medium.copyWith(
                  color: AppColors.secondary,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
