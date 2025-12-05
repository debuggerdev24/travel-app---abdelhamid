import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/provider/trip/my_trip_provider.dart';

class PackageListScreen extends StatelessWidget {
  const PackageListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MyTripProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 31.w, vertical: 27.h),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: SvgIcon(AppAssets.backIcon, size: 28.5.w),
                    ),
                  ),
                  AppText(
                    text: "Packing List",
                    style: textStyle32Bold.copyWith(
                      fontSize: 26.sp,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),

            /// List
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 27.w),
                children: provider.packingData.entries.map((e) {
                  return buildCategory(
                    context,
                    title: e.key,
                    items: e.value,
                    checked: provider.categoryChecked[e.key] ?? false,
                    onTapCheck: () => provider.toggleCategory(e.key),
                  );
                }).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildCategory(
    BuildContext context, {
    required String title,
    required List<String> items,
    required bool checked,
    required VoidCallback onTapCheck,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                text: title,
                style: textStyle16SemiBold.copyWith(
                  color: AppColors.primaryColor.withOpacity(0.8),
                  fontSize: 18.sp,
                ),
              ),

              GestureDetector(
                onTap: onTapCheck,
                child: SvgIcon(
                  checked ? AppAssets.checkbox : AppAssets.checkfill,
                  size: 24.w,
                ),
              ),
            ],
          ),

          14.h.verticalSpace,

          /// Bullet Items
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.map((item) {
              return Padding(
                padding: EdgeInsets.only(bottom: 6.h, left: 12.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: "•  ",
                      style: textStyle14Regular.copyWith(
                        fontSize: 16.sp,
                        color: AppColors.primaryColor.withOpacity(0.6),
                      ),
                    ),
                    Expanded(
                      child: AppText(
                        text: item,
                        style: textStyle14Regular.copyWith(
                          fontSize: 16.sp,
                          color: AppColors.primaryColor.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

