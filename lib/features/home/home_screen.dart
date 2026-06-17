import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';
import 'package:travel_app_abdelhamid/core/widgets/custom_header.dart';
import 'package:travel_app_abdelhamid/core/widgets/tab_button.dart';
import 'package:travel_app_abdelhamid/core/widgets/trip_card.dart';
import 'package:travel_app_abdelhamid/core/utils/server_media_url.dart';
import 'package:travel_app_abdelhamid/provider/home/home_provider.dart';
import 'package:travel_app_abdelhamid/provider/home/prayer_times_provider.dart';
import 'package:travel_app_abdelhamid/provider/profile/profile_provider.dart';
import 'package:travel_app_abdelhamid/routes/user_routes.dart';
import 'package:travel_app_abdelhamid/core/extensions/color_extensions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedTab = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<TripProvider>().fetchTrips();
        context.read<PrayerTimesProvider>().fetchPrayerTimes();
        context.read<ProfileProvider>().loadProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer2<TripProvider, PrayerTimesProvider>(
        builder: (context, provider, prayer, child) {
          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                27.h.verticalSpace,
                Consumer<ProfileProvider>(
                  builder: (context, profileProvider, _) {
                    final raw = profileProvider.profile?.profileImageRaw.trim();
                    final url = raw != null && raw.isNotEmpty
                        ? serverMediaUrl(raw)
                        : null;
                    return CustomHeaders(
                      profileImageUrl: url,
                      onNotificationTap: () {
                        context.pushNamed(
                          UserAppRoutes.notificationScreen.name,
                        );
                      },
                    );
                  },
                ),

                16.h.verticalSpace,
                Center(
                  child: AppText(
                    text: "My Trip".tr(),
                    style: textStyle12semiBold.copyWith(
                      fontSize: 28.sp,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                16.h.verticalSpace,
                GestureDetector(
                  onTap: () async {
                    await context.pushNamed(
                      UserAppRoutes.prayerTimesScreen.name,
                    );
                    if (!context.mounted) return;
                    await context
                        .read<PrayerTimesProvider>()
                        .fetchPrayerTimes();
                  },
                  child: Container(
                    height: 52.h,
                    margin: EdgeInsets.symmetric(horizontal: 27.w),
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
                        16.w.horizontalSpace,
                        AppText(
                          text: "Next Prayer".tr(),
                          style: textStyle14Regular.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        AppText(
                          text: "  :  ",
                          style: textStyle14Regular.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        if (prayer.showHomePrayerLoading)
                          SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          )
                        else ...[
                          Expanded(
                            child: AppText(
                              text: prayer.homePrayerLine,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textStyle14Regular.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          VerticalDivider(
                            indent: 12.w,
                            endIndent: 12.w,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.2),
                          ),
                          AppText(
                            text: prayer.homeCountdownLine,
                            style: textStyle14Regular.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                        8.w.horizontalSpace,
                        SvgIcon(
                          AppAssets.travel,
                          size: 24.w,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        8.w.horizontalSpace,
                      ],
                    ),
                  ),
                ),

                20.h.verticalSpace,

                /// Tabs
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 27.w),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(130.r),
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.tabColor
                          : AppColors.lightblueColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.setOpacity(0.2),
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CustomTabButton(
                          text: "Current".tr(),
                          index: 0,
                          selectedTab: selectedTab,
                          onTap: () => setState(() => selectedTab = 0),
                        ),
                        CustomTabButton(
                          text: "Past".tr(),
                          index: 1,
                          selectedTab: selectedTab,
                          onTap: () => setState(() => selectedTab = 1),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (provider.isLoading) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        );
                      }
                      final trips = selectedTab == 0
                          ? provider.upcomingTripList
                          : provider.tripList;
                      if (trips.isEmpty) {
                        return RefreshIndicator(
                          color: Theme.of(context).colorScheme.onSurface,
                          onRefresh: () async {
                            await provider.fetchTrips(showGlobalLoading: false);
                            if (context.mounted) {
                              await context
                                  .read<PrayerTimesProvider>()
                                  .fetchPrayerTimes();
                            }
                          },
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                              height: MediaQuery.sizeOf(context).height * 0.5,
                              child: Center(
                                child: AppText(
                                  text: selectedTab == 0
                                      ? "No Current Trips"
                                      : "No Past Trips",
                                  style: textStyle16SemiBold.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      return RefreshIndicator(
                        color: Theme.of(context).colorScheme.onSurface,
                        onRefresh: () async {
                          await provider.fetchTrips(showGlobalLoading: false);
                          if (context.mounted) {
                            await context
                                .read<PrayerTimesProvider>()
                                .fetchPrayerTimes();
                          }
                        },
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                            horizontal: 27.w,
                            vertical: 24.h,
                          ),
                          itemCount: trips.length,
                          itemBuilder: (context, index) {
                            final item = trips[index];
                            return TripCard(
                              image: item.image,
                              title: item.title,
                              location: item.location,
                              date: item.date,
                              status: item.status,
                              onTap: () {
                                provider.selectTrip(item);
                                context.pushNamed(
                                  UserAppRoutes.tripDetailsScreen.name,
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
