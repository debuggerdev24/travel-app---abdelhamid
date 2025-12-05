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
import 'package:trael_app_abdelhamid/routes/user_routes.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
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
                    onTap: (){
                      context.pop();
                    },
                    child: SvgIcon(AppAssets.backIcon,size: 28.5.w,))),
                11.h.verticalSpace,
                Align(
                  child: RichText(
                    text: TextSpan(
                      text: "Forgot ",
                      style: textStyle32Bold.copyWith(color: AppColors.secondary),
                      children: [
                        TextSpan(
                          text: "Password ? ",
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
                  text:
                      "We'll send you instructions to reset your code.",
                  style: textStyle14Italic,
                ),
                36.h.verticalSpace,
                AppTextField(hintText: "Email Address / Phone"),
              
                
                60.h.verticalSpace,
                AppButton(title: "Get OTP", onTap: () {
                  context.pushNamed(UserAppRoutes.verifyOtpScreen.name);
                },),
           
          
              ],
            ),
          ),
        ),
      ),
    );
  }
}
