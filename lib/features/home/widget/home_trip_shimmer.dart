import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';

/// Placeholder for the Next Prayer line while prayer times are loading.
class HomePrayerLineShimmer extends StatelessWidget {
  const HomePrayerLineShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Shimmer.fromColors(
        baseColor: AppColors.shimmerBaseColor,
        highlightColor: AppColors.shimmerHighlightColor,
        child: Row(
          children: [
            Container(
              width: 120.w,
              height: 14.h,
              decoration: BoxDecoration(
                color: AppColors.shimmerBaseColor,
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
            const Spacer(),
            Container(
              width: 1,
              height: 28.h,
              color: AppColors.shimmerBaseColor,
            ),
            12.w.horizontalSpace,
            Container(
              width: 48.w,
              height: 14.h,
              decoration: BoxDecoration(
                color: AppColors.shimmerBaseColor,
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder that matches the home [TripCard] while trips are loading.
class HomeTripShimmer extends StatelessWidget {
  const HomeTripShimmer({super.key, this.itemCount = 2, this.shrinkWrap = false});

  final int itemCount;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    if (shrinkWrap) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 13.5.w, vertical: 24.h),
        child: Column(
          children: List.generate(
            itemCount,
            (_) => const _HomeTripCardShimmer(),
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 13.5.w, vertical: 24.h),
      itemCount: itemCount,
      itemBuilder: (_, __) => const _HomeTripCardShimmer(),
    );
  }
}

class _HomeTripCardShimmer extends StatelessWidget {
  const _HomeTripCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.r),
          topRight: Radius.circular(12.r),
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
        ),
      ),
      child: Shimmer.fromColors(
        baseColor: AppColors.shimmerBaseColor,
        highlightColor: AppColors.shimmerHighlightColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.shimmerBaseColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _bar(width: 160.w, height: 16.h),
                      const Spacer(),
                      _bar(width: 20.w, height: 20.w, radius: 4.r),
                    ],
                  ),
                  12.h.verticalSpace,
                  Row(
                    children: [
                      _bar(width: 16.w, height: 16.w, radius: 8.r),
                      8.w.horizontalSpace,
                      _bar(width: 110.w, height: 14.h),
                    ],
                  ),
                  12.h.verticalSpace,
                  Row(
                    children: [
                      _bar(width: 16.w, height: 16.w, radius: 8.r),
                      8.w.horizontalSpace,
                      _bar(width: 150.w, height: 14.h),
                    ],
                  ),
                  12.h.verticalSpace,
                  Row(
                    children: [
                      _bar(width: 52.w, height: 14.h),
                      6.w.horizontalSpace,
                      _bar(width: 70.w, height: 14.h),
                    ],
                  ),
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
