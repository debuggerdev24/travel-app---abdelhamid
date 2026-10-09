import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';

/// Placeholder that matches the itinerary day card while today's plan loads.
class ItineraryListShimmer extends StatelessWidget {
  const ItineraryListShimmer({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.blueColor.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            color: AppColors.shimmerBaseColor.withValues(alpha: 0.45),
            child: Shimmer.fromColors(
              baseColor: AppColors.shimmerBaseColor,
              highlightColor: AppColors.shimmerHighlightColor,
              child: Row(
                children: [
                  _bar(width: 22.w, height: 22.w, radius: 11.r),
                  10.w.horizontalSpace,
                  _bar(width: 140.w, height: 16.h),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
            child: Shimmer.fromColors(
              baseColor: AppColors.shimmerBaseColor,
              highlightColor: AppColors.shimmerHighlightColor,
              child: Column(
                children: List.generate(itemCount, (index) {
                  return _ItineraryStepShimmer(isLast: index == itemCount - 1);
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItineraryStepShimmer extends StatelessWidget {
  const _ItineraryStepShimmer({required this.isLast});

  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14.h),
      child: Row(
        children: [
          _bar(width: 48.w, height: 14.h),
          10.w.horizontalSpace,
          _bar(width: 32.w, height: 32.w, radius: 16.r),
          12.w.horizontalSpace,
          _bar(width: 140.w, height: 14.h),
        ],
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
