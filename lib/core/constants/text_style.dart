import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';

final textStyle32Bold = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 32.sp,
  fontWeight: FontWeight.w700,
);
final textStyle12semiBold = TextStyle(
  fontSize: 12.sp,
  fontFamily: 'Poppins',
  fontWeight: FontWeight.w600,
  color: AppColors.tabtextcolor,
);
final textPopinnsMeidium = TextStyle(
  fontSize: 12.sp,
  fontFamily: 'Poppins',
  fontWeight: FontWeight.w500,
);

final textStyle18Bold = TextStyle(
  fontSize: 18.sp,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w700,
  color: AppColors.whiteColor,
);

final textStyle14Regular = TextStyle(
  fontSize: 14.sp,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w400,
  color: AppColors.primaryColor.withOpacity(0.6),
);
final textStyle14Italic = TextStyle(
  fontSize: 14.sp,
  fontFamily: 'Roboto',
  fontStyle: FontStyle.italic,
  color: AppColors.primaryColor.withOpacity(0.6),
);
final textStyle16SemiBold = TextStyle(
  fontSize: 16.sp,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w600,
  color: AppColors.primaryColor,
);
final textStyle14Medium = TextStyle(
  fontSize: 14.sp,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w600,
  color: AppColors.primaryColor,
);

final textStyle10Regular = TextStyle(
  fontSize: 10.sp,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w400,
  color: AppColors.primaryColor.withOpacity(0.6),
);

final textStyle12Regular = TextStyle(
  fontSize: 12.sp,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w400,
  color: AppColors.primaryColor.withOpacity(0.6),
);

// final textStyle14Regular = TextStyle(
//     fontSize: 14.sp,
//     fontFamily: 'Jaldi',
//     fontWeight: FontWeight.normal,
//     color: AppColors.black.withOpacity(0.8),
//     letterSpacing: 0.1
//     // letterSpacing: 0.4
//     );

// final textStyle16RegularGrey = TextStyle(
//     fontFamily: 'Jaldi',
//     fontWeight: FontWeight.w400,
//     color: AppColors.b,
//     fontSize: 15.sp
//     // letterSpacing: 0.4
//     );

// final textStyle16Regular = TextStyle(
//     fontSize: 16.sp,
//     fontFamily: 'Jaldi',
//     fontWeight: FontWeight.normal,
//     color: AppColors.blackColor.withOpacity(0.9),
//     letterSpacing: 0.2
//     // letterSpacing: 0.4
//     );

// final textStyle16Bold = TextStyle(
//     fontSize: 16.sp,
//     fontFamily: 'Jaldi',
//     fontWeight: FontWeight.w500,
//     color: AppColors.blackColor,
//     letterSpacing: 0.2
//     // letterSpacing: 0.4
//     );

// final textStyletitleBold = TextStyle(
//     fontSize: 20.sp,
//     fontWeight: FontWeight.w500,
//     fontFamily: 'Jaldi',
//     color: AppColors.primaryColor);

// final textStyle20titleBold = TextStyle(
//     fontSize: 18.sp,
//     fontWeight: FontWeight.w500,
//     fontFamily: 'Jaldi',
//     color: AppColors.primaryColor);

final textStylesubtitleBold = TextStyle(
  fontSize: 22.sp,
  fontWeight: FontWeight.w400,
  color: AppColors.black,
);
final primaryTextButtonTheme = TextButton.styleFrom(
  foregroundColor: Colors.white,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
  textStyle: TextStyle(
    fontFamily: 'Jaldi',
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
  ),
);
final primaryElevatedButtonTheme = ElevatedButton.styleFrom(
  // elevation: 0,
  // backgroundColor: AppColors.blackColor,
  foregroundColor: Colors.white,
  fixedSize: Size(ScreenUtil().screenWidth, 48.h),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
  textStyle: TextStyle(
    fontFamily: 'Roboto',
    fontSize: 18.sp,
    fontWeight: FontWeight.w700,
  ),
);
