import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_button.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';
import 'package:travel_app_abdelhamid/core/widgets/feed_back_card.dart';
import 'package:travel_app_abdelhamid/core/widgets/network_image_with_shimmer.dart';
import 'package:travel_app_abdelhamid/core/widgets/packge_details_card.dart';
import 'package:travel_app_abdelhamid/features/home/widget/trip_details_shimmer.dart';
import 'package:travel_app_abdelhamid/provider/home/home_provider.dart';
import 'package:travel_app_abdelhamid/routes/user_routes.dart';
import 'package:travel_app_abdelhamid/provider/booking/trip_booking_provider.dart';

class TripDetailsScreen extends StatefulWidget {
  const TripDetailsScreen({super.key});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final trip = context.read<TripProvider>().selectedTrip;
      if (trip?.id == null) return;

      final booking = context.read<TripBookingProvider>();
      await booking.loadTripDetails(trip!.id!);
      if (!mounted) return;

      final details = booking.tripDetails;
      if (details != null) {
        // Keep home card status in sync with trip details API (e.g. "upcoming").
        context.read<TripProvider>().updateTripFromDetails(details);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();
    final bookingProvider = context.watch<TripBookingProvider>();
    final trip = tripProvider.selectedTrip;

    if (trip == null) {
      return Scaffold(
        body: Center(
          child: Text(
            "No Trip Selected".tr(),
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
      );
    }

    final details = bookingProvider.tripDetails;
    final display = details ?? trip;
    final isUpcoming = tripProvider.upcomingTripList.any(
      (item) => item.id != null && item.id == trip.id,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 15.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: SvgIcon(
                      AppAssets.backIcon,
                      size: 28.5.w,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  30.w.horizontalSpace,
                  Expanded(
                    child: AppText(
                      text: bookingProvider.isLoading
                          ? trip.title
                          : display.title,
                      overflow: TextOverflow.ellipsis,
                      style: textStyle32Bold.copyWith(
                        fontSize: 26.sp,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: bookingProvider.isLoading
                  ? TripDetailsShimmer(showPackages: isUpcoming)
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          NetworkImageWithShimmer(
                            imageUrl: display.imageUrl.replaceAll(
                              "//uploads",
                              "/uploads",
                            ),
                            height: 250.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 11.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                12.h.verticalSpace,

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: AppText(
                                        text: display.title,
                                        style: textStyle16SemiBold.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    if (display.status.trim().isNotEmpty) ...[
                                      12.w.horizontalSpace,
                                      statusTag(display.status),
                                    ],
                                  ],
                                ),

                                14.h.verticalSpace,

                                Row(
                                  children: [
                                    SvgIcon(
                                      AppAssets.pin,
                                      size: 22.w,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                    14.w.horizontalSpace,
                                    Expanded(
                                      child: AppText(
                                        text: display.location,
                                        style: textStyle14Regular.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    12.w.horizontalSpace,
                                    SvgIcon(
                                      AppAssets.calendar,
                                      size: 22.w,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                    14.w.horizontalSpace,
                                    AppText(
                                      text: display.date,
                                      style: textStyle14Regular.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),

                                18.h.verticalSpace,
                                sectionTitle("About Us".tr()),
                                // 2.h.verticalSpace,
                                ReadMoreText(
                                  display.description,
                                  trimLines: 3,
                                  colorClickableText: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  trimMode: TrimMode.Line,
                                  trimCollapsedText: 'Read more'.tr(),
                                  trimExpandedText: ' Read less'.tr(),
                                  style: textStyle14Regular.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                  moreStyle: textStyle14Medium.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  lessStyle: textStyle14Medium.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                                18.h.verticalSpace,
                                if (isUpcoming) ...[
                                  AppText(
                                    text: "Package Details".tr(),
                                    style: textStyle16SemiBold.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                  // Map existing cards to real data if packages exist
                                  if (details?.packages != null &&
                                      details!.packages!.isNotEmpty)
                                    ...details.packages!.map(
                                      (package) => PackageDetailsCard(
                                        package: package,
                                        isSelected:
                                            bookingProvider
                                                .selectedPackage
                                                ?.id ==
                                            package.id,
                                        onTap: () => bookingProvider
                                            .selectPackage(package),
                                      ),
                                    )
                                  else if (details != null)
                                    AppText(
                                      text:
                                          'No packages available for this trip.'
                                              .tr(),
                                      style: textStyle14Regular.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                    ),

                                  AppText(
                                    text: "Note:".tr(),
                                    style: textStyle16SemiBold.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                  8.h.verticalSpace,
                                  AppText(
                                    text:
                                        "Prices may vary depending on airline & hotel:"
                                            .tr(),
                                    style: textStyle14Regular.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                  42.h.verticalSpace,
                                  AppButton(
                                    title: bookingProvider.isBooked
                                        ? 'Continue to Room Type'.tr()
                                        : 'Select Package & Room Type'.tr(),
                                    isLoading: bookingProvider.isLoading,
                                    onTap: () async {
                                      final success = await bookingProvider
                                          .proceedToRoomSelection();

                                      if (!context.mounted) return;

                                      if (success) {
                                        context.pushNamed(
                                          UserAppRoutes.roomDetailScren.name,
                                        );
                                      }
                                    },
                                  ),
                                  42.h.verticalSpace,
                                ],

                                // Past Trip Section
                                if (!isUpcoming) ...[
                                  simpleCard(
                                    title: "Payment Summary".tr(),
                                    rows: [
                                      rowItem(
                                        "Package Cost".tr(),
                                        details?.packages?.isNotEmpty ?? false
                                            ? details!
                                                  .packages!
                                                  .first
                                                  .roomOptions
                                                  .first
                                            : "\$2,500",
                                      ),
                                      rowItem("Status".tr(), "Paid".tr()),
                                    ],
                                  ),
                                  20.h.verticalSpace,
                                  if (tripProvider.reviewSubmitted) ...[
                                    FeedbackReviewCard(),
                                    20.h.verticalSpace,
                                  ],
                                  simpleCard(
                                    rows: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          AppText(
                                            text: "Support Contact".tr(),
                                            style: textStyle16SemiBold.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                            ),
                                          ),
                                          SvgIcon(
                                            AppAssets.phone,
                                            size: 24.w,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  42.h.verticalSpace,
                                  AppButton(
                                    title: tripProvider.reviewSubmitted
                                        ? "Share on Google Review".tr()
                                        : "Share on Review".tr(),
                                    onTap: () => context.pushNamed(
                                      UserAppRoutes.feedbackScreen.name,
                                    ),
                                  ),
                                  40.h.verticalSpace,
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: AppText(
        text: text,
        style: textStyle16SemiBold.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget rowItem(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            text: title,
            style: textStyle14Regular.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          AppText(
            text: value,
            style: textStyle14Regular.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget statusTag(String status) {
    final raw = status.trim();
    if (raw.isEmpty) return const SizedBox.shrink();

    final color = _statusColor(raw);
    final label = _statusLabel(raw);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          8.w.horizontalSpace,
          AppText(
            text: label,
            style: textStyle14Medium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    final lower = status.toLowerCase();
    if (lower.isEmpty) return status;
    return lower[0].toUpperCase() + lower.substring(1);
  }

  Color _statusColor(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('upcoming')) return AppColors.secondary;
    if (lower.contains('ongoing') || lower.contains('active')) {
      return AppColors.blueColor;
    }
    if (lower.contains('complete') ||
        lower.contains('completed') ||
        lower.contains('past') ||
        lower.contains('done')) {
      return const Color(0xFF2E7D32);
    }
    if (lower.contains('cancel')) return AppColors.redColor;
    return AppColors.blueColor;
  }

  Widget simpleCard({String? title, required List<Widget> rows}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: AppText(
                text: title,
                style: textStyle16SemiBold.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ...rows,
        ],
      ),
    );
  }
}
