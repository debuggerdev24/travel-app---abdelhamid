import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/core/widgets/custom_switch_button.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                      child: SvgIcon(AppAssets.backIcon, size: 28.w),
                    ),
                  ),
                  AppText(
                    text: "App Settings",
                    style: textStyle32Bold.copyWith(
                      fontSize: 26.sp,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),

              22.h.verticalSpace,

              _settingTile(
                title: "Light mode",
                value: lightMode,
                onChanged: (v) {
                  setState(() {
                    lightMode = v;
                    if (v) {
                      darkMode = false;
                      systemDefault = false;
                    }
                  });
                },
              ),

              SizedBox(height: 16),

              _settingTile(
                title: "Dark mode",
                value: darkMode,
                onChanged: (v) {
                  setState(() {
                    darkMode = v;
                    if (v) {
                      lightMode = false;
                      systemDefault = false;
                    }
                  });
                },
              ),

              SizedBox(height: 16),

              _settingTile(
                title: "System default",
                value: systemDefault,
                onChanged: (v) {
                  setState(() {
                    systemDefault = v;
                    if (v) {
                      lightMode = false;
                      darkMode = false;
                    }
                  });
                },
              ),

              SizedBox(height: 16),

              _settingTile(
                title: "Auto App Update",
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
        color: Colors.white,
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
          AppText(text: title, style: textStyle16SemiBold.copyWith()),
          CustomSwitchButton(
            initialValue: value,

            onChanged: (v) => onChanged(v),
          ),
        ],
      ),
    );
  }
}
