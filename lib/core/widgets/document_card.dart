import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';
import 'package:travel_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:travel_app_abdelhamid/core/widgets/network_image_with_shimmer.dart';
import 'package:travel_app_abdelhamid/model/home/trip_model.dart';

class DocumentCard extends StatelessWidget {
  final DocumentModel doc;

  /// Primary action (View).
  final VoidCallback onTap;

  /// Secondary action (Map / Helpline / Download). Defaults to [onTap].
  final VoidCallback? onSecondaryTap;

  const DocumentCard({
    super.key,
    required this.doc,
    required this.onTap,
    this.onSecondaryTap,
  });

  Widget _buildThumbnail() {
    final w = 140.w;
    final h = 126.h;
    if (doc.fileImage != null) {
      return _thumbnailBox(
        w,
        h,
        Image.file(doc.fileImage!, width: w, height: h, fit: BoxFit.contain),
      );
    }
    final url = doc.networkThumbnailUrl;
    if (url != null && url.isNotEmpty) {
      return _thumbnailBox(
        w,
        h,
        NetworkImageWithShimmer(
          imageUrl: url,
          width: w,
          height: h,
          fit: BoxFit.contain,
        ),
      );
    }
    return _thumbnailBox(
      w,
      h,
      Image.asset(doc.image, width: w, height: h, fit: BoxFit.contain),
    );
  }

  Widget _thumbnailBox(double w, double h, Widget child) {
    return SizedBox(
      width: w,
      height: h,
      child: ColoredBox(
        color: Colors.white,
        child: Center(child: child),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70.w,
            child: AppText(
              text: label,
              style: textStyle14Regular.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 13.sp,
              ),
            ),
          ),
          AppText(
            text: " :  ",
            style: textStyle14Regular.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          Expanded(
            child: AppText(
              text: value,
              style: textStyle14Regular.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primaryColor.setOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.setOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: _buildThumbnail(),
              ),

              14.w.horizontalSpace,
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (doc.subtitle != null) ...[
                      AppText(
                        text: doc.subtitle!,
                        style: textStyle14Medium.copyWith(
                          fontSize: 12.sp,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      4.h.verticalSpace,
                    ],

                    AppText(
                      text: doc.title,
                      style: textStyle16SemiBold.copyWith(
                        fontSize: 16.sp,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),

                    8.h.verticalSpace,
                    if (doc.info != null)
                      ...doc.info!.entries.map(
                        (entry) =>
                            _buildInfoRow(context, entry.key, entry.value),
                      ),
                  ],
                ),
              ),
            ],
          ),
          16.h.verticalSpace,

          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onTap,
                  child: Container(
                    height: 46.h,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.blueColor.setOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      color: AppColors.blueColor,
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.remove_red_eye_outlined,
                            color: Theme.of(context).colorScheme.surface,
                            size: 18,
                          ),
                          12.w.horizontalSpace,
                          AppText(
                            text: doc.button1,
                            style: textStyle14Medium.copyWith(
                              color: Theme.of(context).colorScheme.surface,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              20.w.horizontalSpace,

              Expanded(
                child: GestureDetector(
                  onTap: onSecondaryTap ?? onTap,
                  child: Container(
                    height: 46.h,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.blueColor.setOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      color: Theme.of(context).colorScheme.surface,
                      border: Border.all(
                        color: AppColors.blueColor,
                        width: 0.8,
                      ),
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgIcon(doc.icon, size: 20.w),
                          12.w.horizontalSpace,
                          AppText(
                            text: doc.button2,
                            style: textStyle14Medium.copyWith(
                              color: AppColors.blueColor,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
