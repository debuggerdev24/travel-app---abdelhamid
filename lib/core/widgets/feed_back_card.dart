import 'package:flutter/material.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';

class FeedbackReviewCard extends StatelessWidget {
  const FeedbackReviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.blueColor.setOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.primaryColor.setOpacity(0.2)),
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title
          const Text(
            "Your Feedback",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),

          10.verticalSpace,

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppText(
                    text: "5",
                    style: textStyle16SemiBold.copyWith(fontSize: 46.sp),
                  ),

                  /// Stars
                  Row(
                    children: List.generate(
                      5,
                      (_) => Icon(
                        Icons.star,
                        color: AppColors.lightyellowColor,
                        size: 18.sp,
                      ),
                    ),
                  ),

                  6.verticalSpace,
                  AppText(
                    text: "1 Review",
                    style: textStyle14Regular.copyWith(
                      fontSize: 12.sp,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              42.w.horizontalSpace,
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _ratingRow(5, 0.9),
                    _ratingRow(4, 0.7),
                    _ratingRow(3, 0.4),
                    _ratingRow(2, 0.2),
                    _ratingRow(1, 0.1),
                  ],
                ),
              ),
            ],
          ),

          Divider(
            height: 30.h,
            thickness: 1,
            color: AppColors.primaryColor.setOpacity(0.2),
          ),

          /// USER REVIEW SECTION
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24.r,
                backgroundImage: AssetImage(AppAssets.profilephoto),
              ),

              12.horizontalSpace,

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Name + Rating
                    Row(
                      children: [
                        AppText(
                          text: "Aisha Khan",
                          style: textStyle14Medium.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        12.w.horizontalSpace,
                        RatingBarIndicator(
                          rating: 5,
                          itemCount: 5,
                          itemSize: 18.w,
                          itemBuilder: (context, _) =>
                              Icon(Icons.star, color: Colors.amber),
                        ),
                      ],
                    ),
                    4.h.verticalSpace,
                    AppText(
                      text: "Jan 26, 2025",
                      style: textStyle14Regular.copyWith(fontSize: 12.sp),
                    ),

                    12.verticalSpace,
                  ],
                ),
              ),
            ],
          ),
          14.h.verticalSpace,
          AppText(
            text:
                "“My stay at Zenstone Retreat was absolutely wonderful. The atmosphere is so peaceful, surrounded by nature with beautiful stone pathways and a calming koi pond. The staff were incredibly welcoming and made sure everything was perfect. If you’re looking for a place to relax, recharge, and enjoy pure tranquility, this is the spot!”",
            style: textStyle14Regular.copyWith(color: AppColors.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _ratingRow(int number, double fill) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Container(
            width: 150.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(110.r),
              border: Border.all(color: AppColors.primaryColor.setOpacity(0.2)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(110.r),
              child: LinearProgressIndicator(
                value: fill,
                valueColor: AlwaysStoppedAnimation(AppColors.lightyellowColor),
                backgroundColor: Colors.transparent,
                minHeight: 6.h,
              ),
            ),
          ),
          10.horizontalSpace,
          Text(
            "$number",
            style: TextStyle(fontSize: 12.sp, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
