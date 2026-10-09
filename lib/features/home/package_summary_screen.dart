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
            'You have unsaved booking data. Do you want to discard it and go back?'
                .tr(),
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (!mounted || !shouldPop) return;
        context.pop();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              /// ---------------- HEADER ----------------
              18.h.verticalSpace,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 11.w),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: SvgIcon(
                          AppAssets.backIcon,
                          size: 26.w,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
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
                padding: EdgeInsets.fromLTRB(11.w, 16.h, 11.w, 10.h),
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
                  padding: EdgeInsets.symmetric(horizontal: 11.w),
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

                      // Dynamically calculate values from provider
                      Builder(
                        builder: (context) {
                          double roomPrice = 0;
                          if (provider.selectedRoomTypeId != null &&
                              selectedPackage != null) {
                            try {
                              roomPrice = selectedPackage.roomDetails
                                  .firstWhere(
                                    (r) => r.id == provider.selectedRoomTypeId,
                                  )
                                  .roomPrice;
                            } catch (_) {}
                          }

                          double childPrice = 0;
                          if (provider.selectedChildDetailsId != null &&
                              selectedPackage != null) {
                            try {
                              childPrice = selectedPackage.childDetails
                                  .firstWhere(
                                    (c) =>
                                        c.id == provider.selectedChildDetailsId,
                                  )
                                  .childPrice;
                            } catch (_) {}
                          }

                          double adultTotal = roomPrice * provider.adultCount;
                          double childTotal =
                              childPrice * provider.selectedChildCount;
                          double babyTotal = 500.0 * provider.babyCount;

                          return Column(
                            children: [
                              if (provider.adultCount > 0)
                                _priceRow(
                                  "${provider.adultCount} ${'Person (Adult)'.tr()}",
                                  "€${adultTotal.toStringAsFixed(0)}",
                                ),
                              if (provider.selectedChildCount > 0)
                                _priceRow(
                                  "${provider.selectedChildCount} ${'Child'.tr()}",
                                  "€${childTotal.toStringAsFixed(0)}",
                                ),
                              if (provider.babyCount > 0)
                                _priceRow(
                                  "${provider.babyCount} ${'Baby'.tr()}",
                                  "€${babyTotal.toStringAsFixed(0)}",
                                ),
                            ],
                          );
                        },
                      ),

                      Divider(
                        height: 28.h,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.2),
                      ),
                      _priceRow(
                        "TOTAL COST".tr(),
                        "€${provider.totalAmount.toStringAsFixed(0)}",
                      ),
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
    if (items.isEmpty) return const SizedBox.shrink();

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
          ...items.map(_sectionItem),
        ],
      ),
    );
  }

  Widget _sectionItem(String text) {
    final parts = text.split(' - ');
    final price = parts.length > 1 ? parts.last.trim() : '';
    final hasPrice = price.startsWith('€');
    final label = hasPrice
        ? parts.sublist(0, parts.length - 1).join(' - ')
        : text;

    return Padding(
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
              text: label,
              style: textStyle14Regular.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          if (hasPrice) ...[
            8.w.horizontalSpace,
            AppText(
              text: _wholeEuro(price),
              style: textStyle14Medium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _wholeEuro(String price) {
    final number = double.tryParse(price.replaceFirst('€', '').trim());
    if (number == null) return price;
    if (number == number.roundToDouble()) {
      return '€${number.toInt()}';
    }
    return '€${number.toStringAsFixed(1)}';
  }

  /// Price row
  Widget _priceRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Expanded(
            child: AppText(
              text: '$title:',
              maxLines: 2,
              style: textStyle14Medium.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          12.w.horizontalSpace,
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
