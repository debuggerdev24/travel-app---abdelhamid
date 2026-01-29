import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/core/widgets/custom_switch_button.dart';

class PrayerTimesScreen extends StatelessWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 27.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              22.h.verticalSpace,
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: SvgPicture.asset(
                        AppAssets.backIcon,
                        width: 28.5.w,
                      ),
                    ),
                  ),
                  AppText(
                    text: "Prayer Times",
                    style: textStyle32Bold.copyWith(
                      fontSize: 26.sp,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),

              30.h.verticalSpace,

              /// ---- PRAYER LIST ----
              PrayerTile(
                prayer: "Fajr",
                time: "05:23 AM",
                initialValue: true,
                onChanged: (v) {},
              ),
              PrayerTile(
                prayer: "Dhuhr",
                time: "12:31 PM",
                initialValue: false,
                onChanged: (v) {},
              ),
              PrayerTile(
                prayer: "Asr",
                time: "03:56 PM",
                initialValue: true,
                onChanged: (v) {},
              ),
              PrayerTile(
                prayer: "Maghrib",
                time: "06:12 PM",
                initialValue: false,
                onChanged: (v) {},
              ),
              PrayerTile(
                prayer: "Isha",
                time: "07:31 PM",
                initialValue: true,
                onChanged: (v) {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PrayerTile extends StatefulWidget {
  final String prayer;
  final String time;
  final bool initialValue;
  final Function(bool) onChanged;

  const PrayerTile({
    super.key,
    required this.prayer,
    required this.time,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<PrayerTile> createState() => _PrayerTileState();
}

class _PrayerTileState extends State<PrayerTile> {
  late bool isOn;

  @override
  void initState() {
    super.initState();
    isOn = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryColor.setOpacity(0.2)),
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueColor.setOpacity(0.08),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          /// Prayer Name with fixed width
          SizedBox(
            width: 65.w, // adjust width as needed
            child: AppText(
              text: widget.prayer,
              style: textStyle16SemiBold.copyWith(fontSize: 16.sp),
            ),
          ),

          SizedBox(
            width: 30.w,
            child: AppText(
              text: ":",
              style: textStyle16SemiBold.copyWith(fontSize: 16.sp),
              textAlign: TextAlign.center,
            ),
          ),

          /// Time
          AppText(
            text: widget.time,
            style: textStyle16SemiBold.copyWith(fontSize: 16.sp),
          ),

          Spacer(),

          CustomSwitchButton(
            initialValue: isOn,
            onChanged: (v) {
              setState(() => isOn = v);
              widget.onChanged(v);
            },
          ),
        ],
      ),
    );
  }
}
