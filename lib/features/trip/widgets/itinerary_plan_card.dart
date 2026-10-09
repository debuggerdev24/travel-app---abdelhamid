import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/utils/date_format_helper.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';

/// One stop on today's plan.
class ItineraryPlanStep {
  const ItineraryPlanStep({
    required this.iconAsset,
    required this.title,
    required this.time,
  });

  final String iconAsset;
  final String title;
  final String time;
}

/// Today's itinerary as one card: day title, notes, then a timed list of stops.
class ItineraryPlanCard extends StatelessWidget {
  const ItineraryPlanCard({
    super.key,
    required this.title,
    required this.steps,
    this.notes,
    this.date,
    this.status = '',
  });

  final String title;
  final String? notes;
  final String? date;
  final String status;
  final List<ItineraryPlanStep> steps;

  bool get _isCompleted => status.trim().toLowerCase() == 'completed';

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final note = notes?.trim() ?? '';
    final dateLabel = formatDateForDisplay(date);
    final showDate = dateLabel != '—';

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.blueColor.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context, showDate ? dateLabel : ''),
          if (note.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
              child: AppText(
                text: note,
                style: textStyle14Regular.copyWith(
                  color: onSurface.withValues(alpha: 0.75),
                  fontSize: 13.sp,
                  height: 1.4,
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
            child: Column(
              children: [
                for (var i = 0; i < steps.length; i++)
                  _step(
                    context,
                    steps[i],
                    isLast: i == steps.length - 1,
                    onSurface: onSurface,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, String dateLabel) {
    final heading = title.trim().isEmpty ? 'Itinerary'.tr() : title.trim();
    return Container(
      width: double.infinity,
      color: AppColors.blueColor,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Icon(Icons.route, color: AppColors.secondary, size: 22.sp),
          10.w.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: heading,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle16SemiBold.copyWith(
                    color: AppColors.whiteColor,
                    fontSize: 16.sp,
                  ),
                ),
                if (dateLabel.isNotEmpty) ...[
                  2.h.verticalSpace,
                  AppText(
                    text: dateLabel,
                    style: textStyle14Regular.copyWith(
                      color: AppColors.whiteColor.withValues(alpha: 0.85),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (status.trim().isNotEmpty) ...[
            8.w.horizontalSpace,
            _statusChip(),
          ],
        ],
      ),
    );
  }

  Widget _statusChip() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: _isCompleted
            ? AppColors.secondary
            : AppColors.whiteColor.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: AppText(
        text: status.trim(),
        style: textStyle14Medium.copyWith(
          color: _isCompleted ? AppColors.primaryColor : AppColors.whiteColor,
          fontSize: 12.sp,
        ),
      ),
    );
  }

  Widget _step(
    BuildContext context,
    ItineraryPlanStep step, {
    required bool isLast,
    required Color onSurface,
  }) {
    final time = step.time.trim().isEmpty ? '-' : step.time.trim();
    final name = step.title.trim().isEmpty ? '-' : step.title.trim();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 58.w,
          child: Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: AppText(
              text: time,
              style: textStyle14Medium.copyWith(
                color: AppColors.blueColor,
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
              ),
            ),
          ),
        ),
        Column(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: AppColors.lightblueColor.withValues(alpha: 0.45),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: SvgIcon(
                step.iconAsset,
                size: 16.w,
                color: AppColors.blueColor,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 22.h,
                color: AppColors.blueColor.withValues(alpha: 0.2),
              ),
          ],
        ),
        12.w.horizontalSpace,
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 6.h, bottom: isLast ? 0 : 10.h),
            child: AppText(
              text: name,
              style: textStyle14Medium.copyWith(
                color: onSurface,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
