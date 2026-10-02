import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';
import 'package:travel_app_abdelhamid/core/extensions/color_extensions.dart';

/// Placeholder that matches the document cards while documents are loading.
class DocumentListShimmer extends StatelessWidget {
  const DocumentListShimmer({super.key, this.itemCount = 2});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: _shimmerBar(width: 110.w, height: 36.h, radius: 30.r),
          ),
          20.h.verticalSpace,
          _shimmerBar(width: 140.w, height: 16.h),
          12.h.verticalSpace,
          ...List.generate(itemCount, (_) => const _DocumentCardShimmer()),
        ],
      ),
    );
  }
}

class _DocumentCardShimmer extends StatelessWidget {
  const _DocumentCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primaryColor.setOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.setOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: AppColors.shimmerBaseColor,
        highlightColor: AppColors.shimmerHighlightColor,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bar(width: 140.w, height: 126.h, radius: 12.r),
                14.w.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _bar(width: 120.w, height: 16.h),
                      12.h.verticalSpace,
                      _bar(width: 90.w, height: 12.h),
                      8.h.verticalSpace,
                      _bar(width: 110.w, height: 12.h),
                    ],
                  ),
                ),
              ],
            ),
            16.h.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: _bar(width: double.infinity, height: 46.h, radius: 25.r),
                ),
                20.w.horizontalSpace,
                Expanded(
                  child: _bar(width: double.infinity, height: 46.h, radius: 25.r),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _shimmerBar({
  required double width,
  required double height,
  double? radius,
}) {
  return Shimmer.fromColors(
    baseColor: AppColors.shimmerBaseColor,
    highlightColor: AppColors.shimmerHighlightColor,
    child: _bar(width: width, height: height, radius: radius),
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
