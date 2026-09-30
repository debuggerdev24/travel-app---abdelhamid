import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';

/// Placeholder that matches the trip details screen while details are loading.
class TripDetailsShimmer extends StatelessWidget {
  const TripDetailsShimmer({super.key, this.showPackages = true});

  final bool showPackages;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBaseColor,
      highlightColor: AppColors.shimmerHighlightColor,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 250.h,
              width: double.infinity,
              color: AppColors.shimmerBaseColor,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 13.5.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  12.h.verticalSpace,
                  _bar(width: 140.w, height: 16.h),
                  14.h.verticalSpace,
                  Row(
                    children: [
                      _dot(22.w),
                      14.w.horizontalSpace,
                      _bar(width: 100.w, height: 14.h),
                      const Spacer(),
                      _dot(22.w),
                      14.w.horizontalSpace,
                      _bar(width: 130.w, height: 14.h),
                    ],
                  ),
                  38.h.verticalSpace,
                  _bar(width: 90.w, height: 16.h),
                  16.h.verticalSpace,
                  _bar(width: double.infinity, height: 12.h),
                  8.h.verticalSpace,
                  _bar(width: 210.w, height: 12.h),
                  if (showPackages) ...[
                    22.h.verticalSpace,
                    _bar(width: 150.w, height: 16.h),
                    _packageCard(context, selected: true),
                    _packageCard(context, selected: false),
                  ] else ...[
                    22.h.verticalSpace,
                    _summaryCard(context),
                    20.h.verticalSpace,
                    _summaryCard(context, short: true),
                  ],
                  24.h.verticalSpace,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _packageCard(BuildContext context, {required bool selected}) {
    final borderColor = selected
        ? AppColors.secondary
        : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 14.h),
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _bar(width: 120.w, height: 16.h),
          16.h.verticalSpace,
          _bar(width: 110.w, height: 14.h),
          12.h.verticalSpace,
          _bulletRow(160.w),
          8.h.verticalSpace,
          _bulletRow(140.w),
          8.h.verticalSpace,
          _bulletRow(150.w),
          16.h.verticalSpace,
          Row(
            children: [
              _bar(width: 72.w, height: 14.h),
              6.w.horizontalSpace,
              _dot(16.w),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(BuildContext context, {bool short = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _bar(width: 140.w, height: 16.h),
          if (!short) ...[
            16.h.verticalSpace,
            _bar(width: double.infinity, height: 12.h),
            10.h.verticalSpace,
            _bar(width: double.infinity, height: 12.h),
          ],
        ],
      ),
    );
  }

  Widget _bulletRow(double width) {
    return Row(
      children: [
        _dot(6.w),
        12.w.horizontalSpace,
        _bar(width: width, height: 12.h),
      ],
    );
  }

  Widget _dot(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.shimmerBaseColor,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _bar({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.shimmerBaseColor,
        borderRadius: BorderRadius.circular(6.r),
      ),
    );
  }
}
