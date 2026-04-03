import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/utils/document_download_helper.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_button.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';


class FullScreenDocumentViewer extends StatefulWidget {
  final File? file;
  /// Remote PDF or image URL (e.g. from [serverMediaUrl]).
  final String? networkFileUrl;
  final String assetImage;
  final String title;

  const FullScreenDocumentViewer({
    super.key,
    this.file,
    this.networkFileUrl,
    required this.assetImage,
    required this.title,
  });

  @override
  State<FullScreenDocumentViewer> createState() =>
      _FullScreenDocumentViewerState();
}

class _FullScreenDocumentViewerState extends State<FullScreenDocumentViewer> {
  bool _downloading = false;

  Future<void> _onDownload() async {
    if (_downloading) return;
    final hasLocal = widget.file != null && widget.file!.existsSync();
    final hasNet =
        widget.networkFileUrl != null && widget.networkFileUrl!.trim().isNotEmpty;
    if (!hasLocal && !hasNet) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No downloadable file for this document.'),
        ),
      );
      return;
    }

    setState(() => _downloading = true);
    try {
      await shareDocumentFile(
        context: context,
        localFile: widget.file,
        networkUrl: widget.networkFileUrl,
        label: widget.title.trim().isNotEmpty ? widget.title : 'Document',
      );
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    text: widget.title,
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
                border: Border.all(
                  color: AppColors.primaryColor.setOpacity(0.2),
                ),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: _buildViewer(),
              ),
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 27.w, vertical: 40.h),

              child: AppButton(
                title: "Download",
                isLoading: _downloading,
                onTap: _onDownload,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewer() {
    final net = widget.networkFileUrl;
    if (net != null && net.isNotEmpty) {
      final pathLower = net.toLowerCase().split('?').first;
      final isNetPdf = pathLower.endsWith('.pdf');
      if (isNetPdf) {
        return SfPdfViewer.network(net);
      }
      return Image.network(
        net,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Image.asset(widget.assetImage, fit: BoxFit.cover),
      );
    }
    if (widget.file != null) {
      final isPdf = widget.file!.path.toLowerCase().endsWith('.pdf');
      if (isPdf) {
        return SfPdfViewer.file(widget.file!);
      } else {
        return Image.file(widget.file!, fit: BoxFit.cover);
      }
    } else {
      return Image.asset(widget.assetImage);
    }
  }
}
