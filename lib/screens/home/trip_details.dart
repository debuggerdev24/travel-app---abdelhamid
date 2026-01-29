import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_button.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/core/widgets/feed_back_card.dart';
import 'package:trael_app_abdelhamid/core/widgets/packge_details_card.dart';
import 'package:trael_app_abdelhamid/provider/home/home_provider.dart';
import 'package:trael_app_abdelhamid/routes/user_routes.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';


class TripDetailsScreen extends StatelessWidget {
  const TripDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();
    final trip = tripProvider.selectedTrip;

    if (trip == null) {
      return const Scaffold(body: Center(child: Text("No Trip Selected")));
    }

    final isUpcoming = tripProvider.upcomingtripList.contains(trip);

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 27.w, vertical: 15.h),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: SvgIcon(AppAssets.backIcon, size: 28.5.w),
                    ),
                    30.w.horizontalSpace,
                    Expanded(
                      child: AppText(
                        text: trip.title,
                        style: textStyle32Bold.copyWith(
                          fontSize: 26.sp,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Image.asset(
                trip.image,
                height: 250.h,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 27.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    12.h.verticalSpace,

                    AppText(text: trip.title, style: textStyle16SemiBold),

                    14.h.verticalSpace,

                    Row(
                      children: [
                        SvgIcon(AppAssets.pin, size: 22.w),
                        14.w.horizontalSpace,
                        Expanded(
                          child: AppText(
                            text: trip.location,
                            style: textStyle14Regular.copyWith(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                        12.w.horizontalSpace,
                        SvgIcon(AppAssets.calendar, size: 22.w),
                        14.w.horizontalSpace,
                        AppText(
                          text: trip.date,
                          style: textStyle14Regular.copyWith(
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),

                    38.h.verticalSpace,
                    sectionTitle("About Us"),
                    2.h.verticalSpace,
                    AppText(
                      text: trip.description,
                      style: textStyle14Regular.copyWith(
                        color: AppColors.primaryColor.setOpacity(0.5),
                      ),
                    ),
                    22.h.verticalSpace,
                    if (isUpcoming) ...[
                      AppText(
                        text: "Package Details",
                        style: textStyle16SemiBold,
                      ),
                      PackageDetailsCard(),
                      AppText(text: "Note:", style: textStyle16SemiBold),
                      8.h.verticalSpace,
                      AppText(
                        text: "Prices may vary depending on airline & hotel:",
                        style: textStyle14Regular.copyWith(
                          color: AppColors.primaryColor.setOpacity(0.6),
                        ),
                      ),
                      42.h.verticalSpace,
                      AppButton(
                        title: "Select Package & Room Type",
                        onTap: () {
                          context.pushNamed(UserAppRoutes.roomDetailScren.name);
                        },
                      ),
                      42.h.verticalSpace,
                    ],

                    // Past Trip Section
                    if (!isUpcoming) ...[
                      statusTag(trip.status),
                      22.h.verticalSpace,
                      simpleCard(
                        title: "Payment Summary",
                        rows: [
                          rowItem("Package Cost", "\$2,500"),
                          rowItem("Status", "Paid"),
                        ],
                      ),
                      20.h.verticalSpace,
                      if (tripProvider.reviewSubmitted) ...[
                        FeedbackReviewCard(),
                        20.h.verticalSpace,
                      ],
                      simpleCard(
                        rows: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AppText(
                                text: "Support Contact",
                                style: textStyle16SemiBold,
                              ),
                              SvgIcon(AppAssets.phone, size: 24.w),
                            ],
                          ),
                        ],
                      ),
                      42.h.verticalSpace,
                      AppButton(
                        title: tripProvider.reviewSubmitted
                            ? "Share on Google Review"
                            : "Share on Review",
                        onTap: () => context.pushNamed(
                          UserAppRoutes.feedbackScreen.name,
                        ),
                      ),
                      40.h.verticalSpace,
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: AppText(text: text, style: textStyle16SemiBold),
    );
  }

  Widget rowItem(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            text: title,
            style: textStyle14Regular.copyWith(color: AppColors.primaryColor),
          ),
          AppText(
            text: value,
            style: textStyle14Regular.copyWith(color: AppColors.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget statusTag(String status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26.r),
        border: Border.all(color: AppColors.secondary),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgIcon(AppAssets.check, size: 17.w),
          10.w.horizontalSpace,
          AppText(
            text: status,
            style: textPopinnsMeidium.copyWith(color: AppColors.secondary),
          ),
        ],
      ),
    );
  }

  Widget simpleCard({String? title, required List<Widget> rows}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.blueColor.setOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.primaryColor.setOpacity(0.2)),
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: AppText(text: title, style: textStyle16SemiBold),
            ),
          ...rows,
        ],
      ),
    );
  }
}
