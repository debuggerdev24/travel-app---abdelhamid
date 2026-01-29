import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_button.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/routes/user_routes.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';


class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 27.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                40.h.verticalSpace,
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                      context.pop();
                    },
                    child: SvgIcon(AppAssets.backIcon, size: 28.5.w),
                  ),
                ),
                11.h.verticalSpace,
                Align(
                  child: RichText(
                    text: TextSpan(
                      text: "Verify",
                      style: textStyle32Bold.copyWith(
                        color: AppColors.secondary,
                      ),
                      children: [
                        TextSpan(
                          text: " Your Account",
                          style: textStyle32Bold.copyWith(
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                6.h.verticalSpace,
                AppText(
                  textAlign: TextAlign.center,
                  text: "Enter the 4-digit code we sent to your \n phone/email",
                  style: textStyle14Italic,
                ),
                40.h.verticalSpace,
                Pinput(
                  length: 4,
                  separatorBuilder: (index) => 12.w.horizontalSpace,
                  defaultPinTheme: PinTheme(
                    height: 55.h,
                    width: 57.w,
                    textStyle: textStyle14Regular,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(08.r),
                      border: Border.all(
                        color: AppColors.primaryColor.setOpacity(0.2),
                      ),
                    ),
                  ),
                  focusedPinTheme: PinTheme(
                    height: 56.h,
                    width: 57.w,
                    textStyle: textStyle14Regular.copyWith(
                      color: AppColors.black,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r), // Less Radius
                      border: Border.all(
                        color: AppColors.primaryColor.setOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  submittedPinTheme: PinTheme(
                    height: 56.h,
                    width: 57.w,
                    textStyle: textStyle14Regular.copyWith(
                      color: AppColors.primaryColor,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: AppColors.primaryColor.setOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onCompleted: (code) {},
                ),

                40.h.verticalSpace,
                AppButton(
                  title: "Verify",
                  onTap: () {
                    context.pushNamed(UserAppRoutes.tabScreen.name);
                  },
                ),
                10.h.verticalSpace,
                RichText(
                  text: TextSpan(
                    text: "Didn't receive the code? ",
                    style: textStyle14Regular.copyWith(letterSpacing: 0.4),
                    children: [
                      TextSpan(
                        text: "Resend OTP",
                        style: textStyle18Bold.copyWith(
                          fontSize: 14.sp,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                59.h.verticalSpace,

                AppText(
                  textAlign: TextAlign.center,
                  text: "Change phone/email",
                  style: textStyle14Regular.copyWith(
                    color: AppColors.secondary,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.secondary,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
