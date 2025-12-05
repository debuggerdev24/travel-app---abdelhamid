import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/model/home/trip_model.dart';

class DocumentCard extends StatelessWidget {
  final DocumentModel doc;
  final VoidCallback ontap;

  const DocumentCard({
    super.key,
    required this.doc, required this.ontap,
  });

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70.w,
            child: AppText(
              text: "$label",
              style: textStyle14Regular.copyWith(
                color: AppColors.primaryColor.withOpacity(0.8),
                fontSize: 13.sp,
              ),
            ),
          ),
          AppText(
            text: " :  ",
            style: textStyle14Regular.copyWith(
              color: AppColors.primaryColor.withOpacity(0.8),
            ),
          ),
          Expanded(
            child: AppText(
              text: value,
              style: textStyle14Regular.copyWith(
                color: AppColors.primaryColor.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: doc.fileImage != null
                    ? Image.file(
                        doc.fileImage!,
                        width: 140.w,
                        height: 126.h,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        doc.image,
                        width: 140.w,
                        height: 126.h,
                        fit: BoxFit.cover,
                      ),
              ),

14.w.horizontalSpace,
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (doc.subtitle != null) ...[
                      AppText(
                        text: doc.subtitle!,
                        style: textStyle14Medium.copyWith(
                          fontSize: 12.sp,
                          color: AppColors.secondary,
                        ),
                      ),
4.h.verticalSpace,                    ],

                    AppText(
                      text: doc.title,
                      style: textStyle16SemiBold.copyWith(fontSize: 16.sp),
                    ),

8.h.verticalSpace,                    if (doc.info != null)
                      ...doc.info!.entries.map((entry) =>
                          _buildInfoRow(entry.key, entry.value),
                      ).toList(),
                  ],
                ),
              ),
            ],
          ),
          16.h.verticalSpace,
          
            Row(
            children: [
              Expanded(
                child: GestureDetector(
                   onTap: ontap,
                  child: Container(
                    height: 46.h,
                    decoration: BoxDecoration(
                       boxShadow: [
                      BoxShadow(
                        color: AppColors.blueColor.withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 5),
                      ),
                    ],
                      color: AppColors.blueColor,
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.remove_red_eye_outlined,
                              color: Colors.white, size: 18),
                          12.w.horizontalSpace,
                          AppText(
                            text: doc.button1,
                            style: textStyle14Medium.copyWith(
                              color: Colors.white,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              20.w.horizontalSpace,

              Expanded(
                child: GestureDetector(
                 onTap: ontap,
                  child: Container(
                    height: 46.h,
                    decoration: BoxDecoration(
                       boxShadow: [
                      BoxShadow(
                        color: AppColors.blueColor.withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                      color: Colors.white,
                      border: Border.all(
                        color: AppColors.blueColor,
                        width: 0.8,
                      ),
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgIcon(doc.icon, size: 20.w),
                          12.w.horizontalSpace,
                          AppText(
                            text: doc.button2,
                            style: textStyle14Medium.copyWith(
                              color: AppColors.blueColor,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}