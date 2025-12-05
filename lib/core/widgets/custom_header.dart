import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';

class CustomHeaders extends StatelessWidget {
  final String image;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;

  const CustomHeaders({
    super.key,
    required this.image,
    this.onProfileTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
padding:  EdgeInsets.symmetric(horizontal: 27.w, ),      child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
      
        children: [
                       SvgIcon(AppAssets.appIcon,size: 52.w,),
      
          Row(
            children: [
              GestureDetector(
                onTap: onProfileTap,
                child: Container(
                  height: 42.h,
                  width: 42.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.blueColor,
                      width: 1,
                    ),
                  ),
                  child: CircleAvatar(
                    
                    backgroundImage: AssetImage(image),
                  ),
                ),
              ),
          
16.w.horizontalSpace,          
              /// ---- Notification Icon ----
              GestureDetector(
                onTap: onNotificationTap,
                child: Container(
                  height: 42.h,
                  width: 42.w,
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.blueColor.withOpacity(0.2),
                    border: Border.all(
                      color:AppColors.blueColor,
                      width: 1.w,
                    ),
                  ),
                  child: SvgIcon(AppAssets.notification,size: 14.sp,),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}