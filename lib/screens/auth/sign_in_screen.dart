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
import 'package:trael_app_abdelhamid/core/widgets/toast_service.dart';
import 'package:trael_app_abdelhamid/provider/auth/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:trael_app_abdelhamid/routes/user_routes.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController personalCodeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    personalCodeController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 50.h, horizontal: 27.w),
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgIcon(AppAssets.homeIcon, size: 130.w),
                    11.h.verticalSpace,
                    RichText(
                      text: TextSpan(
                        text: "Welcome ",
                        style: textStyle32Bold.copyWith(
                          color: AppColors.secondary,
                        ),
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
                    Form(
                      key: _formKey,
                      child: Column(
                        spacing: 22.h,
                        children: [
                          AppTextField(
                            controller: personalCodeController,
                            hintText: "Enter Your Personal Code",
                          ),
                          AppTextField(
                            controller: emailController,
                            hintText: "Email Address / Phone",
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Email or Phone is required";
                              }
                              return null;
                            },
                          ),
                          AppTextField(
                            controller: passwordController,
                            hintText: "Password",
                            obSecureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Password is required";
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
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
                    authProvider.isLoading
                        ? const CircularProgressIndicator()
                        : AppButton(
                            title: "Sign In",
                            onTap: () async {
                              if (_formKey.currentState!.validate()) {
                                authProvider.clearError();
                                final success = await authProvider.login(
                                  email: emailController.text.trim(),
                                  password: passwordController.text.trim(),
                                );

                                if (success && context.mounted) {
                                  ToastService.showSuccess("Welcome back!");
                                  context.pushReplacementNamed(
                                    UserAppRoutes.tabScreen.name,
                                  );
                                } else if (authProvider.error != null) {
                                  ToastService.showError(authProvider.error!);
                                }
                              }
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
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
