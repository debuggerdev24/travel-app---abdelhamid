import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_button.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/core/widgets/custom_switch_button.dart';

class GroupInfoScreen extends StatelessWidget {
  final String name;
  final String image;

  const GroupInfoScreen({super.key, required this.name, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 60.h,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 0,
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: SvgIcon(AppAssets.backIcon, size: 28.5.w),
                      ),
                    ),
                    Center(
                      child: AppText(
                        text: "Group Info",
                        style: textStyle32Bold.copyWith(
                          fontSize: 26.sp,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              20.h.verticalSpace,

              /// ----------------------
              /// GROUP TOP SECTION UI
              /// ----------------------
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Group Image
                  CircleAvatar(
                    radius: 48.r,

                    backgroundImage: AssetImage(image),
                  ),

                  16.w.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          text: "${name} - Group",
                          style: textStyle18Bold.copyWith(
                            fontSize: 18.sp,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        5.h.verticalSpace,

                        AppText(
                          text: "Makkah, Madinah",
                          style: textStyle14Regular.copyWith(
                            fontSize: 16.sp,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        5.h.verticalSpace,
                        AppText(
                          text: "10 – 20 Feb 2025",
                          style: textStyle14Regular.copyWith(
                            color: AppColors.primaryColor,
                          ),
                        ),

                        SizedBox(height: 8.h),
                      ],
                    ),
                  ),
                ],
              ),
              12.h.verticalSpace,
              GestureDetector(
                onTap: () {},
                child: AppText(
                  text: "This group is for updates & travel tips",
                  style: textStyle14Regular.copyWith(
                    fontSize: 16.sp,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),

              25.h.verticalSpace,

              _buildInfoRow("Created By", "Ali Khan (Admin)"),
              5.h.verticalSpace,
              Divider(color: AppColors.primaryColor.withOpacity(0.2)),
              5.h.verticalSpace,
              _buildInfoRow("Created On", "01 Jan 2025"),

              20.h.verticalSpace,

              _buildNotificationSwitch(),

              30.h.verticalSpace,

              _buildSharedMedia(),

              25.h.verticalSpace,
  AppText(
            text: "Members",
            style: textStyle18Bold.copyWith(color: AppColors.primaryColor),
          ),
          14.h.verticalSpace,
              _buildMembersList(),

              35.h.verticalSpace,

              Row(
                children: [
                  Expanded(
                    child: AppActionButton(
                      label: "Exit",
                      icon: AppAssets.exit,
                      color: AppColors.blueColor,
                      onTap: () {},
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: AppActionButton(
                      label: "Delete",
                      icon: AppAssets.delete,
                      color: AppColors.redColor,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
              42.h.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          text: label,
          style: textStyle14Medium.copyWith(
            color: AppColors.primaryColor.withOpacity(0.5),
            fontSize: 14.sp,
          ),
        ),
        AppText(
          text: value,
          style: textStyle14Regular.copyWith(color: AppColors.primaryColor),
        ),
      ],
    );
  }

  Widget _buildNotificationSwitch() {

    return StatefulBuilder(
      builder: (context, setState) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(
              text: "Notification",
              style: textStyle18Bold.copyWith(color: AppColors.primaryColor),
            ),

      CustomSwitchButton(
  initialValue: true,
  onChanged: (value) {
    print("Notification status: $value");
  },
),

          ],
        );
      },
    );
  }

  Widget _buildSharedMedia() {
    final mediaList = [
      AppAssets.trip1,
      AppAssets.trip2,
      AppAssets.trip3,
      AppAssets.trip4,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(
              text: "Shared Media & Docs",
              style: textStyle18Bold.copyWith(color: AppColors.primaryColor,fontSize: 18.sp),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26.r),
                border: Border.all(color: AppColors.secondary),
              ),
              child: AppText(
                text: "View All",
                style: textStyle14Medium.copyWith(color: AppColors.secondary,fontSize: 12.sp),
              ),
            ),
          ],
        ),
       19.h.verticalSpace,

        SizedBox(
          height: 100.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: mediaList.length,
            separatorBuilder: (_, __) => SizedBox(width: 10.w),
            itemBuilder: (_, index) {
              return Container(
                width: 100.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  image: DecorationImage(
                    image: AssetImage(mediaList[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --------------------------
  // MEMBERS LIST
  // --------------------------
  Widget _buildMembersList() {
    final members = [
      {"name": "Ali Khan", "role": "Admin", "image": AppAssets.profilephoto},
      {"name": "Ahmed Khan", "role": "Guide", "image": AppAssets.profilephoto},
      {
        "name": "Support Team",
        "role": "Support Team",
        "image": AppAssets.profilephoto,
      },
    ];

    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: BoxBorder.all(color: AppColors.primaryColor.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueColor.withOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        
          ...members.map(
            (member) => Padding(
              padding:EdgeInsets.only(bottom: 10.h),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    backgroundImage: AssetImage(member["image"]!),
                  ),
              18.w.horizontalSpace,                  Expanded(
                    child: AppText(
                      text: member["name"]!,
                      style: textStyle12Regular.copyWith(
                        color: AppColors.primaryColor,
                        fontSize: 16.sp
                      ),
                    ),
                  ),
                  AppText(
                    text: member["role"]!,
                    style: textStyle14Medium.copyWith(color:AppColors.primaryColor.withOpacity(0.8)),
                  ),
                ],
              ),
            ),
          ),
Divider(indent: 10.w,endIndent: 10.w,),
10.h.verticalSpace,
          Center(
            child: AppText(
              text: "View All Members",
              style: textStyle18Bold.copyWith(color: AppColors.blueColor,fontSize: 16.sp),
            ),
          ),
        ],
      ),
    );
  }

  
}
