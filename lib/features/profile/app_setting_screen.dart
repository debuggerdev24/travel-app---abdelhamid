import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';
import 'package:travel_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';
import 'package:travel_app_abdelhamid/core/widgets/custom_switch_button.dart';
import 'package:travel_app_abdelhamid/provider/theme_provider.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool lightMode = true;
  bool darkMode = false;
  bool systemDefault = false;
  bool autoUpdate = false;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  void _loadThemeMode() {
    final themeProvider = context.read<ThemeProvider>();
    switch (themeProvider.themeModeOption) {
      case ThemeModeOption.light:
        lightMode = true;
        darkMode = false;
        systemDefault = false;
        break;
      case ThemeModeOption.dark:
        lightMode = false;
        darkMode = true;
        systemDefault = false;
        break;
      case ThemeModeOption.system:
        lightMode = false;
        darkMode = false;
        systemDefault = true;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 27.w), // NOT CHANGED
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              22.h.verticalSpace,

              // Header
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: SvgIcon(AppAssets.backIcon, size: 28.w, color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ),
                  AppText(
                    text: "App Settings".tr(),
                    style: textStyle32Bold.copyWith(
                      fontSize: 26.sp,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),

              22.h.verticalSpace,

              _settingTile(
                title: "Light mode".tr(),
                value: lightMode,
                onChanged: (v) {
                  setState(() {
                    lightMode = true;
                    darkMode = false;
                    systemDefault = false;
                  });
                  context.read<ThemeProvider>().setThemeMode(
                    ThemeModeOption.light,
                  );
                },
              ),

              SizedBox(height: 16),

              _settingTile(
                title: "Dark mode".tr(),
                value: darkMode,
                onChanged: (v) {
                  setState(() {
                    darkMode = true;
                    lightMode = false;
                    systemDefault = false;
                  });
                  context.read<ThemeProvider>().setThemeMode(
                    ThemeModeOption.dark,
                  );
                },
              ),

              SizedBox(height: 16),

              _settingTile(
                title: "System default".tr(),
                value: systemDefault,
                onChanged: (v) {
                  setState(() {
                    systemDefault = true;
                    lightMode = false;
                    darkMode = false;
                  });
                  context.read<ThemeProvider>().setThemeMode(
                    ThemeModeOption.system,
                  );
                },
              ),

              SizedBox(height: 16),

              _settingTile(
                title: "Auto App Update".tr(),
                value: autoUpdate,
                onChanged: (v) {
                  setState(() {
                    autoUpdate = v;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryColor.setOpacity(0.2)),
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueColor.setOpacity(0.08),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            text: title,
            style: textStyle16SemiBold.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          CustomSwitchButton(value: value, onChanged: (v) => onChanged(v)),
        ],
      ),
    );
  }
}
