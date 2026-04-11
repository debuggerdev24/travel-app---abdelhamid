import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_button.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:trael_app_abdelhamid/routes/user_routes.dart';

/// Passed as [GoRouterState.extra] when opening [PaymentSuccessfullScreen].
class PaymentSuccessRouteExtra {
  const PaymentSuccessRouteExtra({required this.amountEur});

  final double amountEur;
}

class PaymentSuccessfullScreen extends StatelessWidget {
  const PaymentSuccessfullScreen({super.key, this.amountEur});

  /// Amount received (e.g. from Stripe / booking). Null → generic copy.
  final double? amountEur;

  @override
  Widget build(BuildContext context) {
    final amountLine = amountEur != null
        ? "We've received your payment of €${amountEur!.toStringAsFixed(2)}"
        : "We've received your payment.";

    return PopScope(
      canPop: true,
      child: Scaffold(
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
                  text: "Payment Successful!",
                  style: textStyle32Bold.copyWith(
                    fontSize: 26.sp,
                    color: AppColors.secondary,
                  ),
                ),
                42.h.verticalSpace,
                Image.asset(AppAssets.paymentSuccessful),
                52.h.verticalSpace,
                AppText(
                  text: amountLine,
                  style: textStyle14Regular.copyWith(
                    color: AppColors.primaryColor,
                    fontSize: 18.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                14.h.verticalSpace,
                AppText(
                  text:
                      "Thank you for booking with us! Your trip is now confirmed – happy travels ahead!",
                  style: textStyle14Regular.copyWith(
                    color: AppColors.primaryColor.setOpacity(0.6),
                    fontSize: 16.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                Spacer(),
                AppButton(
                  title: "Back to My Trip",
                  onTap: () {
                    // Pop first so callers awaiting [pushNamed] to this screen complete,
                    // then replace stack to the Trips tab.
                    if (context.canPop()) {
                      context.pop(true);
                    }
                    context.goNamed(
                      UserAppRoutes.tabScreen.name,
                      queryParameters: const {'tab': '1'},
                    );
                  },
                ),
                42.h.verticalSpace,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
