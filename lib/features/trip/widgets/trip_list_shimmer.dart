import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';

/// Placeholder that matches the My Trips card while the list is loading.
class TripListShimmer extends StatelessWidget {
  const TripListShimmer({super.key, this.itemCount = 2});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 13.5.w),
      itemCount: itemCount,
      itemBuilder: (_, __) => const _TripCardShimmer(),
    );
  }
}

class _TripCardShimmer extends StatelessWidget {
  const _TripCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Shimmer.fromColors(
        baseColor: AppColors.shimmerBaseColor,
        highlightColor: AppColors.shimmerHighlightColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.shimmerBaseColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(12.r),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bar(width: 120.w, height: 16.h),
                  12.h.verticalSpace,
                  Row(
                    children: [
                      _bar(width: 14.w, height: 14.w, radius: 7.r),
                      8.w.horizontalSpace,
                      _bar(width: 90.w, height: 12.h),
                      const Spacer(),
                      _bar(width: 14.w, height: 14.w, radius: 7.r),
                      8.w.horizontalSpace,
                      _bar(width: 110.w, height: 12.h),
                    ],
                  ),
                  14.h.verticalSpace,
                  _bar(width: 110.w, height: 26.h, radius: 8.r),
                ],
              ),
            ),
          ],
        ),
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
