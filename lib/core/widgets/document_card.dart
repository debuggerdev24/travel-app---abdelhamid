import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';
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
    final w = 88.w;
    final h = 88.w;
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
    final muted = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.55);
    return Padding(
      padding: EdgeInsets.only(top: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: '$label:',
            style: textStyle14Regular.copyWith(color: muted, fontSize: 12.sp),
          ),
          8.w.horizontalSpace,
          Expanded(
            child: AppText(
              text: value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textStyle14Medium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 13.sp,
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
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.blueColor.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueColor.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
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
                        text: doc.subtitle!.tr(),
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
                            _buildInfoRow(context, entry.key.tr(), entry.value),
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
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: AppColors.blueColor,
                      borderRadius: BorderRadius.circular(8.r),
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
                            text: doc.button1.tr(),
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
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border.all(color: AppColors.blueColor, width: 1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgIcon(doc.icon, size: 20.w),
                          12.w.horizontalSpace,
                          AppText(
                            text: doc.button2.tr(),
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
