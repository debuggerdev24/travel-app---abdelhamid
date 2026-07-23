import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';
import 'package:travel_app_abdelhamid/model/profile/app_notification_model.dart';
import 'package:travel_app_abdelhamid/provider/profile/notification_provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

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
                    text: "Notifications".tr(),
                    style: textStyle32Bold.copyWith(
                      fontSize: 26.sp,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              30.h.verticalSpace,
              Expanded(
                child: Consumer<NotificationProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading && provider.notifications.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (provider.notifications.isEmpty) {
                      return Center(
                        child: AppText(
                          text: "No notifications yet".tr(),
                          style: textStyle16Regular.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        await provider.fetchNotifications();
                      },
                      child: ListView.separated(
                        itemCount: provider.notifications.length,
                        separatorBuilder: (context, index) => 16.h.verticalSpace,
                        itemBuilder: (context, index) {
                          final notification = provider.notifications[index];
                          return GestureDetector(
                            onTap: () {
                              if (!notification.isRead) {
                                provider.markAsRead(notification.id);
                              }
                            },
                            child: _buildNotificationCard(
                              context,
                              notification: notification,
                            ),
                          );
                        },
                      ),
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

  Widget _buildNotificationCard(
    BuildContext context, {
    required AppNotificationModel notification,
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
              notification.icon ?? AppAssets.alarm, // Fallback to a default icon
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
                          text: "PREMIUM".tr(),
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
                        decoration: const BoxDecoration(
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
                if (notification.time != null && notification.time!.isNotEmpty) ...[
                  8.h.verticalSpace,
                  AppText(
                    text: notification.time!,
                    style: textStyle12Regular.copyWith(
                      fontSize: 12.sp,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
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
}
