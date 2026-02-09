import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/utils/validators.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_button.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text_filed.dart';
import 'package:trael_app_abdelhamid/core/widgets/toast_service.dart';
import 'package:trael_app_abdelhamid/features/auth/provider/auth_provider.dart';
import 'package:trael_app_abdelhamid/routes/user_routes.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    _formKey.currentState?.reset();
    super.dispose();
  }

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
                      text: "Forgot ",
                      style: textStyle32Bold.copyWith(
                        color: AppColors.secondary,
                      ),
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
                  text: "We'll send you instructions to reset your code.",
                  style: textStyle14Italic,
                ),
                36.h.verticalSpace,
                Form(
                  key: _formKey,
                  child: AppTextField(
                    hintText: "Email Address",
                    controller: emailController,
                    validator: Validator.validateEmail,
                  ),
                ),

                60.h.verticalSpace,
                Selector<AuthProvider, bool>(
                  selector: (context, provider) => provider.isLoading,
                  builder: (context, isLoading, child) {
                    if (isLoading) return const CircularProgressIndicator();
                    return AppButton(
                      title: "Get OTP",
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          bool result = await context
                              .read<AuthProvider>()
                              .forgetPassword(
                                emnail: emailController.text.trim(),
                                onError: (error) {
                                  ToastService.showError(error);
                                },
                              );
                          if (result) {
                            ToastService.showSuccess(
                              "OTP sent successfully to your email",
                            );
                            context.pushNamed(
                              UserAppRoutes.verifyOtpScreen.name,
                              queryParameters: {
                                'email': emailController.text.trim(),
                              },
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
