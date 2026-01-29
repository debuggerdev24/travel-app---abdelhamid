import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_button.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text_filed.dart';
import 'package:trael_app_abdelhamid/routes/user_routes.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 50.h, horizontal: 27.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgIcon(AppAssets.homeIcon, size: 130.w),
                11.h.verticalSpace,
                RichText(
                  text: TextSpan(
                    text: "Welcome ",
                    style: textStyle32Bold.copyWith(color: AppColors.secondary),
                    children: [
                      TextSpan(
                        text: "Back!",
                        style: textStyle32Bold.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                6.h.verticalSpace,
                AppText(
                  textAlign: TextAlign.center,
                  text:
                      "“Access your trips, bookings, and adventures in one place.”",
                  style: textStyle14Italic,
                ),
                36.h.verticalSpace,
                Column(
                  spacing: 22.h,
                  children: [
                    AppTextField(hintText: "Enter Your Personal Code"),
                    AppTextField(hintText: "Email Address / Phone"),
                    AppTextField(hintText: "Password"),
                  ],
                ),
                8.h.verticalSpace,
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      context.pushNamed(
                        UserAppRoutes.forgotPasswordScreen.name,
                      );
                    },
                    child: AppText(
                      text: "Forgot Password ?",
                      style: textStyle14Regular.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ),
                60.h.verticalSpace,
                AppButton(
                  title: "Sign Up",
                  onTap: () {
                    context.pushReplacementNamed(UserAppRoutes.tabScreen.name);
                  },
                ),
                10.h.verticalSpace,
                RichText(
                  text: TextSpan(
                    text: "Don’t have an account? ",
                    style: textStyle14Regular.copyWith(letterSpacing: 0.4),
                    children: [
                      TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            context.pushReplacementNamed(
                              UserAppRoutes.signUpScreen.name,
                            );
                          },
                        text: "Sign Up",
                        style: textStyle18Bold.copyWith(
                          fontSize: 14.sp,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
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
