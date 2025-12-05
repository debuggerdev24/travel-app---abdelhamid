import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_button.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';

class HotelVoucherScreen extends StatelessWidget {
  final String? imageFile;
  final String hotelName;
  final String address;

  const HotelVoucherScreen({
    super.key,
    this.imageFile,
    required this.hotelName,
    required this.address,
  });

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
              // Header
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
                      text: "Hotel Voucher",
                      style: textStyle32Bold.copyWith(
                        fontSize: 26.sp,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Hotel Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.asset(
                  imageFile ?? AppAssets.hotelvoucher,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              10.h.verticalSpace,

              // Hotel Name + Map Icon
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Row(
                  children: [
                    AppText(
                      text: hotelName,
                      style: textStyle18Bold.copyWith(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    Spacer(),
                    SvgIcon(
                      AppAssets.map,
                      color: AppColors.secondary,
                      size: 24.w,
                    ),
                  ],
                ),
              ),

              8.h.verticalSpace,

              // Address Row
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: Row(
                  children: [
                    SvgIcon(AppAssets.address, size: 20.w),
                    5.w.horizontalSpace,
                    AppText(
                      text: address,
                      style: textStyle14Regular.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              20.h.verticalSpace,

              // Static Inputs
              _inputBox("Guest Name", "Ali Mohammed"),
              _inputBox("Booking Ref", "45239-UMR-2025"),
              _inputBox("Room Type", "Double Deluxe (302)"),
              _inputBox("Occupancy", "2 Adults"),
              _stayInfo(),
              _inputBox("Hotel Contact", "+966 12 377 8900"),
              _inputBox("Hotel Email", "reservations@swissotel.com"),

              Text(
                "Facilities",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              14.h.verticalSpace,

              _facilityItem("Free WiFi", AppAssets.wifi),
              _facilityItem("Breakfast Included", AppAssets.breakfast),
              _facilityItem("Dinner", AppAssets.kitchen),

              40.h.verticalSpace,
            ],
          ),
        ),
      ),

      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 27.w, vertical: 30.h),
        child: SizedBox(
          height: 50.h,
          width: double.infinity,
          child: AppButton(title: "Download"),
        ),
      ),
    );
  }

  // Reusable Input Box Style
  Widget _inputBox(String title, String value) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.blueColor.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: title,
            style: textStyle14Regular.copyWith(
              fontSize: 12.sp,
              color: AppColors.primaryColor.withOpacity(0.8),
            ),
          ),
          8.h.verticalSpace,
          AppText(
            text: value,
            style: textStyle14Regular.copyWith(color: AppColors.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _stayInfo() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.blueColor.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: "Stay Info",
            style: textStyle14Regular.copyWith(
              fontSize: 12.sp,
              color: AppColors.primaryColor.withOpacity(0.8),
            ),
          ),
          8.h.verticalSpace,
          _buildInfoRow("Check-In", "10 Feb 2025, 2:00 PM"),
          SizedBox(height: 10.h),
          _buildInfoRow("Check-Out", "15 Feb 2025, 11:00 AM"),
          SizedBox(height: 10.h),
          _buildInfoRow("Nights", "05"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70.w,
            child: AppText(
              text: "$label",
              style: textStyle14Regular.copyWith(color: AppColors.primaryColor),
            ),
          ),
          AppText(
            text: " :  ",
            style: textStyle14Regular.copyWith(color: AppColors.primaryColor),
          ),
          Expanded(
            child: AppText(
              text: value,
              style: textStyle14Regular.copyWith(color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _facilityItem(String title, String icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 18.h),
      child: Row(
        children: [
          SvgIcon(
            icon,
            size: 20.sp,
            color: AppColors.primaryColor.withOpacity(0.8),
          ),
          8.w.horizontalSpace,
          AppText(
            text: title,
            style: textStyle14Regular.copyWith(
              fontSize: 14.sp,
              color: AppColors.primaryColor.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
