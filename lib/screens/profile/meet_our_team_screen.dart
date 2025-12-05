import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';

class MeetOurTeamScreen extends StatelessWidget {
  const MeetOurTeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 27.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            22.h.verticalSpace,
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: SvgIcon(AppAssets.backIcon, size: 28.w),
                    ),
                  ),
                  AppText(
                    text: "Meet Our Team",
                    style: textStyle32Bold.copyWith(
                      fontSize: 26.sp,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),

              // Title

22.h.verticalSpace,
              // Team Cards
              _teamCard(
                imageUrl:
                    AppAssets.profile1,
                name: "Ali Khan",
                role: "Admin",
                description:
                    "Oversees Umrah operations and customer experience.",
                roleColor: AppColors.blueColor
              ),

24.h.verticalSpace,
              _teamCard(
                imageUrl:
                    AppAssets.profile2,
                name: "Ahmed Khan",
                role: "Guide",
                description:
                    "Assists with bookings, documentation, and client support.",
                roleColor:AppColors.blueColor
              ),

24.h.verticalSpace,
              _teamCard(
                imageUrl:
                                       AppAssets.profile3,

                name: "Fatima Noor",
                role: "Support Team",
                description:
                    "Provides guidance and answers user queries with care.",
                roleColor: AppColors.blueColor
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _teamCard({
    required String imageUrl,
    required String name,
    required String role,
    required String description,
    required Color roleColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.white,
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.1)),
        boxShadow: [
      BoxShadow(
                      color: AppColors.blueColor.withOpacity(0.08),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40.w,
            backgroundImage: NetworkImage(imageUrl),
          ),
16.w.horizontalSpace,
          // Text Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + Role
                Row(
                  children: [
                    AppText(
                 text:      name,
                      style: textStyle14Medium.copyWith(
                        fontSize: 16.sp,
                    color: AppColors.primaryColor
                      ),
                    ),
6.w.horizontalSpace,                    AppText(
                    text:   role,
                      style: textStyle14Medium.copyWith(
                        fontSize: 12.sp,
                        color: roleColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

4.h.verticalSpace,
                AppText(
               text:    description,
                  style: textStyle12Regular.copyWith(
                    color:AppColors.primaryColor.withOpacity(0.8),
                    fontSize: 12.sp,
                   
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
