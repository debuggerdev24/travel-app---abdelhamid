import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/provider/trip/my_trip_provider.dart';
import 'package:trael_app_abdelhamid/routes/user_routes.dart';
import 'package:go_router/go_router.dart';

class ViewReceiptScreen extends StatefulWidget {
  const ViewReceiptScreen({super.key});

  @override
  State<ViewReceiptScreen> createState() => _ViewReceiptScreenState();
}

class _ViewReceiptScreenState extends State<ViewReceiptScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      bottomNavigationBar: SafeArea(
        child: GestureDetector(
          onTap: () {
            Provider.of<MyTripProvider>(
              context,
              listen: false,
            ).setHidePaymentMethods(true);

            context.pushNamed(UserAppRoutes.tabScreen.name, extra: 1);
          },
          child: Container(
            height: 50.h,
            margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.blueColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            alignment: Alignment.center,
            child: AppText(
              text: "Download PDF",
              style: textStyle16SemiBold.copyWith(color: AppColors.whiteColor),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: SvgIcon(AppAssets.backIcon, size: 26.w),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Center(
                      child: AppText(
                        text: "Payment Receipt",
                        style: textStyle32Bold.copyWith(
                          fontSize: 24.sp,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ),
                  26.w.horizontalSpace,
                ],
              ),
              4.h.verticalSpace,
              AppText(
                text: "Company Pvt. Ltd.",
                style: textStyle16SemiBold.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
              SizedBox(height: 20.h),
              _section("Invoice & Transaction", [
                _info("Invoice No.", "INV-20240715-001"),
                _info("Date", "July 15, 2024"),
                _info(
                  "Payment Status",
                  "Successful",
                  color: AppColors.blueColor,
                ),
                _info("Amount Paid", "\$1,250.00"),
                _info("Transaction ID", "TXN-20240715-001"),
                _info("Method", "Credit Card"),
                _info("Date & Time", "July 15, 2024, 10:30 AM"),
              ]),
              SizedBox(height: 20.h),
              _section("Customer Info", [
                _info("Name", "Aaliyah Khan"),
                _info("Email", "aaliyah@email.com"),
                _info("Phone", "+91 98765 43210"),
              ]),
              SizedBox(height: 20.h),
              _section("Booking Details", [
                _info("Booking Ref", "BK-20240715-001"),
                _info("Package", "Luxury Maldives Getaway"),
                _info("Travel Dates", "Aug 15 - 22, 2024"),
                _info("Passengers", "2 Adults, 1 Child"),
              ]),
              SizedBox(height: 30.h),
              AppText(
                text: "\"Thank you for booking with us.\"",
                style: textStyle14Regular.copyWith(
                  color: AppColors.primaryColor.withOpacity(.5),
                ),
              ),
              SizedBox(height: 4.h),
              AppText(
                text: "Support: +91 XXXXX XXXXX",
                style: textStyle14Regular.copyWith(
                  color: AppColors.primaryColor.withOpacity(.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: title,
          style: textStyle16SemiBold.copyWith(color: AppColors.primaryColor),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          margin: EdgeInsets.only(top: 10.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
          ),
          child: Column(
            children: List.generate(
              rows.length,
              (i) => Column(
                children: [
                  rows[i],
                  if (i != rows.length - 1)
                    Divider(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      height: 10.h,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _info(String title, String value, {Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Expanded(
            child: AppText(
              text: title,
              style: textStyle14Medium.copyWith(
                color: AppColors.primaryColor.withOpacity(0.6),
              ),
            ),
          ),
          AppText(
            text: value,
            style: textStyle14Regular.copyWith(
              color: color ?? AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
