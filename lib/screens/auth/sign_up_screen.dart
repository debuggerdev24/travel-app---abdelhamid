import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_button.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text_filed.dart';
import 'package:trael_app_abdelhamid/routes/go_routes.dart';
import 'package:trael_app_abdelhamid/routes/user_routes.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
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
                    text: "Create An",
                    style: textStyle32Bold.copyWith(color: AppColors.primaryColor),
                    children: [
                      TextSpan(
                        text: " Account",
                        style: textStyle32Bold.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                6.h.verticalSpace,
                AppText(
                    textAlign: TextAlign.center,
                  text:
                      "“Start your journey with us – create your account today!”",
                  style: textStyle14Italic,
                ),
                36.h.verticalSpace,
                Column(
                  spacing: 22.h,
                  children: [
                    AppTextField(hintText: "Email Address"),
                    AppTextField(hintText: "Phone Number"),
                    AppTextField(hintText: "Password"),
                  ],
                ),
                66.h.verticalSpace,
                AppButton(
                  title: "Sign Up",
                  onTap: () {
                    context.pushNamed(UserAppRoutes.signInScreen.name);
                  },
                ),
                10.h.verticalSpace,
                RichText(
                  text: TextSpan(
                    text: "Already have an account? ",
                    style: textStyle14Regular.copyWith(letterSpacing: 0.4),
                    children: [
                     TextSpan(
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            context.pushNamed(UserAppRoutes.signInScreen.name);
          },
                        text: "Sign In",
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
