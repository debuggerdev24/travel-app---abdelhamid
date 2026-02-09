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

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
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
                      text: "Change ",
                      style: textStyle32Bold.copyWith(
                        color: AppColors.secondary,
                      ),
                      children: [
                        TextSpan(
                          text: "Password",
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
                  text: "Enter your new password to update your account.",
                  style: textStyle14Italic,
                ),
                36.h.verticalSpace,
                Form(
                  key: _formKey,
                  child: Column(
                    spacing: 22.h,
                    children: [
                      AppTextField(
                        hintText: "New Password",
                        controller: passwordController,
                        obSecureText: true,
                        validator: Validator.validatePassword,
                      ),
                      AppTextField(
                        hintText: "Confirm Password",
                        controller: confirmPasswordController,
                        obSecureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Confirm Password is required";
                          }
                          if (value != passwordController.text) {
                            return "Passwords do not match";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                60.h.verticalSpace,
                Selector<AuthProvider, bool>(
                  selector: (context, provider) => provider.isLoading,
                  builder: (context, isLoading, child) {
                    if (isLoading) return const CircularProgressIndicator();
                    return AppButton(
                      title: "Change Password",
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          await context.read<AuthProvider>().resetPassword(
                            email: widget.email,
                            password: passwordController.text.trim(),
                            onError: (error) {
                              ToastService.showError(error);
                            },
                            onSuccess: () {
                              ToastService.showSuccess(
                                "Password updated successfully",
                              );
                              context.goNamed(UserAppRoutes.signInScreen.name);
                            },
                          );
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
