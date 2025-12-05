import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_button.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';

class FullScreenDocumentViewer extends StatelessWidget {
  final File? file;
  final String assetImage;
  final String title;

  const FullScreenDocumentViewer({
    super.key,
    this.file,
    required this.assetImage,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasFile = file != null;
    final bool isPdf = hasFile && file!.path.toLowerCase().endsWith('.pdf');

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Column(
          children: [
            /// ---------- HEADER ----------
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 27.w, vertical: 20.h),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: SvgIcon(AppAssets.backIcon, size: 26.w),
                    ),
                  ),
                  AppText(
                    text: title,
                    style: textStyle32Bold.copyWith(
                      fontSize: 26.sp,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),

            /// ---------- IMAGE / PDF VIEWER CONTAINER ----------
            Container(
              height: 300.h,
              width: 348.w,
              
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r,),
                child: _buildViewer(isPdf)),
            ),
            Spacer(),
            Padding(
                           padding: EdgeInsets.symmetric(horizontal: 27.w, vertical: 40.h),

              child: AppButton(title: "Download",),
            )
          ],
        ),
      ),
    );
  }

Widget _buildViewer(bool isPdf) {
  if (file != null) {
    if (isPdf) {
      // ---------- PDF VIEW ----------
      return SfPdfViewer.file(file!);
    } else {
      // ---------- FIT IMAGE INSIDE CONTAINER ----------
      return Image.file(
        file!,
        fit: BoxFit.cover,   
      );
    }
  } else {
    // ---------- FIT ASSET IMAGE ----------
    return Image.asset(
      assetImage,
      
    );
  }
}

}
