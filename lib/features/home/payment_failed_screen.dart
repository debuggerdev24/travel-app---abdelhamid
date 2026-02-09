import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_button.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/routes/user_routes.dart';

class PaymentFailedScreen extends StatelessWidget {
  const PaymentFailedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 27.w),
            child: Column(
              children: [
                56.h.verticalSpace,
                AppText(
                  textAlign: TextAlign.center,
                  text: "Payment Failed",
                  style: textStyle32Bold.copyWith(
                    fontSize: 26.sp,
                    color: AppColors.secondary,
                  ),
                ),
                42.h.verticalSpace,
                Image.asset(AppAssets.paymentfailed),
                52.h.verticalSpace,
                AppText(
                  text:
                      "We couldn’t process your payment at the moment. Please try again or use another method.",
                  style: textStyle14Regular.copyWith(
                    color: AppColors.primaryColor,
                    fontSize: 18.sp,
                  ),
                  textAlign: TextAlign.center,
                ),

                Spacer(),
                AppButton(title: "Try Again", onTap: () {
                  context.pushNamed(UserAppRoutes.tabScreen.name
                  );
                }),
                42.h.verticalSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
