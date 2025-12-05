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
import 'package:trael_app_abdelhamid/routes/user_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<TripProvider>(
        builder: (context, provider, child) {
          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                27.h.verticalSpace,
                CustomHeaders(image: AppAssets.profilephoto),

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
                Container(
                  height: 52.h,
                  margin: EdgeInsets.symmetric(horizontal: 27.w),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.2),
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      22.w.horizontalSpace,
                      AppText(
                        text: "Next Prayer",
                        style: textStyle14Regular.copyWith(
                          color: AppColors.primaryColor.withOpacity(0.6),
                        ),
                      ),

                      AppText(
                        text: "  :  ",
                        style: textStyle14Regular.copyWith(
                          color: AppColors.primaryColor.withOpacity(0.6),
                        ),
                      ),
                      AppText(
                        text: "Dhuhr 12:30 PM",
                        style: textStyle14Regular.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                      VerticalDivider(indent: 12.w, endIndent: 12.w),
                      AppText(
                        text: "1h 50m",
                        style: textStyle14Regular.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                      12.w.horizontalSpace,
                      SvgIcon(AppAssets.travel, size: 24.w),
                    ],
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
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CustomTabButton(
                          text: "Upcoming",
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
                      final trips = selectedTab == 0
                          ? provider.upcomingtripList
                          : provider.tripList;
                      if (trips.isEmpty) {
                        return Center(
                          child: AppText(
                            text: selectedTab == 0
                                ? "No Upcoming Trips"
                                : "No Past Trips",
                            style: textStyle16SemiBold.copyWith(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
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
