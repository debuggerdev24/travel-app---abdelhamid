import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';

/// Placeholder that matches the itinerary steps while today's plan is loading.
class ItineraryListShimmer extends StatelessWidget {
  const ItineraryListShimmer({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBaseColor,
      highlightColor: AppColors.shimmerHighlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _bar(width: 160.w, height: 16.h),
          16.h.verticalSpace,
          ...List.generate(itemCount, (index) {
            return _ItineraryStepShimmer(isLast: index == itemCount - 1);
          }),
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
      padding: EdgeInsets.only(bottom: isLast ? 0 : 18.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              _bar(width: 32.w, height: 32.w, radius: 16.r),
              if (!isLast)
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10.h),
                  height: 30.h,
                  width: 1.5,
                  color: AppColors.shimmerBaseColor,
                ),
            ],
          ),
          22.w.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bar(width: 180.w, height: 16.h),
                8.h.verticalSpace,
                _bar(width: 90.w, height: 14.h),
              ],
            ),
          ),
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
