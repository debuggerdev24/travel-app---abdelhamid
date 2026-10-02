import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';
import 'package:travel_app_abdelhamid/core/extensions/color_extensions.dart';

/// Placeholder that matches the hotel voucher card while hotels are loading.
class HotelListShimmer extends StatelessWidget {
  const HotelListShimmer({super.key, this.itemCount = 1});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(itemCount, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index == itemCount - 1 ? 0 : 20.h),
          child: const _HotelCardShimmer(),
        );
      }),
    );
  }
}

class _HotelCardShimmer extends StatelessWidget {
  const _HotelCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueColor.setOpacity(0.1),
            blurRadius: 6,
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
            Row(
              children: [
                _bar(width: 150.w, height: 16.h),
                const Spacer(),
                _bar(width: 24.w, height: 24.w, radius: 6.r),
              ],
            ),
            16.h.verticalSpace,
            _row(labelWidth: 55.w, valueWidth: 130.w),
            _row(labelWidth: 70.w, valueWidth: 160.w),
            _row(labelWidth: 55.w, valueWidth: 120.w),
            _row(labelWidth: 75.w, valueWidth: 110.w),
            _row(labelWidth: 80.w, valueWidth: 110.w),
            _row(labelWidth: 85.w, valueWidth: 90.w),
            _row(labelWidth: 70.w, valueWidth: 50.w),
          ],
        ),
      ),
    );
  }

  Widget _row({required double labelWidth, required double valueWidth}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          _bar(width: labelWidth, height: 14.h),
          20.w.horizontalSpace,
          _bar(width: valueWidth, height: 14.h),
        ],
      ),
    );
  }

  Widget _bar({
    required double width,
    required double height,
    double? radius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.shimmerBaseColor,
        borderRadius: BorderRadius.circular(radius ?? 6.r),
      ),
    );
  }
}
