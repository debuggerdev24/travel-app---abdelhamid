import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:trael_app_abdelhamid/model/home/trip_model.dart';

class PackageDetailsCard extends StatelessWidget {
  final PackageDetails package;
  final bool isSelected;
  final VoidCallback onTap;

  const PackageDetailsCard({
    super.key,
    required this.package,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.secondary
                : AppColors.primaryColor.setOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.blueColor.setOpacity(0.1),
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  AppText(
                    text: package.title,
                    style: textStyle16SemiBold.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),

              if (package.roomOptions.isNotEmpty)
                _buildSection(
                  title: 'Room Options :',
                  items: package.roomOptions,
                ),

              if (package.childPrices.isNotEmpty)
                _buildSection(
                  title: 'Child Prices :',
                  items: package.childPrices,
                ),

              if (package.inclusions.isNotEmpty)
                _buildSection(title: 'Inclusions :', items: package.inclusions),

              if (package.exclusions.isNotEmpty)
                _buildSection(
                  title: 'Exclusions:',
                  items: package.exclusions,
                  isLast: true,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<String> items,
    bool isLast = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        8.h.verticalSpace,
        Row(
          children: [
            8.h.verticalSpace,
            AppText(
              text: title,
              style: textStyle14Medium.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        10.h.verticalSpace,
        ...items.map(
          (item) => Padding(
            padding: EdgeInsets.only(bottom: 5.h, left: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 4.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.setOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                ),
                12.w.horizontalSpace,
                Expanded(
                  child: AppText(
                    text: item,
                    style: textStyle14Regular.copyWith(
                      fontSize: 14,
                      color: AppColors.primaryColor.setOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        8.h.verticalSpace,
      ],
    );
  }
}
