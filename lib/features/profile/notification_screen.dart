import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';

class NotificationModel {
  final String title;
  final String message;
  final String time;
  final String icon;
  final bool isPremium;
  final bool isRead;

  NotificationModel({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.isPremium,
    this.isRead = false,
  });
}

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                      child: SvgIcon(
                        AppAssets.backIcon,
                        size: 28.5,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  AppText(
                    text: "Notifications",
                    style: textStyle32Bold.copyWith(
                      fontSize: 26.sp,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              30.h.verticalSpace,
              Expanded(
                child: ListView(
                  children: [
                    _buildPremiumNotificationCard(
                      context,
                      notification: NotificationModel(
                        title: "Premium Feature Unlocked",
                        message:
                            "You now have access to exclusive travel deals and discounts!",
                        time: "2 hours ago",
                        icon: AppAssets.travel,
                        isPremium: true,
                        isRead: false,
                      ),
                    ),
                    16.h.verticalSpace,
                    _buildPremiumNotificationCard(
                      context,
                      notification: NotificationModel(
                        title: "Trip Reminder",
                        message:
                            "Your trip to Mecca starts in 3 days. Don't forget to pack!",
                        time: "5 hours ago",
                        icon: AppAssets.alarm,
                        isPremium: true,
                        isRead: false,
                      ),
                    ),
                    16.h.verticalSpace,
                    _buildPremiumNotificationCard(
                      context,
                      notification: NotificationModel(
                        title: "Special Offer",
                        message:
                            "Get 20% off on hotel bookings with code: TRAVEL20",
                        time: "1 day ago",
                        icon: AppAssets.cash,
                        isPremium: true,
                        isRead: true,
                      ),
                    ),
                    16.h.verticalSpace,
                    _buildPremiumNotificationCard(
                      context,
                      notification: NotificationModel(
                        title: "Prayer Time Alert",
                        message: "Maghrib prayer is in 30 minutes",
                        time: "2 days ago",
                        icon: AppAssets.alarm,
                        isPremium: false,
                        isRead: true,
                      ),
                    ),
                    16.h.verticalSpace,
                    _buildPremiumNotificationCard(
                      context,
                      notification: NotificationModel(
                        title: "Payment Successful",
                        message:
                            "Your payment of \$500 has been processed successfully",
                        time: "3 days ago",
                        icon: AppAssets.cash,
                        isPremium: false,
                        isRead: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumNotificationCard(
    BuildContext context, {
    required NotificationModel notification,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        gradient: notification.isPremium
            ? LinearGradient(
                colors: [
                  AppColors.blueColor.withValues(alpha: 0.1),
                  AppColors.blueColor.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        border: Border.all(
          color: notification.isPremium
              ? AppColors.blueColor.withValues(alpha: 0.3)
              : Theme.of(context).colorScheme.outlineVariant,
          width: notification.isPremium ? 1.5.w : 1.w,
        ),
        color: notification.isPremium
            ? null
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: notification.isPremium
                ? AppColors.blueColor.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: notification.isPremium ? 12 : 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 48.h,
            width: 48.w,
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              gradient: notification.isPremium
                  ? LinearGradient(
                      colors: [
                        AppColors.blueColor,
                        AppColors.blueColor.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: notification.isPremium
                  ? null
                  : Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: SvgIcon(
              notification.icon,
              size: 24.sp,
              color: notification.isPremium
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
          16.w.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: AppText(
                        text: notification.title,
                        style: textStyle16SemiBold.copyWith(
                          fontSize: 16.sp,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: notification.isRead
                              ? FontWeight.w400
                              : FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (notification.isPremium) ...[
                      8.w.horizontalSpace,
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.blueColor,
                              AppColors.blueColor.withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: AppText(
                          text: "PREMIUM",
                          style: textStyle10Regular.copyWith(
                            fontSize: 10.sp,
                            color: Colors.white,
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    if (!notification.isRead) ...[
                      8.w.horizontalSpace,
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color: AppColors.blueColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                6.h.verticalSpace,
                AppText(
                  text: notification.message,
                  style: textStyle14Regular.copyWith(
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.onSurface.withValues(
                      alpha: notification.isRead ? 0.5 : 0.7,
                    ),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                8.h.verticalSpace,
                AppText(
                  text: notification.time,
                  style: textStyle12Regular.copyWith(
                    fontSize: 12.sp,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
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
