import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';

/// Placeholder that matches the hotel stay card while hotels are loading.
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
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.blueColor.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
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
                  const Spacer(),
                  _bar(width: 64.w, height: 22.h, radius: 20.r),
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
                children: [
                  Row(
                    children: [
                      _bar(width: 80.w, height: 18.h),
                      const Spacer(),
                      _bar(width: 36.w, height: 36.w, radius: 18.r),
                      const Spacer(),
                      _bar(width: 80.w, height: 18.h),
                    ],
                  ),
                  16.h.verticalSpace,
                  Row(
                    children: [
                      _bar(width: 70.w, height: 28.h),
                      16.w.horizontalSpace,
                      _bar(width: 70.w, height: 28.h),
                      16.w.horizontalSpace,
                      _bar(width: 70.w, height: 28.h),
                    ],
                  ),
                  16.h.verticalSpace,
                  _bar(width: double.infinity, height: 14.h),
                  8.h.verticalSpace,
                  _bar(width: 160.w, height: 14.h),
                ],
              ),
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
