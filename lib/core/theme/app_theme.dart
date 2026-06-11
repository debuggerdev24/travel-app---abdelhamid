import 'package:flutter/material.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';

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

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: AppColors.skyblueColor,
        secondary: AppColors.secondary,
        surface: const Color(0xFF1E1E1E),
        error: AppColors.redColor,
        onPrimary: AppColors.whiteColor,
        onSecondary: AppColors.whiteColor,
        onSurface: AppColors.whiteColor,
        onError: AppColors.whiteColor,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      fontFamily: 'Poppins',
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: AppColors.whiteColor,
        elevation: 0,
      ),
    );
  }
}
