import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';

class ToastHelper {
  ToastHelper._internal();

  static void showSuccess(String message) {
    _showToast(
      message: message,
      backgroundColor: AppColors.secondary,
      textColor: Colors.white,
    );
  }

  static void showError(String message) {
    _showToast(
      message: message,
      backgroundColor: Colors.redAccent,
      textColor: Colors.white,
    );
  }

  static void showInfo(String message) {
    _showToast(
      message: message,
      backgroundColor: AppColors.primaryColor,
      textColor: Colors.white,
    );
  }

  static void _showToast({
    required String message,
    required Color backgroundColor,
    required Color textColor,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: 16.0,
    );
  }
}
