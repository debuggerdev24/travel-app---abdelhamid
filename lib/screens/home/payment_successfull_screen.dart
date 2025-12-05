import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_button.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/routes/user_routes.dart';

class PaymentSuccessfullScreen extends StatelessWidget {
  const PaymentSuccessfullScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding:EdgeInsetsGeometry.symmetric(horizontal: 27.w),
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
                Image.asset(AppAssets.paymentsuccessfull),
                52.h.verticalSpace,
                AppText(text: "We’ve received your payment of €5,000",style: textStyle14Regular.copyWith(color: AppColors.primaryColor,fontSize: 18.sp,),textAlign: TextAlign.center,),
                14.h.verticalSpace,
                              AppText(text: "Thank you for booking with us! Your trip is now confirmed – happy travels ahead!",style: textStyle14Regular.copyWith(color: AppColors.primaryColor.withOpacity(0.6),fontSize: 16.sp),textAlign: TextAlign.center,),
                              Spacer(),
                              AppButton(title:"Back to My Trip",
                              onTap: (){
                                context.pushNamed(UserAppRoutes.paymentFailedScreen.name);
                              },
                              ),
                              42.h.verticalSpace,
            
              ],
            ),
          ),
        ),
      ),
    );
  }
}