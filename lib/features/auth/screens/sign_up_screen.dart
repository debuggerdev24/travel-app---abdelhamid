import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:travel_app_abdelhamid/features/auth/screens/sign_in_screen.dart';
import 'package:travel_app_abdelhamid/routes/user_routes.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_button.dart';
import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/widgets/toast_service.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text_filed.dart';
import 'package:travel_app_abdelhamid/features/auth/provider/auth_provider.dart';

final TextEditingController signUpEmailController = TextEditingController();
final TextEditingController signUpPhoneController = TextEditingController();
final TextEditingController signUpPasswordController = TextEditingController();

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    signUpEmailController.dispose();
    signUpPhoneController.dispose();
    signUpPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 50.h, horizontal: 13.5.w),
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgIcon(AppAssets.homeIcon, size: 130.w),
                    11.h.verticalSpace,
                    RichText(
                      text: TextSpan(
                        text: "Create An".tr(),
                        style: textStyle32Bold.copyWith(
                          color: AppColors.secondary,
                        ),
                        children: [
                          TextSpan(
                            text: " Account".tr(),
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
                          "“Start your journey with us – create your account today!”"
                              .tr(),
                      style: textStyle14Italic,
                    ),
                    36.h.verticalSpace,
                    Form(
                      key: _formKey,
                      child: Column(
                        spacing: 22.h,
                        children: [
                          AppTextField(
                            controller: signUpEmailController,
                            hintText: "Email Address".tr(),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Email is required";
                              }
                              if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                return "Invalid email format";
                              }
                              return null;
                            },
                          ),
                          AppTextField(
                            controller: signUpPhoneController,
                            hintText: "Phone Number".tr(),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Phone number is required";
                              }
                              if (value.length < 10) {
                                return "Phone number is too short";
                              }
                              return null;
                            },
                          ),
                          AppTextField(
                            controller: signUpPasswordController,
                            hintText: "Password".tr(),
                            obSecureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Password is required";
                              }
                              if (value.length < 6) {
                                return "Password must be at least 6 characters";
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    66.h.verticalSpace,
                    AppButton(
                      title: "Sign Up".tr(),
                      isLoading: authProvider.isLoading,
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          final success = await authProvider.register(
                            email: signUpEmailController.text.trim(),
                            phoneNumber: signUpPhoneController.text.trim(),
                            password: signUpPasswordController.text.trim(),
                            onError: (error) {
                              ToastService.showError(error);
                            },
                          );

                          if (success && context.mounted) {
                            ToastService.showSuccess(
                              "We have sent you an email with the traveller code",
                            );
                            context.pushNamed(UserAppRoutes.signInScreen.name);
                          }
                        }
                      },
                    ),
                    10.h.verticalSpace,
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Already have an account? ".tr(),
                            style: textStyle14Regular.copyWith(
                              letterSpacing: 0.4,
                              color: Colors.black.withValues(alpha: 0.7),
                            ),
                          ),
                          TextSpan(
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                context.pushReplacementNamed(
                                  UserAppRoutes.signInScreen.name,
                                );
                              },
                            text: "Sign In".tr(),
                            style: textStyle18Bold.copyWith(
                              fontSize: 14.sp,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
