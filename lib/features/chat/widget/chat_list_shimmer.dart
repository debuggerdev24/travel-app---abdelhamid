import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';

/// Placeholder that matches a chat row while conversations are loading.
class ChatListShimmer extends StatelessWidget {
  const ChatListShimmer({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      itemCount: itemCount,
      separatorBuilder: (_, __) => 20.h.verticalSpace,
      itemBuilder: (_, __) => const _ChatRowShimmer(),
    );
  }
}

class _ChatRowShimmer extends StatelessWidget {
  const _ChatRowShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBaseColor,
      highlightColor: AppColors.shimmerHighlightColor,
      child: Row(
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: const BoxDecoration(
              color: AppColors.shimmerBaseColor,
              shape: BoxShape.circle,
            ),
          ),
          15.w.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _bar(width: 150.w, height: 16.h),
                    const Spacer(),
                    _bar(width: 72.w, height: 12.h),
                  ],
                ),
                8.h.verticalSpace,
                _bar(width: 110.w, height: 12.h),
              ],
            ),
          ),
        ],
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
