import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';

/// Placeholder that matches the trip payment summary while payment data loads.
class PaymentSectionShimmer extends StatelessWidget {
  const PaymentSectionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(11.w, 10.h, 11.w, 12.h),
          child: const _SummaryCardShimmer(),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(11.w, 4.h, 11.w, 8.h),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PastPaymentHeaderShimmer(),
              PastPaymentRowShimmer(),
            ],
          ),
        ),
        24.h.verticalSpace,
      ],
    );
  }
}

class _SummaryCardShimmer extends StatelessWidget {
  const _SummaryCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: AppColors.shimmerBaseColor,
        highlightColor: AppColors.shimmerHighlightColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _bar(width: 120.w, height: 13.h),
            12.h.verticalSpace,
            _priceRow(),
            6.h.verticalSpace,
            _priceRow(),
            6.h.verticalSpace,
            _priceRow(),
            12.h.verticalSpace,
            _bar(width: double.infinity, height: 36.h, radius: 8.r),
          ],
        ),
      ),
    );
  }

  Widget _priceRow() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          _bar(width: 70.w, height: 14.h),
          const Spacer(),
          _bar(width: 56.w, height: 14.h),
        ],
      ),
    );
  }
}

class _PastPaymentHeaderShimmer extends StatelessWidget {
  const _PastPaymentHeaderShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBaseColor,
      highlightColor: AppColors.shimmerHighlightColor,
      child: Row(
        children: [
          _bar(width: 130.w, height: 18.h),
          const Spacer(),
          _bar(width: 64.w, height: 14.h),
        ],
      ),
    );
  }
}

/// One past-payment row while the history list is loading.
class PastPaymentRowShimmer extends StatelessWidget {
  const PastPaymentRowShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
      child: Shimmer.fromColors(
        baseColor: AppColors.shimmerBaseColor,
        highlightColor: AppColors.shimmerHighlightColor,
        child: Row(
          children: [
            Container(
              width: 24.w,
              height: 24.w,
              decoration: const BoxDecoration(
                color: AppColors.shimmerBaseColor,
                shape: BoxShape.circle,
              ),
            ),
            12.w.horizontalSpace,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bar(width: 120.w, height: 13.h),
                6.h.verticalSpace,
                _bar(width: 48.w, height: 14.h),
                6.h.verticalSpace,
                _bar(width: 100.w, height: 12.h),
              ],
            ),
            const Spacer(),
            _bar(width: 96.w, height: 28.h, radius: 20.r),
          ],
        ),
      ),
    );
  }
}

Widget _bar({required double width, required double height, double? radius}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: AppColors.shimmerBaseColor,
      borderRadius: BorderRadius.circular(radius ?? 6.r),
    ),
  );
}
