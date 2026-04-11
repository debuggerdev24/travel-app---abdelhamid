import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/core/widgets/custom_header.dart';
import 'package:trael_app_abdelhamid/core/widgets/tab_button.dart';
import 'package:trael_app_abdelhamid/core/widgets/trip_card.dart';
import 'package:trael_app_abdelhamid/provider/home/home_provider.dart';
import 'package:trael_app_abdelhamid/provider/home/prayer_times_provider.dart';
import 'package:trael_app_abdelhamid/routes/user_routes.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';

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
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer2<TripProvider, PrayerTimesProvider>(
        builder: (context, provider, prayer, child) {
          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                27.h.verticalSpace,
                CustomHeaders(image: AppAssets.profilePhoto),

                16.h.verticalSpace,
                Center(
                  child: AppText(
                    text: "My Trip",
                    style: textStyle12semiBold.copyWith(
                      fontSize: 28.sp,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                if (selectedTab == 0) 16.h.verticalSpace,
                if (selectedTab == 0)
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
                          color: AppColors.primaryColor.setOpacity(0.2),
                        ),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          16.w.horizontalSpace,
                          AppText(
                            text: "Next Prayer",
                            style: textStyle14Regular.copyWith(
                              color: AppColors.primaryColor.setOpacity(0.6),
                            ),
                          ),
                          AppText(
                            text: "  :  ",
                            style: textStyle14Regular.copyWith(
                              color: AppColors.primaryColor.setOpacity(0.6),
                            ),
                          ),
                          if (prayer.showHomePrayerLoading)
                            SizedBox(
                              width: 18.w,
                              height: 18.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryColor,
                              ),
                            )
                          else ...[
                            Expanded(
                              child: AppText(
                                text: prayer.homePrayerLine,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textStyle14Regular.copyWith(
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                            VerticalDivider(
                              indent: 12.w,
                              endIndent: 12.w,
                              color: AppColors.primaryColor.setOpacity(0.2),
                            ),
                            AppText(
                              text: prayer.homeCountdownLine,
                              style: textStyle14Regular.copyWith(
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ],
                          8.w.horizontalSpace,
                          SvgIcon(AppAssets.travel, size: 24.w),
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
                      color: AppColors.lightblueColor,
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
                          text: "Current",
                          index: 0,
                          selectedTab: selectedTab,
                          onTap: () => setState(() => selectedTab = 0),
                        ),
                        CustomTabButton(
                          text: "Past",
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
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          ),
                        );
                      }
                      final trips = selectedTab == 0
                          ? provider.upcomingTripList
                          : provider.tripList;
                      if (trips.isEmpty) {
                        return RefreshIndicator(
                          color: AppColors.primaryColor,
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
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      return RefreshIndicator(
                        color: AppColors.primaryColor,
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
