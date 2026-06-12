import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';
import 'package:travel_app_abdelhamid/core/utils/server_media_url.dart';
import 'package:travel_app_abdelhamid/core/widgets/network_image_with_shimmer.dart';

class TripCard extends StatelessWidget {
  final String image;
  final String title;
  final String location;
  final String date;
  final String status;
  final String? paymentStatus;
  final VoidCallback onTap;

  const TripCard({
    super.key,
    required this.image,
    required this.title,
    required this.location,
    required this.date,
    required this.status,
    this.paymentStatus,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedImageUrl = serverMediaUrl(image);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 24.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12.r),
            topRight: Radius.circular(12.r),
            bottomLeft: Radius.circular(20.r),
            bottomRight: Radius.circular(20.r),
          ),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
              child: image.startsWith('assets')
                  ? Image.asset(
                      image,
                      height: 200.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : (resolvedImageUrl == null || resolvedImageUrl.isEmpty)
                  ? Container(
                      height: 200.h,
                      width: double.infinity,
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: Icon(
                        Icons.broken_image,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    )
                  : NetworkImageWithShimmer(
                      imageUrl: resolvedImageUrl,
                      height: 200.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12.r),
                      ),
                    ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title row with clipboard icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: AppText(
                          text: title,
                          style: textStyle16SemiBold.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      8.w.horizontalSpace,
                      Icon(
                        Icons.assignment_outlined,
                        size: 20.w,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ],
                  ),
                  12.h.verticalSpace,

                  /// Location with icon
                  Row(
                    children: [
                      SvgIcon(
                        AppAssets.location,
                        size: 16.w,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      8.w.horizontalSpace,
                      AppText(
                        text: location,
                        style: textStyle14Regular.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),

                  12.h.verticalSpace,

                  /// Date with calendar icon
                  Row(
                    children: [
                      SvgIcon(
                        AppAssets.calendar,
                        size: 16.w,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      8.w.horizontalSpace,
                      AppText(
                        text: date,
                        style: textStyle14Regular.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),

                  /// Status (Only show if not empty)
                  if (status.isNotEmpty) ...[
                    12.h.verticalSpace,
                    Row(
                      children: [
                        AppText(
                          text: "Status : ",
                          style: textStyle14Regular.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        AppText(
                          text: status,
                          style: textStyle14Medium.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],

                  /// Payment Status (Only show if not empty)
                  if (paymentStatus != null && paymentStatus!.isNotEmpty) ...[
                    12.h.verticalSpace,
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getPaymentStatusColor(
                          context,
                          paymentStatus!,
                        ).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: _getPaymentStatusColor(
                            context,
                            paymentStatus!,
                          ),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getPaymentStatusIcon(paymentStatus!),
                            size: 14.w,
                            color: _getPaymentStatusColor(
                              context,
                              paymentStatus!,
                            ),
                          ),
                          6.w.horizontalSpace,
                          AppText(
                            text: "Payment: $paymentStatus",
                            style: textStyle12semiBold.copyWith(
                              color: _getPaymentStatusColor(
                                context,
                                paymentStatus!,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPaymentStatusColor(BuildContext context, String status) {
    final lowerStatus = status.toLowerCase();
    if (lowerStatus.contains('pending') || lowerStatus.contains('unpaid')) {
      return Colors.orange;
    } else if (lowerStatus.contains('paid') ||
        lowerStatus.contains('complete')) {
      return Colors.green;
    } else if (lowerStatus.contains('failed') ||
        lowerStatus.contains('cancelled')) {
      return Colors.red;
    }
    return Theme.of(context).colorScheme.primary;
  }

  IconData _getPaymentStatusIcon(String status) {
    final lowerStatus = status.toLowerCase();
    if (lowerStatus.contains('pending') || lowerStatus.contains('unpaid')) {
      return Icons.pending_outlined;
    } else if (lowerStatus.contains('paid') ||
        lowerStatus.contains('complete')) {
      return Icons.check_circle_outline;
    } else if (lowerStatus.contains('failed') ||
        lowerStatus.contains('cancelled')) {
      return Icons.error_outline;
    }
    return Icons.info_outline;
  }
}
