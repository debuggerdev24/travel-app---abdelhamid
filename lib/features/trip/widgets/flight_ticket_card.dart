import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/utils/date_format_helper.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';
import 'package:travel_app_abdelhamid/model/user_flight_model.dart';
import 'package:url_launcher/url_launcher.dart';

/// Boarding-pass style card for one outbound or return flight.
class FlightTicketCard extends StatelessWidget {
  const FlightTicketCard({super.key, required this.flight});

  final FlightInfoModel flight;

  bool get _isOutbound => flight.flightType == 'outbound';

  bool get _isPending => flight.status.trim().toLowerCase() == 'pending';

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
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
          _header(context),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _times(context, onSurface),
                if (flight.route.trim().isNotEmpty) ...[
                  12.h.verticalSpace,
                  AppText(
                    text: flight.route.trim(),
                    style: textStyle14Regular.copyWith(
                      color: onSurface.withValues(alpha: 0.7),
                      fontSize: 13.sp,
                    ),
                  ),
                ],
                14.h.verticalSpace,
                Divider(
                  height: 1,
                  color: onSurface.withValues(alpha: 0.1),
                ),
                14.h.verticalSpace,
                Row(
                  children: [
                    _fact(context, 'Seat'.tr(), flight.seatNumber),
                    _fact(context, 'Baggage'.tr(), flight.baggage),
                    _fact(context, 'Desk No'.tr(), flight.deskNumber),
                  ],
                ),
                14.h.verticalSpace,
                _contactRow(
                  context,
                  icon: Icons.phone_outlined,
                  label: 'Airline Contact'.tr(),
                  value: flight.airlineContact,
                  onTap: () => _callNumber(flight.airlineContact),
                ),
                8.h.verticalSpace,
                _contactRow(
                  context,
                  icon: Icons.mail_outline,
                  label: 'Email'.tr(),
                  value: flight.supportEmail,
                  onTap: () => _sendEmail(flight.supportEmail),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    final title = _isOutbound ? 'Outbound Flight'.tr() : 'Return Flight'.tr();
    final name = flight.flightName.trim().isEmpty ? '-' : flight.flightName.trim();
    return Container(
      width: double.infinity,
      color: AppColors.blueColor,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Icon(
            _isOutbound ? Icons.flight_takeoff : Icons.flight_land,
            color: AppColors.secondary,
            size: 22.sp,
          ),
          10.w.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle16SemiBold.copyWith(
                    color: AppColors.whiteColor,
                    fontSize: 16.sp,
                  ),
                ),
                2.h.verticalSpace,
                AppText(
                  text: name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle14Regular.copyWith(
                    color: AppColors.whiteColor.withValues(alpha: 0.85),
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
          if (flight.status.trim().isNotEmpty) ...[
            8.w.horizontalSpace,
            _statusChip(),
          ],
        ],
      ),
    );
  }

  Widget _statusChip() {
    final pending = _isPending;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: pending
            ? AppColors.secondary
            : AppColors.whiteColor.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: AppText(
        text: flight.status.trim(),
        style: textStyle14Medium.copyWith(
          color: pending ? AppColors.primaryColor : AppColors.whiteColor,
          fontSize: 12.sp,
        ),
      ),
    );
  }

  Widget _times(BuildContext context, Color onSurface) {
    return Row(
      children: [
        Expanded(
          child: _timeColumn(
            context,
            'Departure'.tr(),
            flight.departureTime,
            CrossAxisAlignment.start,
            onSurface,
          ),
        ),
        Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: AppColors.lightblueColor.withValues(alpha: 0.45),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.flight,
            color: AppColors.blueColor,
            size: 18.sp,
          ),
        ),
        Expanded(
          child: _timeColumn(
            context,
            'Arrival'.tr(),
            flight.arrivalTime,
            CrossAxisAlignment.end,
            onSurface,
          ),
        ),
      ],
    );
  }

  Widget _timeColumn(
    BuildContext context,
    String label,
    String time,
    CrossAxisAlignment align,
    Color onSurface,
  ) {
    final shown = time.trim().isEmpty ? '-' : time.trim();
    final extra = align == CrossAxisAlignment.start
        ? formatDateForDisplay(flight.date)
        : flight.duration.trim();
    return Column(
      crossAxisAlignment: align,
      children: [
        AppText(
          text: shown,
          style: textStyle16SemiBold.copyWith(
            color: onSurface,
            fontSize: 18.sp,
          ),
        ),
        4.h.verticalSpace,
        AppText(
          text: label,
          style: textStyle14Regular.copyWith(
            color: onSurface.withValues(alpha: 0.55),
            fontSize: 12.sp,
          ),
        ),
        if (extra.isNotEmpty) ...[
          4.h.verticalSpace,
          AppText(
            text: extra,
            style: textStyle14Medium.copyWith(
              color: AppColors.blueColor,
              fontSize: 12.sp,
            ),
          ),
        ],
      ],
    );
  }

  Widget _fact(BuildContext context, String label, String value) {
    final shown = value.trim().isEmpty ? '-' : value.trim();
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: label,
            style: textStyle14Regular.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
              fontSize: 12.sp,
            ),
          ),
          4.h.verticalSpace,
          AppText(
            text: shown,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textStyle14Medium.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final shown = value.trim().isEmpty ? '-' : value.trim();
    final canOpen = value.trim().isNotEmpty;
    return InkWell(
      onTap: canOpen ? onTap : null,
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: AppColors.blueColor),
          10.w.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: label,
                  style: textStyle14Regular.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                    fontSize: 11.sp,
                  ),
                ),
                AppText(
                  text: shown,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle14Medium.copyWith(
                    color: canOpen
                        ? AppColors.blueColor
                        : Theme.of(context).colorScheme.onSurface,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _callNumber(String raw) async {
  final digits = raw.replaceAll(RegExp(r'[^\d+]'), '');
  if (digits.isEmpty) return;
  final uri = Uri.parse('tel:$digits');
  if (!await canLaunchUrl(uri)) return;
  await launchUrl(uri);
}

Future<void> _sendEmail(String raw) async {
  final email = raw.trim();
  if (email.isEmpty) return;
  final uri = Uri.parse('mailto:$email');
  if (!await canLaunchUrl(uri)) return;
  await launchUrl(uri);
}
