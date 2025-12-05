import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';

class CustomTabButton extends StatelessWidget {
  final String text;
  final int index;
  final int selectedTab;
  final VoidCallback onTap;

  const CustomTabButton( {
    super.key,
    required this.text,
    required this.index,
    required this.selectedTab,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool active = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 42.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(160.r),
            color: active ? Colors.white : Colors.transparent,
          ),
          child: Text(
            text,
            style: textStyle14Regular.copyWith(
              fontSize: 14.sp,

    fontWeight: FontWeight.w500,
              color: active ? Colors.black : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
