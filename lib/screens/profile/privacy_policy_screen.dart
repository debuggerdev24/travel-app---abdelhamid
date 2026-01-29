import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Widget sectionTitle(String title) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(vertical: 12.h),
      child: AppText(
        text: title,
        style: textStyle16SemiBold.copyWith(
          fontSize: 16.sp,
          color: AppColors.primaryColor.setOpacity(0.8),
        ),
      ),
    );
  }

  Widget bullet(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 3.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "•  ",
            style: textStyle14Regular.copyWith(
              color: AppColors.textcolor.setOpacity(0.6),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: textStyle14Regular.copyWith(
                color: AppColors.primaryColor.setOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 27.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              20.h.verticalSpace,
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: SvgIcon(AppAssets.backIcon, size: 28.w),
                    ),
                  ),
                  AppText(
                    text: "Privacy Policy",
                    style: textStyle16SemiBold.copyWith(
                      fontSize: 26.sp,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),

              /// ---------------- Introduction ----------------
              sectionTitle("Introduction"),

              bullet("Full Name: Ahmed Khan"),
              bullet("Email Address: Ahmed.khan@temheed.com"),
              bullet("Phone Number: +34 945 678 1230"),
              bullet(
                "Passport & Visa Details for travel documentation and trip processing.",
              ),
              bullet(
                "Flights & Hotel Bookings to show your complete itinerary and confirmations.",
              ),
              bullet(
                "Uploaded Travel Documents (E.g. flight tickets, hotel vouchers, insurance PDFs).",
              ),
              bullet(
                "Optional Preferences (Luggage, meal choice, or special assistance requests).",
              ),

              /// ---------------- How We Use Your Information ----------------
              sectionTitle("How We Use Your Information"),

              bullet(
                "We use your data only to make your trip effortless and safe.",
              ),
              bullet("To confirm and manage your bookings."),
              bullet(
                "To show your trip details (flights, hotels, itinerary, documents).",
              ),
              bullet("To send you important notifications and updates."),
              bullet("To provide customer support during your journey."),
              bullet(
                "To ensure legal compliance for visas and travel regulations.",
              ),

              /// ---------------- Data Protection ----------------
              sectionTitle("Data Protection & Security"),

              bullet(
                "Your safety comes first.  We use encryption and secure servers to protect your documents and data.  Only authorized travel staff can access your information when required.  Your data is automatically removed after your trip is completed.",
              ),

              /// ---------------- Sharing Information ----------------
              sectionTitle("Sharing of Information"),

              bullet("We only share necessary information only with:"),
              bullet(
                "- Airline and hotel providers (for booking confirmation)",
              ),
              bullet("- Visa or insurance providers (for documentation)"),
              bullet("- Authorized guides or group leaders (for coordination)"),
              bullet("We never sell your personal data to anyone."),

              /// ---------------- Rights & Choices ----------------
              sectionTitle("Your Rights & Choices"),

              bullet("You are always in control of your data."),
              bullet("View or update your personal information anytime."),
              bullet("Request removal of your data after your trip."),
              bullet("Choose to opt out of marketing notifications."),
              bullet("For any privacy-related issues, simply email us."),

              /// ---------------- Contact Us ----------------
              sectionTitle("Contact Us"),

              bullet(
                "If you have any questions about your data or this Privacy Policy, reach out to us:",
              ),
              Padding(
                padding: EdgeInsets.only(left: 12.w),
                child: AppText(
                  text: "Email: info@example.com",
                  style: textStyle16SemiBold.copyWith(
                    fontSize: 14.sp,
                    color: AppColors.blueColor,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 12.w),
                child: AppText(
                  text: "Website: www.example.com",
                  style: textStyle16SemiBold.copyWith(
                    fontSize: 14.sp,
                    color: AppColors.blueColor,
                  ),
                ),
              ),

              sectionTitle("Thank You for Trusting Us"),
              bullet(
                "Your journey is sacred to us — and so is your privacy.  We’re here to ensure that your travel experience remains peaceful, secure, and worry-free.",
              ),

              40.h.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}
