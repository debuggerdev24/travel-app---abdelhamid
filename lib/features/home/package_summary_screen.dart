import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_button.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';
import 'package:travel_app_abdelhamid/provider/booking/trip_booking_provider.dart';
import 'package:travel_app_abdelhamid/routes/user_routes.dart';

class PackageSummaryScreen extends StatefulWidget {
  const PackageSummaryScreen({super.key});

  @override
  State<PackageSummaryScreen> createState() => _PackageSummaryScreenState();
}

class _PackageSummaryScreenState extends State<PackageSummaryScreen> {
  /// Show confirmation dialog when user tries to go back with unsaved data
  Future<bool> _onWillPop() async {
    final tripBookingProvider = context.read<TripBookingProvider>();
    if (tripBookingProvider.hasAnyUnsavedData) {
      final shouldPop = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Discard unsaved data?'.tr()),
          content: Text(
            'You have unsaved booking data. Do you want to discard it and go back?'.tr(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'.tr()),
            ),
            TextButton(
              onPressed: () {
                tripBookingProvider.clearLocalData();
                Navigator.pop(context, true);
              },
              child: Text('Discard'.tr()),
            ),
          ],
        ),
      );
      return shouldPop ?? false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TripBookingProvider>();
      final tripId = provider.tripDetails?.id;

      debugPrint('✅ [PackageSummaryScreen] initState called');
      debugPrint('🔵 [PackageSummaryScreen] tripId: $tripId');

      // Only fetch package options from backend if no package is selected locally
      // With the new flow, package is stored locally until payment
      if (provider.selectedPackage == null &&
          tripId != null &&
          tripId.isNotEmpty) {
        debugPrint('🔵 [PackageSummaryScreen] Fetching package options...');
        provider.fetchPackageOptions(tripId);
      } else if (provider.selectedPackage != null) {
        debugPrint(
          '🔵 [PackageSummaryScreen] Package already selected locally',
        );
      } else {
        debugPrint(
          '❌ [PackageSummaryScreen] tripId is null — cannot fetch package options',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TripBookingProvider>();
    final trip = provider.tripDetails;
    final selectedPackage = provider.selectedPackage;

    debugPrint(
      '🔵 [PackageSummaryScreen] build — isLoading: ${provider.isLoading}',
    );
    debugPrint(
      '🔵 [PackageSummaryScreen] selectedPackage: ${selectedPackage?.title}',
    );
    debugPrint(
      '🔵 [PackageSummaryScreen] roomOptions: ${selectedPackage?.roomOptions}',
    );
    debugPrint(
      '🔵 [PackageSummaryScreen] childPrices: ${selectedPackage?.childPrices}',
    );
    debugPrint(
      '🔵 [PackageSummaryScreen] inclusions: ${selectedPackage?.inclusions}',
    );
    debugPrint(
      '🔵 [PackageSummaryScreen] exclusions: ${selectedPackage?.exclusions}',
    );

    if (trip == null) {
      return Scaffold(body: Center(child: Text("No Trip Selected".tr())));
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              /// ---------------- HEADER ----------------
              40.h.verticalSpace,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: SvgIcon(AppAssets.backIcon, size: 26.w, color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ),
                    AppText(
                      text: "Umrah Trip 2025".tr(),
                      style: textStyle32Bold.copyWith(
                        fontSize: 26.sp,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),

              /// Travel details
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 32.h),
                child: Row(
                  children: [
                    SvgIcon(
                      AppAssets.pin,
                      size: 20.w,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    10.w.horizontalSpace,
                    Expanded(
                      child: AppText(
                        text: trip.location,
                        style: textStyle14Regular.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    SvgIcon(
                      AppAssets.calendar,
                      size: 20.w,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    10.w.horizontalSpace,
                    AppText(
                      text: trip.date,
                      style: textStyle14Regular.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),

              /// ------------- MAIN CONTENT LIST ---------------
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      10.h.verticalSpace,

                      /// Selected Package Card
                      if (selectedPackage != null)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.shadow.withValues(alpha: 0.1),
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            color: Theme.of(context).colorScheme.surface,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                text: selectedPackage.title,
                                style: textStyle16SemiBold.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  fontSize: 17.sp,
                                ),
                              ),
                              _buildSection(
                                title: 'Room Options :'.tr(),
                                items: selectedPackage.roomOptions,
                              ),
                              _buildSection(
                                title: 'Child Prices :'.tr(),
                                items: selectedPackage.childPrices,
                              ),
                              _buildSection(
                                title: 'Inclusions :'.tr(),
                                items: selectedPackage.inclusions,
                              ),
                              _buildSection(
                                title: 'Exclusions :'.tr(),
                                items: selectedPackage.exclusions,
                              ),
                            ],
                          ),
                        ),

                      20.h.verticalSpace,

                      _priceRow("2 Person (Adult)".tr(), "€7,000"),
                      _priceRow("2 Child".tr(), "€2500"),
                      _priceRow("1 Baby".tr(), "€500"),

                      Divider(
                        height: 30.h,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.2),
                        endIndent: 60,
                      ),
                      _priceRow("TOTAL COST".tr(), "€10,000"),
                      52.h.verticalSpace,
                      AppButton(
                        onTap: () {
                          debugPrint(
                            '🔵 [PackageSummaryScreen] Book Now tapped',
                          );
                          context.pushNamed(
                            UserAppRoutes.paymentOptionScreen.name,
                          );
                        },
                        title: "Book Now".tr(),
                      ),
                      46.h.verticalSpace,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build Section (Room Options / Inclusions etc.)
  Widget _buildSection({required String title, required List<String> items}) {
    return Padding(
      padding: EdgeInsets.only(top: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: title,
            style: textStyle14Medium.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          8.h.verticalSpace,
          ...items.map(
            (e) => Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 4.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface,
                      shape: BoxShape.circle,
                    ),
                  ),
                  12.w.horizontalSpace,
                  Expanded(
                    child: AppText(
                      text: e,
                      style: textStyle14Regular.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Price row
  Widget _priceRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 140.w,
            child: AppText(
              text: title,
              style: textStyle14Medium.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          AppText(
            text: ":",
            style: textStyle14Medium.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          30.w.horizontalSpace,
          AppText(
            text: value,
            style: textStyle14Medium.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
