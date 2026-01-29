import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';


class TripCard extends StatelessWidget {
  final String image;
  final String title;
  final String location;
  final String date;
  final String status;
  final VoidCallback onTap;

  const TripCard({
    Key? key,
    required this.image,
    required this.title,
    required this.location,
    required this.date,
    required this.status,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 24.h),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.blueColor.setOpacity(0.1),
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.primaryColor.setOpacity(0.2)),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
              child: Image.asset(
                image,
                height: 200.h,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(text: title, style: textStyle16SemiBold),
                  12.h.verticalSpace,

                  /// Location
                  Row(
                    children: [
                      AppText(
                        text: location,
                        style: textStyle14Regular.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),

                  12.h.verticalSpace,

                  /// Date
                  Row(
                    children: [
                      AppText(
                        text: date,
                        style: textStyle14Regular.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),

                  /// Status (Only show if not empty)
                  if (status.isNotEmpty) ...[
                    12.h.verticalSpace,
                    Row(
                      children: [
                        AppText(
                          text: "Status : ",
                          style: textStyle14Regular.copyWith(
                            color: AppColors.primaryColor,
                          ),
                        ),
                        AppText(
                          text: status,
                          style: textStyle14Medium.copyWith(
                            color: AppColors.blueColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
