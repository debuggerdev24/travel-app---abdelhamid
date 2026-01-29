import 'package:flutter/material.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';

/// Application theme configuration.
/// Centralizes colors and typography for consistency.
/// For screen-specific text use [core/constants/text_style.dart] (uses ScreenUtil).
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.blueColor,
        secondary: AppColors.secondary,
        surface: AppColors.whiteColor,
        error: AppColors.redColor,
        onPrimary: AppColors.whiteColor,
        onSecondary: AppColors.primaryColor,
        onSurface: AppColors.primaryColor,
        onError: AppColors.whiteColor,
      ),
      scaffoldBackgroundColor: AppColors.whiteColor,
      fontFamily: 'Poppins',
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.whiteColor,
        foregroundColor: AppColors.primaryColor,
        elevation: 0,
      ),
    );
  }
}
