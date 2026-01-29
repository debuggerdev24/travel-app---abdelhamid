import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';


class TripDetialsCard extends StatelessWidget {
  final String title;
  final Map<String, String> infoMap;
  final double labelWidth; // <-- added

  const TripDetialsCard({
    super.key,
    required this.title,
    required this.infoMap,
    this.labelWidth = 130, // <-- default same as before
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primaryColor.setOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueColor.setOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(text: title, style: textStyle16SemiBold),
              SvgIcon(AppAssets.download, size: 24.w),
            ],
          ),
          SizedBox(height: 16.h),

          /// Show rows
          ...infoMap.entries.map((entry) {
            return buildRow(entry.key, entry.value);
          }).toList(),
        ],
      ),
    );
  }

  Widget buildRow(String key, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth.w,
            child: AppText(
              text: key,
              style: textStyle14Regular.copyWith(
                fontSize: 15.sp,
                color: AppColors.primaryColor.setOpacity(0.8),
              ),
            ),
          ),
          AppText(
            text: ":",
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.primaryColor.setOpacity(0.8),
            ),
          ),
          15.w.horizontalSpace,
          Expanded(
            child: AppText(
              text: value,
              style: textStyle14Regular.copyWith(
                fontSize: 15.sp,
                color: AppColors.primaryColor.setOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EscortContactCard extends StatelessWidget {
  final String name;
  final String phone;

  const EscortContactCard({super.key, required this.name, required this.phone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: AppColors.lightblueColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title
          AppText(text: "Escort Contact", style: textStyle16SemiBold),

          SizedBox(height: 10.h),

          /// Contact Name
          _buildRow("Escort Name", name),

          SizedBox(height: 12.h),

          /// Phone Row with icon
          Row(
            children: [
              Expanded(child: _buildRow("Phone", phone)),
              SvgIcon(
                AppAssets.phone,
                size: 20.sp,
                color: AppColors.primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String key, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110.w,
          child: AppText(
            text: key,
            style: textStyle14Regular.copyWith(
              fontSize: 15.sp,
              color: AppColors.primaryColor.setOpacity(0.8),
            ),
          ),
        ),
        AppText(
          text: ":",
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColors.primaryColor.setOpacity(0.8),
          ),
        ),
        10.w.horizontalSpace,
        Expanded(
          child: AppText(
            text: value,
            style: textStyle14Regular.copyWith(
              fontSize: 15.sp,
              color: AppColors.primaryColor.setOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }
}
