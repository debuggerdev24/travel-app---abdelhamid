import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/core/widgets/custom_switch_button.dart';
import 'package:trael_app_abdelhamid/provider/home/prayer_times_provider.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<PrayerTimesProvider>().fetchPrayerTimes();
    });
  }

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

              Expanded(
                child: Consumer<PrayerTimesProvider>(
                  builder: (context, prayer, _) {
                    if (prayer.isLoading && prayer.items.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      );
                    }
                    if (prayer.error != null && prayer.items.isEmpty) {
                      return Center(
                        child: AppText(
                          textAlign: TextAlign.center,
                          text:
                              'Could not load prayer times. Pull to refresh from home or try again later.',
                          style: textStyle14Regular.copyWith(
                            color: AppColors.primaryColor.setOpacity(0.8),
                          ),
                        ),
                      );
                    }
                    if (prayer.items.isEmpty) {
                      return Center(
                        child: AppText(
                          textAlign: TextAlign.center,
                          text:
                              'No prayer times have been set yet. They can be added from the admin panel.',
                          style: textStyle14Regular.copyWith(
                            color: AppColors.primaryColor.setOpacity(0.8),
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: prayer.items.length,
                      itemBuilder: (context, index) {
                        final p = prayer.items[index];
                        return PrayerTile(
                          prayer: p.name,
                          time: p.time,
                          initialValue: false,
                          onChanged: (_) {},
                        );
                      },
                    );
                  },
                ),
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 65.w,
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

          AppText(
            text: widget.time,
            style: textStyle16SemiBold.copyWith(fontSize: 16.sp),
          ),

          const Spacer(),

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
