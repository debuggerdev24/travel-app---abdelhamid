import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';

class FeedbackReviewCard extends StatelessWidget {
  const FeedbackReviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title
          Text(
            "Your Feedback".tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
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
                    style: textStyle16SemiBold.copyWith(
                      fontSize: 46.sp,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),

                  /// Stars
                  Row(
                    children: List.generate(
                      5,
                      (_) => Icon(
                        Icons.star,
                        color: Theme.of(context).colorScheme.primary,
                        size: 18.sp,
                      ),
                    ),
                  ),

                  6.verticalSpace,
                  AppText(
                    text: "1 Review".tr(),
                    style: textStyle14Regular.copyWith(
                      fontSize: 12.sp,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),

              42.w.horizontalSpace,
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _ratingRow(context, 5, 0.9),
                    _ratingRow(context, 4, 0.7),
                    _ratingRow(context, 3, 0.4),
                    _ratingRow(context, 2, 0.2),
                    _ratingRow(context, 1, 0.1),
                  ],
                ),
              ),
            ],
          ),

          Divider(
            height: 30.h,
            thickness: 1,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),

          /// USER REVIEW SECTION
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24.r,
                backgroundImage: AssetImage(AppAssets.profilePhoto),
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
                          text: "Aisha Khan".tr(),
                          style: textStyle14Medium.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
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
                      text: "Jan 26, 2025".tr(),
                      style: textStyle14Regular.copyWith(
                        fontSize: 12.sp,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
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
                "“My stay at Zenstone Retreat was absolutely wonderful. The atmosphere is so peaceful, surrounded by nature with beautiful stone pathways and a calming koi pond. The staff were incredibly welcoming and made sure everything was perfect. If you’re looking for a place to relax, recharge, and enjoy pure tranquility, this is the spot!”".tr(),
            style: textStyle14Regular.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _ratingRow(BuildContext context, int number, double fill) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Container(
            width: 150.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(110.r),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(110.r),
              child: LinearProgressIndicator(
                value: fill,
                valueColor: AlwaysStoppedAnimation(
                  Theme.of(context).colorScheme.primary,
                ),
                backgroundColor: Colors.transparent,
                minHeight: 6.h,
              ),
            ),
          ),
          10.horizontalSpace,
          Text(
            "$number",
            style: TextStyle(
              fontSize: 12.sp,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
