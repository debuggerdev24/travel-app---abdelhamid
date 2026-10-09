import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/utils/date_format_helper.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';
import 'package:travel_app_abdelhamid/model/home/hotel_voucher_model.dart';
import 'package:url_launcher/url_launcher.dart';

/// Stay card for one hotel, in the same style as the flight ticket.
class HotelStayCard extends StatelessWidget {
  const HotelStayCard({
    super.key,
    required this.hotel,
    required this.fallbackTitle,
  });

  final HotelVoucherModel hotel;
  final String fallbackTitle;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final room = hotel.rooms.isNotEmpty ? hotel.rooms.first : null;
    final guests = room == null ? '' : room.guests.join(', ');
    final facilities = hotel.facilitiesDisplayText.trim();
    final address = hotel.hotelAddress.trim();
    final mapLink = (hotel.locationUrl ?? '').trim();
    final link = mapLink.isNotEmpty
        ? mapLink
        : (_isWebLink(address) ? address : '');
    final addressText = _isWebLink(address)
        ? 'Open in Maps'.tr()
        : (address.isEmpty ? '-' : address);

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
                _stayTimes(context, onSurface),
                if (room != null) ...[
                  14.h.verticalSpace,
                  Divider(height: 1, color: onSurface.withValues(alpha: 0.1)),
                  14.h.verticalSpace,
                  Row(
                    children: [
                      _fact(context, 'Room Type'.tr(), room.roomType),
                      _fact(context, 'Room No'.tr(), room.roomNumber),
                      if (guests.isNotEmpty)
                        _fact(context, 'Guests'.tr(), guests),
                    ],
                  ),
                ],
                14.h.verticalSpace,
                _contactRow(
                  context,
                  icon: Icons.location_on_outlined,
                  label: 'Address'.tr(),
                  value: addressText,
                  onTap: link.isEmpty ? null : () => _openLink(link),
                ),
                8.h.verticalSpace,
                _contactRow(
                  context,
                  icon: Icons.phone_outlined,
                  label: 'Phone'.tr(),
                  value: hotel.hotelContact,
                  onTap: hotel.hotelContact.trim().isEmpty
                      ? null
                      : () => _callNumber(hotel.hotelContact),
                ),
                if (hotel.hotelEmail.trim().isNotEmpty) ...[
                  8.h.verticalSpace,
                  _contactRow(
                    context,
                    icon: Icons.mail_outline,
                    label: 'Email'.tr(),
                    value: hotel.hotelEmail,
                    onTap: () => _sendEmail(hotel.hotelEmail),
                  ),
                ],
                if (facilities.isNotEmpty) ...[
                  14.h.verticalSpace,
                  AppText(
                    text: 'Facilities'.tr(),
                    style: textStyle14Regular.copyWith(
                      color: onSurface.withValues(alpha: 0.55),
                      fontSize: 12.sp,
                    ),
                  ),
                  4.h.verticalSpace,
                  AppText(
                    text: facilities,
                    style: textStyle14Medium.copyWith(
                      color: onSurface,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    final name = hotel.hotelName.trim().isEmpty
        ? fallbackTitle
        : hotel.hotelName.trim();
    final nights = int.tryParse(hotel.stayInfo.nights.trim()) ?? 0;
    return Container(
      width: double.infinity,
      color: AppColors.blueColor,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Icon(Icons.hotel, color: AppColors.secondary, size: 22.sp),
          10.w.horizontalSpace,
          Expanded(
            child: AppText(
              text: name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textStyle16SemiBold.copyWith(
                color: AppColors.whiteColor,
                fontSize: 16.sp,
              ),
            ),
          ),
          if (nights > 0) ...[
            8.w.horizontalSpace,
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: AppText(
                text: '$nights ${'Nights'.tr()}',
                style: textStyle14Medium.copyWith(
                  color: AppColors.primaryColor,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _stayTimes(BuildContext context, Color onSurface) {
    final checkIn = _moment(hotel.stayInfo.checkIn);
    final checkOut = _moment(hotel.stayInfo.checkOut);
    return Row(
      children: [
        Expanded(
          child: _timeColumn(
            context,
            'Check-in'.tr(),
            checkIn,
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
            Icons.hotel_outlined,
            color: AppColors.blueColor,
            size: 18.sp,
          ),
        ),
        Expanded(
          child: _timeColumn(
            context,
            'Check-out'.tr(),
            checkOut,
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
    _StayMoment moment,
    CrossAxisAlignment align,
    Color onSurface,
  ) {
    return Column(
      crossAxisAlignment: align,
      children: [
        AppText(
          text: moment.main,
          textAlign: align == CrossAxisAlignment.end
              ? TextAlign.end
              : TextAlign.start,
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
        if (moment.extra.isNotEmpty) ...[
          4.h.verticalSpace,
          AppText(
            text: moment.extra,
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
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.55),
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
    required VoidCallback? onTap,
  }) {
    final shown = value.trim().isEmpty ? '-' : value.trim();
    return InkWell(
      onTap: onTap,
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
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.55),
                    fontSize: 11.sp,
                  ),
                ),
                AppText(
                  text: shown,
                  maxLines: onTap == null ? 3 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle14Medium.copyWith(
                    color: onTap == null
                        ? Theme.of(context).colorScheme.onSurface
                        : AppColors.blueColor,
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

/// Escort row above the hotel cards, in the same navy header style.
class EscortStayCard extends StatelessWidget {
  const EscortStayCard({super.key, required this.name, required this.phone});

  final String name;
  final String phone;

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
          Container(
            width: double.infinity,
            color: AppColors.blueColor,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                Icon(Icons.person, color: AppColors.secondary, size: 22.sp),
                10.w.horizontalSpace,
                Expanded(
                  child: AppText(
                    text: 'Escort Contact'.tr(),
                    style: textStyle16SemiBold.copyWith(
                      color: AppColors.whiteColor,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: 'Escort Name'.tr(),
                  style: textStyle14Regular.copyWith(
                    color: onSurface.withValues(alpha: 0.55),
                    fontSize: 12.sp,
                  ),
                ),
                4.h.verticalSpace,
                AppText(
                  text: name,
                  style: textStyle16SemiBold.copyWith(
                    color: onSurface,
                    fontSize: 16.sp,
                  ),
                ),
                12.h.verticalSpace,
                InkWell(
                  onTap: phone.trim().isEmpty ? null : () => _callNumber(phone),
                  child: Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 18.sp,
                        color: AppColors.blueColor,
                      ),
                      10.w.horizontalSpace,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              text: 'Phone'.tr(),
                              style: textStyle14Regular.copyWith(
                                color: onSurface.withValues(alpha: 0.55),
                                fontSize: 11.sp,
                              ),
                            ),
                            AppText(
                              text: phone,
                              style: textStyle14Medium.copyWith(
                                color: AppColors.blueColor,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

class _StayMoment {
  const _StayMoment(this.main, this.extra);

  final String main;
  final String extra;
}

_StayMoment _moment(String? raw) {
  final dt = parseApiDate(raw);
  if (dt == null) {
    final text = formatDateTimeForDisplay(raw);
    return _StayMoment(text == '—' ? '-' : text, '');
  }
  final local = dt.toLocal();
  final date = formatDateForDisplay(raw);
  final shownDate = date == '—' ? '' : date;
  final trimmed = raw?.trim() ?? '';
  final hasTime =
      trimmed.contains('T') || RegExp(r'\d{1,2}:\d{2}').hasMatch(trimmed);
  if (!hasTime) {
    return _StayMoment(shownDate.isEmpty ? '-' : shownDate, '');
  }
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return _StayMoment('$hour:$minute', shownDate);
}

bool _isWebLink(String value) {
  final text = value.trim().toLowerCase();
  return text.startsWith('http://') || text.startsWith('https://');
}

Future<void> _openLink(String raw) async {
  final uri = Uri.tryParse(raw.trim());
  if (uri == null) return;
  if (!await canLaunchUrl(uri)) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
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
