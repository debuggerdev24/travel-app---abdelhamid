import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';

class OurLocationsScreen extends StatelessWidget {
  const OurLocationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 27.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),

                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: SvgIcon(AppAssets.backIcon, size: 26.w),
                      ),
                    ),
                    AppText(
                      text: "Our Locations",
                      style: textStyle32Bold.copyWith(
                        fontSize: 26.sp,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              _sectionTitle("The Netherlands :"),
              _locationCard([
                "Edisonplein 7, 4816 AM, Breda",
                "Jan Rebelstraat 18b, 1069 CC, Amsterdam",
                "Van Bijinkershoeklaan 405, 3527 XK, Utrecht",
                "Rijksweg Zuid 80a, 6161 BP, Geleen",
              ]),

              12.h.verticalSpace,
              _sectionTitle("Belgium :"),
              _locationCard([
                "Sint-Bernardsesteenweg 273B, 2660, Hoboken - Antwerp",
                "Rue d'Ostende 124, 1080, Sint-Jans-Molenbeek, Brussels",
              ]),

              12.h.verticalSpace,
              _sectionTitle("Morocco :"),
              _locationCard(["84 Ave Mohammed V, Tangier 90000, Marokko"]),
              12.h.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 10.h, bottom: 8.w),
      child: AppText(
        text: title,
        style: textStyle16SemiBold.copyWith(color: AppColors.primaryColor),
      ),
    );
  }

  Widget _locationCard(List<String> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: BoxBorder.all(
          color: AppColors.primaryColor.setOpacity(0.2),
          width: 0,
        ),
        borderRadius: BorderRadius.circular(12.r),

        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.setOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items
              .map(
                (text) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: "•  ",
                        style: textStyle12Regular.copyWith(
                          fontSize: 16.sp,
                          color: AppColors.primaryColor.setOpacity(0.8),
                        ),
                      ),
                      Expanded(
                        child: AppText(
                          text: text,
                          style: textStyle12Regular.copyWith(
                            fontSize: 16.sp,
                            color: AppColors.primaryColor.setOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
