import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';

class GuideHomeScreen extends StatefulWidget {
  const GuideHomeScreen({super.key});

  @override
  State<GuideHomeScreen> createState() => _GuideHomeScreenState();
}

class _GuideHomeScreenState extends State<GuideHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 27.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                20.h.verticalSpace,
                _buildHeader(),
                12.h.verticalSpace,
                AppText(
                  text: "Guide Dashboard",
                  style: textStyle12semiBold.copyWith(
                    fontSize: 28.sp,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                16.h.verticalSpace,
                _buildStatsGrid(),
                16.h.verticalSpace,
                _buildQuickActions(),
                20.h.verticalSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          text: "Welcome, Guide!",
          style: textStyle14Regular.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.2),
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Icon(
                Icons.notifications_outlined,
                size: 20.sp,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              4.w.horizontalSpace,
              AppText(
                text: "3",
                style: textStyle12Regular.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12.w,
      crossAxisSpacing: 12.w,
      childAspectRatio: 1.4,
      children: [
        _buildStatCard(
          title: "Active Trips",
          value: "5",
          icon: Icons.flight_takeoff,
        ),
        _buildStatCard(
          title: "Total Travelers",
          value: "128",
          icon: Icons.people,
        ),
        _buildStatCard(
          title: "Upcoming Tours",
          value: "3",
          icon: Icons.calendar_today,
        ),
        _buildStatCard(title: "Messages", value: "24", icon: Icons.message),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20.sp,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          8.h.verticalSpace,
          AppText(
            text: title,
            style: textStyle12Regular.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          4.h.verticalSpace,
          AppText(
            text: value,
            style: textStyle32Bold.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 24.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(
          text: "Quick Actions",
          style: textStyle14Regular.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        12.h.verticalSpace,
        _buildActionButton(title: "Manage Trips", icon: Icons.directions),
        8.h.verticalSpace,
        _buildActionButton(title: "View Travelers", icon: Icons.group),
        8.h.verticalSpace,
        _buildActionButton(
          title: "Send Notifications",
          icon: Icons.notifications,
        ),
      ],
    );
  }

  Widget _buildActionButton({required String title, required IconData icon}) {
    return Container(
      height: 52.h,
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          16.w.horizontalSpace,
          Icon(
            icon,
            size: 20.sp,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          16.w.horizontalSpace,
          AppText(
            text: title,
            style: textStyle14Regular.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Spacer(),
          Icon(
            Icons.arrow_forward_ios,
            size: 16.sp,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          16.w.horizontalSpace,
        ],
      ),
    );
  }
}
