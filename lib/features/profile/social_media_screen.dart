import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';


class SocialMediaScreen extends StatelessWidget {
  SocialMediaScreen({super.key});

  final List<Map<String, dynamic>> socialList = [
    {
      "icon": AppAssets.instagram,
      "title": "Instagram",
      "sub": "Follow our travel highlights & stories",
    },
    {
      "icon": AppAssets.tiktok,
      "title": "TikTok",
      "sub": "Watch short videos & trip moments",
    },
    {
      "icon": AppAssets.facebook,
      "title": "Facebook",
      "sub": "Join our travel community & get updates",
    },
    {
      "icon": AppAssets.whatsapp,
      "title": "WhatsApp",
      "sub": "Chat directly with our support team",
    },
    {
      "icon": AppAssets.starfill,
      "title": "Leave us a Google Review",
      "sub": "",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 27.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 35.h),
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: SvgIcon(AppAssets.backIcon, size: 28.5.w),
                    ),
                  ),
                  50.w.horizontalSpace,
                  AppText(
                    textAlign: TextAlign.center,
                    text: "Social Media \nLinks",
                    style: textStyle32Bold.copyWith(
                      fontSize: 26.sp,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              12.h.verticalSpace,

              AppText(
                text:
                    "“Stay connected with us! Follow our latest updates, photos, and travel stories on social media.”",
                style: textStyle14Regular.copyWith(
                  fontSize: 14.sp,
                  color: AppColors.textcolor.setOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),

              22.h.verticalSpace,

              ListView.builder(
                shrinkWrap: true,
                itemCount: socialList.length,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final item = socialList[index];

                  return Container(
                    margin: EdgeInsets.only(bottom: 16.h),
                    padding: EdgeInsets.symmetric(
                      vertical: 15.h,
                      horizontal: 20.w,
                    ),
                    decoration: BoxDecoration(
                      border: BoxBorder.all(
                        color: AppColors.primaryColor.setOpacity(0.2),
                      ),
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.blueColor.setOpacity(0.1),
                          blurRadius: 1,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        /// ICON
                        SvgIcon(item["icon"], size: 40.w),

                        14.w.horizontalSpace,

                        /// TITLE + SUBTITLE
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                text: item["title"],
                                style: textStyle16SemiBold.copyWith(
                                  fontSize: 18.sp,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              if (item["sub"] != "")
                                AppText(
                                  text: item["sub"],
                                  style: textStyle14Regular.copyWith(
                                    fontSize: 14.sp,
                                    color: AppColors.primaryColor.setOpacity(
                                      0.8,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        /// OPEN ICON
                        Padding(
                          padding: EdgeInsets.only(bottom: 24.h),
                          child: Icon(
                            Icons.open_in_new,
                            size: 24.w,
                            color: AppColors.blueColor,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
