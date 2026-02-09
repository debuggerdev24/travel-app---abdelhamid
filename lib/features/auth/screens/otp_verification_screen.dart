import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_button.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/core/widgets/toast_service.dart';
import 'package:trael_app_abdelhamid/features/auth/provider/auth_provider.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:trael_app_abdelhamid/routes/user_routes.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Timer? _timer;
  int _secondsRemaining = 60;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 60;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
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
                  text: "Enter the 6-digit code we sent to your email",
                  style: textStyle14Italic,
                ),
                40.h.verticalSpace,
                Form(
                  key: _formKey,
                  child: Pinput(
                    controller: _otpController,
                    length: 6,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter OTP";
                      }
                      if (value.length != 6) {
                        return "Please enter 6-digit OTP";
                      }
                      return null;
                    },
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
                ),

                40.h.verticalSpace,
                Selector<AuthProvider, bool>(
                  selector: (context, provider) => provider.isLoading,
                  builder: (context, isLoading, child) {
                    if (isLoading) const CircularProgressIndicator();
                    return AppButton(
                      title: "Verify",
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<AuthProvider>().verifyOtp(
                            email: widget.email,
                            otp: _otpController.text,
                            onSuccess: (data) {
                              ToastService.showSuccess(
                                "OTP verified successfully",
                              );
                              context.pushNamed(
                                UserAppRoutes.resetPasswordScreen.name,
                                queryParameters: {'email': widget.email},
                              );
                            },
                            onError: (error) {
                              ToastService.showError(error);
                            },
                          );
                        }
                      },
                    );
                  },
                ),
                10.h.verticalSpace,
                RichText(
                  text: TextSpan(
                    text: "Didn't receive the code? ",
                    style: textStyle14Regular.copyWith(letterSpacing: 0.4),
                    children: [
                      TextSpan(
                        recognizer: _secondsRemaining == 0
                            ? (TapGestureRecognizer()
                                ..onTap = () {
                                  context.read<AuthProvider>().resendOtp(
                                    email: widget.email,
                                    onError: (error) =>
                                        ToastService.showError(error),
                                    onSuccess: () {
                                      ToastService.showSuccess(
                                        "OTP resent successful!",
                                      );
                                      _startTimer();
                                    },
                                  );
                                })
                            : null,
                        text: _secondsRemaining == 0
                            ? "Resend OTP"
                            : "Resend in ${_secondsRemaining}s",
                        style: textStyle18Bold.copyWith(
                          fontSize: 14.sp,
                          color: _secondsRemaining == 0
                              ? AppColors.secondary
                              : AppColors.secondary.setOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                59.h.verticalSpace,

                GestureDetector(
                  onTap: () {
                    context.pop();
                  },
                  child: AppText(
                    textAlign: TextAlign.center,
                    text: "Change phone/email",
                    style: textStyle14Regular.copyWith(
                      color: AppColors.secondary,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.secondary,
                      height: 1.0,
                    ),
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
