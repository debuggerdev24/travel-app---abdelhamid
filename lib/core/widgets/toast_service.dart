import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toastification/toastification.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/routes/go_routes.dart';

class ToastService {
  static OverlayState? get _rootOverlay =>
      UserAppRoute.rootNavigatorKey.currentState?.overlay;

  static void show({
    required String message,
    required Color backgroundColor,
    Color? textColor,
    Icon? icon,
    ToastificationType type = ToastificationType.info,
    Duration? duration,
  }) {
    toastification.dismissAll();
    toastification.show(
      primaryColor: AppColors.whiteColor,
      borderSide: const BorderSide(color: Colors.transparent),
      overlayState: _rootOverlay,
      type: type,
      backgroundColor: backgroundColor,
      autoCloseDuration: duration ?? const Duration(seconds: 4),
      alignment: Alignment.topRight,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      icon: icon,

      title: Text(
        message,
        maxLines: 6,
        overflow: TextOverflow.ellipsis,
        style: textStyle14Medium.copyWith(
          color: textColor ?? AppColors.whiteColor,
          fontSize: 16.sp,
        ),
      ),
    );
  }

  static void showSuccess(String message, {Duration? duration}) {
    show(
      message: message,
      type: ToastificationType.success,
      backgroundColor: Colors.green.shade600,
      duration: duration,
    );
  }

  static void showError(String message) {
    show(
      message: message,
      type: ToastificationType.error,
      backgroundColor: Colors.red.shade600,
    );
  }

  static void showWarning(String message) {
    show(
      message: message,
      textColor: AppColors.black,
      type: ToastificationType.warning,
      backgroundColor: Colors.yellow,
      icon: const Icon(Icons.warning_amber_rounded, color: AppColors.black),
    );
  }

  static void showInfo(String message, {Duration? duration}) {
    show(
      message: message,
      type: ToastificationType.info,
      backgroundColor: Colors.blue,
      duration: duration,
    );
  }

  static void dismiss() {
    toastification.dismissAll();
  }
}
