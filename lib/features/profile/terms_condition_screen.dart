import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';

class TermsConditionScreen extends StatelessWidget {
  const TermsConditionScreen({super.key});

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
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "•  ",
            style: textStyle14Regular.copyWith(
              fontSize: 14.sp,
              color: AppColors.textcolor.setOpacity(0.6),
            ),
          ),
          Expanded(
            child: AppText(
              text: text,
              style: textStyle14Regular.copyWith(
                fontSize: 14.sp,
                color: AppColors.textcolor.setOpacity(0.6),
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
              21.h.verticalSpace,
              Stack(
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
                    text: "Terms & Conditions",
                    style: textStyle32Bold.copyWith(
                      fontSize: 26.sp,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              sectionTitle("Introduction"),
              AppText(
                text:
                    "Welcome to [Agency Name]. By booking or managing your trip through our platform, you agree to the following terms and conditions. Please read them carefully before proceeding.",
                style: textStyle14Regular.copyWith(
                  fontSize: 14.sp,
                  color: AppColors.textcolor.setOpacity(0.6),
                ),
              ),

              // ---------- SECTION: Definitions ----------
              sectionTitle("Definitions"),
              bullet("“Agency” refers to [Agency Name], the service provider."),
              bullet("“Traveller” means the person booking or joining a trip."),
              bullet(
                "“Service” includes booking, support, and travel assistance.",
              ),
              bullet(
                "“Platform” refers to the website or mobile application used for booking and management.”",
              ),

              // ---------- SECTION: Booking Policy ----------
              sectionTitle("Booking & Payment Policy"),
              bullet(
                "Full payment must be completed within 24 hours of booking.",
              ),
              bullet("Failure to pay may result in booking cancellation."),
              bullet(
                "All payments are non-refundable unless stated otherwise.",
              ),
              bullet("Prices may vary depending on availability and season."),

              // ---------- SECTION: Pricing ----------
              sectionTitle("Pricing & Packages"),
              AppText(
                text:
                    "All prices mentioned are inclusive of applicable taxes unless specified. The final amount will be displayed during checkout.",
                style: textStyle14Regular.copyWith(
                  fontSize: 13.sp,
                  height: 1.4,
                ),
              ),

              // ---------- SECTION: Cancellation ----------
              sectionTitle("Cancellation & Refund Policy"),
              bullet("Cancellations must be made through the app."),
              bullet("Refund eligibility depends on package terms."),
              bullet("Non-refundable bookings cannot be cancelled."),
              bullet("Refunds may take 5–7 business days to process."),

              // ---------- SECTION: Travel Documents ----------
              sectionTitle("Travel Documents"),
              bullet(
                "Travellers are responsible for ensuring valid passports, visas, and medical documents.  The agency may assist but is not liable for visa rejections or delays.",
              ),

              // ---------- SECTION: Liability ----------
              sectionTitle("Liability & Responsibilities"),
              bullet(
                "The agency acts as an intermediary and is not liable for delays, loss of property, or injuries during travel.",
              ),
              bullet(
                "Travellers must follow local laws and respect group schedules and tour guides.",
              ),

              // ---------- SECTION: Insurance ----------
              sectionTitle("Insurance"),
              bullet(
                "All travellers are strongly advised to obtain comprehensive travel insurance covering medical emergencies, cancellations, and personal belongings.",
              ),

              // ---------- SECTION: Data Privacy ----------
              sectionTitle("Data Privacy"),
              bullet(
                "Personal data collected (such as name, passport number, and contact details) will only be used for booking and visa purposes.",
              ),
              bullet(
                "The agency complies with GDPR and data protection regulations.",
              ),

              // ---------- SECTION: Changes ----------
              sectionTitle("Changes & Updates"),
              bullet(
                "The agency reserves the right to amend these Terms & Conditions at any time. Updated terms will be published on this page with the latest revision date.",
              ),

              // ---------- SECTION: Contact ----------
              sectionTitle("Contact Information"),
              bullet("For questions about these terms, please contact us at:"),

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

              40.h.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}
