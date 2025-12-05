import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_button.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/provider/home/home_provider.dart';
import 'package:trael_app_abdelhamid/routes/user_routes.dart';

class PackageSummaryScreen extends StatefulWidget {
  const PackageSummaryScreen({super.key});

  @override
  State<PackageSummaryScreen> createState() => _PackageSummaryScreenState();
}

class _PackageSummaryScreenState extends State<PackageSummaryScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TripProvider>();
    final trip = provider.selectedTrip;
    final selectedPackage = provider.selectedPackage;

    if (trip == null) {
      return const Scaffold(body: Center(child: Text("No Trip Selected")));
    }

    return Scaffold(
      backgroundColor: AppColors.whiteColor,



      body: SafeArea(
        child: Column(
          children: [
            /// ---------------- HEADER ----------------
            40.h.verticalSpace,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w,  ),
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
                    text: "Umrah Trip 2025",
                    style: textStyle32Bold.copyWith(
                      fontSize: 26.sp,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),

            /// Travel details
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 32.h),
              child: Row(
                children: [
                  SvgIcon(AppAssets.pin, size: 20.w),
                  10.w.horizontalSpace,
                  Expanded(
                    child: AppText(
                      text: trip.location,
                      style: textStyle14Regular.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  SvgIcon(AppAssets.calendar, size: 20.w),
                  10.w.horizontalSpace,
                  AppText(
                    text: trip.date,
                    style: textStyle14Regular.copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            /// ------------- MAIN CONTENT LIST ---------------
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    10.h.verticalSpace,

                    /// Selected Package Card
                    if (selectedPackage != null)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.blueColor),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              blurRadius: 3,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              text: selectedPackage.title,
                              style: textStyle16SemiBold.copyWith(
                                color: AppColors.secondary,
                                fontSize: 17.sp,
                              ),
                            ),

                            _buildSection(
                              title: 'Room Options :',
                              items: selectedPackage.roomOptions,
                            ),
                            _buildSection(
                              title: 'Child Prices :',
                              items: selectedPackage.childPrices,
                            ),
                            _buildSection(
                              title: 'Inclusions :',
                              items: selectedPackage.inclusions,
                            ),
                            _buildSection(
                              title: 'Exclusions :',
                              items: selectedPackage.exclusions,
                            ),
                          ],
                        ),
                      ),

                    20.h.verticalSpace,

                    /// Example Price Rows
                    _priceRow("2 Person (Adult)", "€7,000"),
                    _priceRow("2 Child", "€2500"),
                    _priceRow("1 Baby", "€500"),

                    Divider(height: 30.h,color: AppColors.primaryColor.withOpacity(0.2),endIndent: 60,),
                    _priceRow("TOTAL COST", "€10,000"),
                    52.h.verticalSpace,
                    AppButton(
                      onTap: (){
                        context.pushNamed(UserAppRoutes.paymentOptionScreen.name);
                      },
                      title: "Book Now",
                    ),
                    46.h.verticalSpace,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build Section (Room Options / Inclusions etc.)
  Widget _buildSection({required String title, required List<String> items}) {
    return Padding(
      padding: EdgeInsets.only(top: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: title,
            style: textStyle14Medium.copyWith(fontWeight: FontWeight.w600),
          ),
          8.h.verticalSpace,
          ...items.map(
            (e) => Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 4.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  12.w.horizontalSpace,
                  Expanded(
                    child: AppText(
                      text: e,
                      style: textStyle14Regular.copyWith(
                        color: AppColors.primaryColor.withOpacity(0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Price row
  Widget _priceRow(String title, String value) {
    return Padding(
    padding: EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        SizedBox(
          width: 140.w, // FIXED WIDTH FOR ALIGNMENT
          child: AppText(
            text: title,
            style: textStyle14Medium.copyWith(
              color: AppColors.primaryColor.withOpacity(0.6),
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        AppText(
          text: ":",
          style: textStyle14Medium.copyWith(
            color: AppColors.primaryColor.withOpacity(0.6),
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),

30.w.horizontalSpace,        // VALUE
        AppText(
          text: value,
          style: textStyle14Medium.copyWith(
            color: AppColors.primaryColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
  }
}
