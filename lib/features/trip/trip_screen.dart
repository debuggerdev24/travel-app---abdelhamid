import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_button.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_chip.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/core/widgets/details_card.dart';
import 'package:trael_app_abdelhamid/core/widgets/document_card.dart';
import 'package:trael_app_abdelhamid/core/widgets/itinerarystep_card.dart';
import 'package:trael_app_abdelhamid/core/utils/document_download_helper.dart';
import 'package:trael_app_abdelhamid/core/utils/trip_detail_refresh.dart';
import 'package:trael_app_abdelhamid/core/utils/server_media_url.dart';
import 'package:trael_app_abdelhamid/model/home/trip_model.dart';
import 'package:trael_app_abdelhamid/model/home/hotel_voucher_model.dart';
import 'package:trael_app_abdelhamid/model/trip/trip_documents_bundle_model.dart';
import 'package:trael_app_abdelhamid/provider/home/home_provider.dart';
import 'package:trael_app_abdelhamid/provider/home/user_flight_provider.dart';
import 'package:trael_app_abdelhamid/provider/trip/my_trip_provider.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:trael_app_abdelhamid/core/extensions/routes_extensions.dart';
import 'package:trael_app_abdelhamid/routes/user_routes.dart';
import 'package:url_launcher/url_launcher.dart';

class TripScreen extends StatefulWidget {
  const TripScreen({super.key});

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  String selectedMethod = "Credit/Debit Card";
  int selectedIndex = 0;

  /// Last trip id we ran [refreshAllTripScopedData] for (avoids duplicate work).
  String? _lastRefreshedTripId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await context.read<TripProvider>().ensureSelectedTripFromUpcoming();
    });
  }

  void _scheduleRefreshIfTripChanged(String? tripId) {
    if (tripId == null || tripId.isEmpty) {
      _lastRefreshedTripId = null;
      return;
    }
    if (tripId == _lastRefreshedTripId) return;
    _lastRefreshedTripId = tripId;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final current = context.read<TripProvider>().selectedTrip?.id;
      if (current != tripId) return;
      await refreshAllTripScopedData(context, tripId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();
    final trip = tripProvider.selectedTrip;

    _scheduleRefreshIfTripChanged(trip?.id);

    return Consumer<MyTripProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  10.h.verticalSpace,
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 27.w,
                      vertical: 10.h,
                    ),
                    child: Center(
                      child: AppText(
                        text: trip?.title ?? "",
                        style: textStyle32Bold.copyWith(
                          fontSize: 26.sp,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ),
                  if (trip != null)
                    trip.image.startsWith('assets')
                        ? Image.asset(
                            trip.image,
                            height: 250.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            trip.imageUrl,
                            height: 250.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  height: 250.h,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.broken_image),
                                ),
                          ),

                  // Trip title and location
                  12.h.verticalSpace,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 27.w),
                    child: AppText(
                      text: trip?.title ?? "-",
                      style: textStyle16SemiBold,
                    ),
                  ),
                  14.h.verticalSpace,
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 27.w,
                      vertical: 2.h,
                    ),
                    child: Row(
                      children: [
                        SvgIcon(AppAssets.pin, size: 22.w),
                        14.w.horizontalSpace,
                        Expanded(
                          child: AppText(
                            text: trip?.location ?? "-",
                            style: textStyle14Regular.copyWith(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                        12.w.horizontalSpace,
                        SvgIcon(AppAssets.calendar, size: 22.w),
                        14.w.horizontalSpace,
                        AppText(
                          text: trip?.date ?? "-",
                          style: textStyle14Regular.copyWith(
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  10.h.verticalSpace,

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 19.w,
                        vertical: 10.h,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildTab("Payment", AppAssets.payment, 0),
                          _buildTab("Flights", AppAssets.flight, 1),
                          _buildTab("Hotels", AppAssets.hotel, 2),
                          _buildTab("Itinerary", AppAssets.itinerary, 3),
                          _buildTab("Essentials", AppAssets.essential, 4),
                          _buildTab("Documents", AppAssets.document, 5),
                        ],
                      ),
                    ),
                  ),

                  // Show section based on selected tab
                  _getSelectedSection(provider),

                  // Proceed Button (optional, only for Payment maybe)
                  // if (selectedIndex == 0)
                  //   Padding(
                  //     padding: EdgeInsets.symmetric(
                  //       horizontal: 27.w,
                  //       vertical: 20.h,
                  //     ),
                  //     child: AppButton(title: "Proceed to Pay"),
                  //   ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTab(String title, String icon, int index) {
    return AppChip(
      isSelected: selectedIndex == index,
      title: title,
      icon: icon,
      onTap: () {
        setState(() {
          selectedIndex = index;
        });

        // Refetch APIs whenever the user selects these tabs (fresh data each visit).
        if (index == 1) {
          final tripProvider = context.read<TripProvider>();
          final tripId = tripProvider.selectedTrip?.id;
          if (tripId != null && tripId.isNotEmpty) {
            context.read<FlightProvider>().fetchMyFlights(tripId, force: true);
          }
        } else if (index == 2) {
          final tripProvider = context.read<TripProvider>();
          final tripId = tripProvider.selectedTrip?.id;
          if (tripId != null && tripId.isNotEmpty) {
            tripProvider.fetchHotelVoucherDetails(tripId, force: true);
          }
        } else if (index == 3) {
          final tripProvider = context.read<TripProvider>();
          final tripId = tripProvider.selectedTrip?.id;
          if (tripId != null && tripId.isNotEmpty) {
            tripProvider.fetchTodayItinerary(tripId, force: true);
          }
        } else if (index == 4) {
          context.read<MyTripProvider>().refreshEssentialsTab();
        } else if (index == 5) {
          final tripProvider = context.read<TripProvider>();
          final tripId = tripProvider.selectedTrip?.id;
          if (tripId != null && tripId.isNotEmpty) {
            tripProvider.fetchHotelVoucherDetails(tripId, force: true);
            context.read<MyTripProvider>().refreshDocumentsTab(tripId);
          }
        }
      },
    );
  }

  Widget _getSelectedSection(MyTripProvider provider) {
    switch (selectedIndex) {
      case 0:
        return _paymentSection(provider);
      case 1:
        return _flightsSection();
      case 2:
        return _hotelsSection();
      case 3:
        return _itinerarySection();
      case 4:
        return _essentialsSection();
      case 5:
        return _documentsSection();
      default:
        return SizedBox.shrink();
    }
  }

  Widget _paymentSection(MyTripProvider provider) {
    final tripProvider = context.read<TripProvider>();
    final payment = tripProvider.paymentDetails;
    final isPaymentLoading = tripProvider.isPaymentLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.setOpacity(0.2),
                  blurRadius: 1,
                  offset: Offset(0, 1),
                ),
              ],
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.primaryColor.setOpacity(0.2)),
            ),
            child: isPaymentLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: payment?.packageName ?? '-',
                        style: textStyle14Regular.copyWith(
                          color: AppColors.primaryColor.setOpacity(0.8),
                          fontSize: 14.sp,
                        ),
                      ),
                      12.h.verticalSpace,
                      _priceRow(
                        "Total",
                        "€${payment?.totalAmount.toStringAsFixed(0) ?? '-'}",
                      ),
                      4.h.verticalSpace,
                      _priceRow(
                        "Paid",
                        "€${payment?.paidAmount.toStringAsFixed(0) ?? '-'}",
                      ),
                      4.h.verticalSpace,
                      _priceRow(
                        "Pending",
                        "€${payment?.pendingAmount.toStringAsFixed(0) ?? '-'}",
                      ),
                    ],
                  ),
            // child: Column(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     // AppText(
            //     //   text: "Premium Package",
            //     //   style: textStyle14Regular.copyWith(
            //     //     color: AppColors.primaryColor.setOpacity(0.8),
            //     //     fontSize: 14.sp,
            //     //   ),
            //     // ),
            //     // 12.h.verticalSpace,
            //     // _priceRow("Total", "€10,000"),
            //     // 4.h.verticalSpace,
            //     // _priceRow("Paid", "€5,000"),
            //     // 4.h.verticalSpace,
            //     // _priceRow("Pending", "€5,000"),
            //   ],
            // ),
          ),
        ),

        // Past Payments
        // Padding(
        //   padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 10.h),
        //   child: Row(
        //     children: [
        //       AppText(text: "Past Payment", style: textStyle16SemiBold),
        //       Spacer(),
        //       GestureDetector(
        //         onTap: () =>
        //             context.pushNamed(UserAppRoutes.paymentHistoryScreen.name),
        //         child: AppText(
        //           text: "View All",
        //           style: textStyle16SemiBold.copyWith(
        //             color: AppColors.blueColor,
        //             fontSize: 14.sp,
        //             decoration: TextDecoration.underline,
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        // PastPaymentItem(
        //   id: "#TRX001",
        //   amount: "250,000",
        //   date: "02 Jan 2024",
        //   onViewReceiptTap: () {},
        // ),
        // PastPaymentItem(
        //   id: "#TRX002",
        //   amount: "250,000",
        //   date: "22 Dec 2024",
        //   onViewReceiptTap: () {},
        // ),
        // PastPaymentItem(
        //   id: "#TRX003",
        //   amount: "250,000",
        //   date: "31 May 2023",
        //   onViewReceiptTap: () {},
        // ),
      ],
    );
  }

  Widget _flightsSection() {
    final flightProvider = context.read<FlightProvider>();
    // final tripId = context.read<TripProvider>().selectedTrip?.id;
    // final tripId = context.read<TripBookingProvider>().tripDetails?.id;
    final tripId = context.read<TripProvider>().selectedTrip?.id;
    debugPrint(
      '🔵 [TripScreen] selectedTrip: ${context.read<TripProvider>().selectedTrip?.id}',
    );
    debugPrint(
      '🔵 [TripScreen] selectedTrip title: ${context.read<TripProvider>().selectedTrip?.title}',
    );
    // First visit / edge cases: load once if still empty (tab tap uses force refresh).
    if (flightProvider.flightDetails == null && !flightProvider.isLoading) {
      if (tripId != null && tripId.isNotEmpty) {
        debugPrint('🔵 [TripScreen] Fetching flights for tripId: $tripId');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          flightProvider.fetchMyFlights(tripId);
        });
      } else {
        debugPrint('❌ [TripScreen] tripId is null — cannot fetch flights');
      }
    }

    return Consumer<FlightProvider>(
      builder: (context, provider, child) {
        debugPrint(
          '🔵 [TripScreen] _flightsSection build — isLoading: ${provider.isLoading}',
        );
        debugPrint(
          '🔵 [TripScreen] flights count: ${provider.flightDetails?.flights.length}',
        );

        if (provider.isLoading) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 40.h),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final flights = provider.flightDetails?.flights ?? [];

        if (flights.isEmpty) {
          debugPrint('❌ [TripScreen] No flights found');
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 40.h),
            child: Center(
              child: AppText(
                text: "No flight details available",
                style: textStyle14Regular.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          );
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 27.w, vertical: 10.h),
            child: Column(
              children: flights.asMap().entries.map((entry) {
                final index = entry.key;
                final flight = entry.value;
                debugPrint(
                  '🔵 [TripScreen] Flight[$index]: ${flight.flightName} — ${flight.flightType}',
                );
                return Column(
                  children: [
                    TripDetailsCard(
                      title: flight.flightType == 'outbound'
                          ? 'Outbound Flight'
                          : 'Return Flight',
                      infoMap: flight.infoMap,
                    ),
                    if (index < flights.length - 1) SizedBox(height: 20.h),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _hotelsSection() {
    final tripProvider = context.watch<TripProvider>();
    final tripId = tripProvider.selectedTrip?.id;
    final isLoading = tripProvider.isHotelVoucherLoading;
    final error = tripProvider.hotelVoucherError;
    final vouchers = tripProvider.hotelVouchers;
    final hasFetched = tripProvider.hasFetchedHotelVouchers;

    // Static escort details for now (as requested).
    final escortCard = Column(
      children: [
        EscortContactCard(name: "Ahmed Khan", phone: "+966 55 123 4567"),
        SizedBox(height: 16.h),
      ],
    );

    if (tripId != null &&
        tripId.isNotEmpty &&
        vouchers.isEmpty &&
        !isLoading &&
        error == null &&
        !hasFetched) {
      // If user lands here via deep link / restore, ensure we load once.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<TripProvider>().fetchHotelVoucherDetails(tripId);
        }
      });
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 27.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            escortCard,
            if (isLoading)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                child: const Center(child: CircularProgressIndicator()),
              )
            else if (error != null)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Column(
                  children: [
                    AppText(
                      text: "Failed to load hotel details",
                      style: textStyle14Regular.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                    12.h.verticalSpace,
                    AppButton(
                      title: "Retry",
                      onTap: tripId == null || tripId.isEmpty
                          ? null
                          : () => context
                                .read<TripProvider>()
                                .fetchHotelVoucherDetails(tripId, force: true),
                    ),
                  ],
                ),
              )
            else if (vouchers.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: AppText(
                  text: "No hotel details available",
                  style: textStyle14Regular.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
              )
            else
              ...vouchers.asMap().entries.map((entry) {
                final idx = entry.key;
                final hotel = entry.value;
                final room = hotel.rooms.isNotEmpty ? hotel.rooms.first : null;
                final facilities = hotel.facilities.join(', ');

                final info = <String, String>{
                  "Name": hotel.hotelName.isEmpty ? "-" : hotel.hotelName,
                  "Address": hotel.hotelAddress.isEmpty
                      ? "-"
                      : hotel.hotelAddress,
                  "Phone": hotel.hotelContact.isEmpty
                      ? "-"
                      : hotel.hotelContact,
                  "Check-in": hotel.stayInfo.checkIn ?? "-",
                  "Check-out": hotel.stayInfo.checkOut ?? "-",
                  if (room != null)
                    "Room Type": room.roomType.isEmpty ? "-" : room.roomType,
                  if (room != null)
                    "Room No": room.roomNumber.isEmpty ? "-" : room.roomNumber,
                  if (room != null && room.guests.isNotEmpty)
                    "Guests": room.guests.join(', '),
                  if (facilities.isNotEmpty) "Facilities": facilities,
                };

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: idx == vouchers.length - 1 ? 0 : 20.h,
                  ),
                  child: TripDetailsCard(
                    labelWidth: 90.w,
                    title: hotel.hotelName.isEmpty
                        ? "Hotel ${idx + 1}"
                        : hotel.hotelName,
                    infoMap: info,
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _itinerarySection() {
    final tripProvider = context.watch<TripProvider>();
    final tripId = tripProvider.selectedTrip?.id;
    final isLoading = tripProvider.isItineraryLoading;
    final error = tripProvider.itineraryError;
    final today = tripProvider.todayItinerary;
    final hasFetched = tripProvider.hasFetchedItinerary;

    if (tripId != null &&
        tripId.isNotEmpty &&
        today == null &&
        !isLoading &&
        error == null &&
        !hasFetched) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<TripProvider>().fetchTodayItinerary(tripId);
        }
      });
    }

    final activities = (today?.itinerary.activities ?? []).toList()
      ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 27.w, vertical: 20.h),
      child: isLoading
          ? Padding(
              padding: EdgeInsets.symmetric(vertical: 40.h),
              child: const Center(child: CircularProgressIndicator()),
            )
          : error != null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  text: "Failed to load itinerary",
                  style: textStyle14Regular.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
                12.h.verticalSpace,
                AppButton(
                  title: "Retry",
                  onTap: tripId == null || tripId.isEmpty
                      ? null
                      : () => context.read<TripProvider>().fetchTodayItinerary(
                          tripId,
                          force: true,
                        ),
                ),
              ],
            )
          : activities.isEmpty
          ? AppText(
              text: "No itinerary available",
              style: textStyle14Regular.copyWith(color: AppColors.primaryColor),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((today?.itinerary.dayTitle ?? '').isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: AppText(
                      text: today!.itinerary.dayTitle,
                      style: textStyle16SemiBold.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                if ((today?.itinerary.notes ?? '').trim().isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: AppText(
                      text: today!.itinerary.notes!.trim(),
                      style: textStyle14Regular.copyWith(
                        color: AppColors.primaryColor.setOpacity(0.7),
                      ),
                    ),
                  ),
                ...activities.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final a = entry.value;
                  final isLast = idx == activities.length - 1;
                  return Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 18.h),
                    child: ItineraryStep(
                      icon: _iconForItinerary(a.icon),
                      title: a.activityTitle,
                      time: a.times,
                      isCompleted:
                          (today?.itinerary.status ?? '') == 'completed',
                      isLast: isLast,
                    ),
                  );
                }),
              ],
            ),
    );
  }

  String _iconForItinerary(String rawIcon) {
    switch (rawIcon.toLowerCase()) {
      case 'plane':
        return AppAssets.plane;
      case 'bus':
      case 'truck':
        return AppAssets.truck;
      case 'hotel':
        return AppAssets.hotel;
      case 'mosque':
      case 'landmark':
        return AppAssets.landmark;
      case 'location':
      default:
        return AppAssets.location;
    }
  }

  Widget _essentialsSection() {
    final List<String> essentialsItems = [
      "Packing List",
      "Currency & Money",
      "Emergency Contacts",
      "Local Info/Haramain Train",
      "Health & Safety Tips",
      "Umrah Guide (Step-by-Step)",
      "Dua List",
    ];

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 23.h),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: essentialsItems.length,
      separatorBuilder: (_, __) => SizedBox(height: 23.h),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            if (index == 0) {
              context.pushNamed(
                UserAppRoutes.packageListScreen.name,
                extra: freshRouteNonce(),
              );
            }
            if (index == 1) {
              context.pushNamed(
                UserAppRoutes.currencyMoneyScreen.name,
                extra: freshRouteNonce(),
              );
            }
            if (index == 2) {
              context.pushNamed(
                UserAppRoutes.emergencyContactScreen.name,
                extra: freshRouteNonce(),
              );
            }
            if (index == 3) {
              context.pushNamed(
                UserAppRoutes.localInformationScreen.name,
                extra: freshRouteNonce(),
              );
            }
            if (index == 4) {
              context.pushNamed(
                UserAppRoutes.healthSafteyScreen.name,
                extra: freshRouteNonce(),
              );
            }
            if (index == 5) {
              context.pushNamed(
                UserAppRoutes.umrahGuideScreen.name,
                extra: freshRouteNonce(),
              );
            }
            if (index == 6) {
              context.pushNamed(
                UserAppRoutes.duaListScreen.name,
                extra: freshRouteNonce(),
              );
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                text: essentialsItems[index],
                style: textStyle14Regular.copyWith(
                  fontSize: 18.sp,
                  color: AppColors.primaryColor,
                ),
              ),
              SvgIcon(
                AppAssets.arrow,
                size: 16.sp,
                color: AppColors.primaryColor,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchOptionalUrl(String? raw) async {
    if (raw == null || raw.trim().isEmpty) return;
    final uri = Uri.tryParse(raw.trim());
    if (uri == null) return;
    if (!await canLaunchUrl(uri)) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _dialOptional(String? raw) async {
    if (raw == null || raw.trim().isEmpty) return;
    final digits = raw.replaceAll(RegExp(r'[^\d+]'), '');
    if (digits.isEmpty) return;
    final uri = Uri.parse('tel:$digits');
    if (!await canLaunchUrl(uri)) return;
    await launchUrl(uri);
  }

  Future<void> _shareDocument(
    BuildContext context, {
    File? file,
    String? networkUrl,
    required String title,
  }) async {
    await shareDocumentFile(
      context: context,
      localFile: file,
      networkUrl: networkUrl,
      label: title,
    );
  }

  Widget _buildApiPersonalDocCard(
    BuildContext context, {
    required PersonalDoc doc,
    required String typeLabel,
    required String memberName,
    required bool showMemberName,
  }) {
    final info = <String, String>{
      'File Type': doc.fileType ?? '—',
      if (doc.uploadedDate != null && doc.uploadedDate!.isNotEmpty)
        'Uploaded': doc.uploadedDate!,
    };
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: DocumentCard(
        doc: DocumentModel(
          image: AppAssets.hotel4,
          networkThumbnailUrl: doc.resolvedViewUrl,
          title: doc.documentName,
          subtitle: showMemberName ? '$typeLabel · $memberName' : typeLabel,
          info: info,
          button1: 'View',
          button2: 'Download',
          icon: AppAssets.save,
        ),
        onTap: () {
          final url = doc.resolvedViewUrl;
          if (url == null || url.isEmpty) return;
          context.pushNamed(
            UserAppRoutes.viewDocumentScreen.name,
            extra: {
              'file': null,
              'networkFileUrl': url,
              'assetImage': AppAssets.hotel4,
              'title': doc.documentName,
            },
          );
        },
        onSecondaryTap: () => _shareDocument(
          context,
          networkUrl: doc.resolvedViewUrl,
          title: doc.documentName,
        ),
      ),
    );
  }

  Widget _buildApiFlightTicketCard(
    BuildContext context, {
    required FlightTicketDoc ticket,
    required String memberName,
    required bool showMemberName,
  }) {
    final info = <String, String>{
      if (ticket.flightName != null && ticket.flightName!.isNotEmpty)
        'Flight': ticket.flightName!,
      if (ticket.date != null && ticket.date!.isNotEmpty) 'Date': ticket.date!,
      'File Type': ticket.fileType ?? '—',
    };
    final title = showMemberName
        ? 'E-ticket · $memberName'
        : (ticket.flightName ?? 'Flight ticket');
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: DocumentCard(
        doc: DocumentModel(
          subtitle: 'Flight Ticket',
          image: AppAssets.hotel,
          title: title,
          networkThumbnailUrl: ticket.resolvedTicketUrl,
          info: info,
          button1: 'View',
          button2: 'Download',
          icon: AppAssets.save,
        ),
        onTap: () {
          final url = ticket.resolvedTicketUrl;
          if (url == null || url.isEmpty) return;
          context.pushNamed(
            UserAppRoutes.viewDocumentScreen.name,
            extra: {
              'file': null,
              'networkFileUrl': url,
              'assetImage': AppAssets.hotel4,
              'title': 'E-ticket',
            },
          );
        },
        onSecondaryTap: () => _shareDocument(
          context,
          networkUrl: ticket.resolvedTicketUrl,
          title: title,
        ),
      ),
    );
  }

  Widget _buildBundleHotelDocCard(BuildContext context, BundleHotelDoc h) {
    final thumb = h.resolvedImageUrl ?? '';
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: DocumentCard(
        doc: DocumentModel(
          image: AppAssets.hotel1,
          networkThumbnailUrl: thumb.isNotEmpty ? thumb : null,
          title: h.hotelName,
          info: {
            'Check-in': h.checkIn ?? '—',
            'Check-out': h.checkOut ?? '—',
            'File Type': h.fileType ?? 'Image',
          },
          button1: 'View',
          button2: 'Open in Map',
          icon: AppAssets.map,
        ),
        onTap: () {
          context.pushNamed(
            UserAppRoutes.hotelVoucherScreen.name,
            extra: {
              'imageFile': null,
              'networkImageUrl': thumb.isNotEmpty ? thumb : null,
              'hotelName': h.hotelName,
              'address': h.hotelName,
            },
          );
        },
        onSecondaryTap: () async {
          final q = Uri.encodeComponent(h.hotelName);
          await _launchOptionalUrl(
            'https://www.google.com/maps/search/?api=1&query=$q',
          );
        },
      ),
    );
  }

  Widget _buildBundleInsuranceCard(
    BuildContext context,
    BundleInsuranceDoc d,
  ) {
    final info = <String, String>{
      if (d.coverage != null && d.coverage!.isNotEmpty)
        'Coverage': d.coverage!,
      if (d.uploadedDate != null && d.uploadedDate!.isNotEmpty)
        'Uploaded': d.uploadedDate!,
    };
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: DocumentCard(
        doc: DocumentModel(
          image: AppAssets.hotel3,
          networkThumbnailUrl: d.resolvedThumbnailUrl,
          title: d.policyName ?? 'Travel Insurance',
          subtitle: 'Travel Insurance',
          info: info,
          button1: 'View',
          button2: 'Helpline',
          icon: AppAssets.call,
        ),
        onTap: () {
          final url = d.resolvedPrimaryFileUrl ?? d.resolvedThumbnailUrl;
          if (url == null || url.isEmpty) return;
          context.pushNamed(
            UserAppRoutes.viewDocumentScreen.name,
            extra: {
              'file': null,
              'networkFileUrl': url,
              'assetImage': AppAssets.hotel4,
              'title': d.policyName ?? 'Insurance',
            },
          );
        },
        onSecondaryTap: () => _dialOptional(d.emergencyDetails),
      ),
    );
  }

  Widget _buildBundleChecklistCard(
    BuildContext context,
    BundleChecklistDoc d,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: DocumentCard(
        doc: DocumentModel(
          image: AppAssets.hotel3,
          networkThumbnailUrl: d.resolvedThumbnailUrl,
          title: 'Checklist',
          subtitle: 'Travel Document',
          info: {
            if (d.fileType != null) 'File Type': d.fileType!,
            if (d.uploadedDate != null) 'Uploaded': d.uploadedDate!,
          },
          button1: 'View',
          button2: 'Download',
          icon: AppAssets.save,
        ),
        onTap: () {
          final url = d.resolvedPrimaryFileUrl ?? d.resolvedThumbnailUrl;
          if (url == null || url.isEmpty) return;
          context.pushNamed(
            UserAppRoutes.viewDocumentScreen.name,
            extra: {
              'file': null,
              'networkFileUrl': url,
              'assetImage': AppAssets.hotel4,
              'title': 'Checklist',
            },
          );
        },
        onSecondaryTap: () {
          final url = d.resolvedPrimaryFileUrl ?? d.resolvedThumbnailUrl;
          _shareDocument(
            context,
            networkUrl: url,
            title: 'Checklist',
          );
        },
      ),
    );
  }

  Widget _buildHotelVoucherDocumentCard(
    BuildContext context,
    HotelVoucherModel h,
  ) {
    final thumb = serverMediaUrl(h.hotelImage) ?? '';
    final checkIn = h.stayInfo.checkIn ?? '-';
    final checkOut = h.stayInfo.checkOut ?? '-';

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: DocumentCard(
        doc: DocumentModel(
          image: AppAssets.hotel1,
          networkThumbnailUrl: thumb.isNotEmpty ? thumb : null,
          title: h.hotelName.isEmpty ? 'Hotel' : h.hotelName,
          info: {
            'Check-in': checkIn,
            'Check-out': checkOut,
            'File Type': 'Image (JPG)',
          },
          button1: 'View',
          button2: 'Open in Map',
          icon: AppAssets.map,
        ),
        onTap: () {
          context.pushNamed(
            UserAppRoutes.hotelVoucherScreen.name,
            extra: {
              'imageFile': null,
              'networkImageUrl': thumb.isNotEmpty ? thumb : null,
              'hotelName': h.hotelName,
              'address': h.hotelAddress,
            },
          );
        },
        onSecondaryTap: () async {
          final u = h.locationUrl;
          if (u != null && u.trim().isNotEmpty) {
            await _launchOptionalUrl(u);
          } else {
            final q = Uri.encodeComponent(h.hotelAddress);
            await _launchOptionalUrl(
              'https://www.google.com/maps/search/?api=1&query=$q',
            );
          }
        },
      ),
    );
  }

  Widget _documentsSection() {
    return Consumer2<MyTripProvider, TripProvider>(
      builder: (context, myTrip, trip, _) {
        final tripId = trip.selectedTrip?.id;
        final docs = myTrip.uploadedDocs;
        final bundle = myTrip.tripDocumentsBundle;
        final loading = myTrip.isTripDocumentsLoading;
        final err = myTrip.tripDocumentsError;
        final hotels = trip.hotelVouchers;

        final multiMember = (bundle?.memberDocuments.length ?? 0) > 1;

        var hasPassVisaApi = false;
        var hasFlightApi = false;
        var hasMedApi = false;
        if (bundle != null) {
          for (final m in bundle.memberDocuments) {
            final d = m.documents;
            if (d.visa != null || d.passport != null) {
              hasPassVisaApi = true;
            }
            if (d.flightTickets.isNotEmpty) hasFlightApi = true;
            if (d.medicalCertificate != null) hasMedApi = true;
          }
        }

        final bundleHotel = bundle?.tripDocuments.hotel;
        final insurance = bundle?.tripDocuments.insurance;
        final checklist = bundle?.tripDocuments.checklist;

        final hasLocal = docs.isNotEmpty;
        final hasRemote = bundle?.hasAnyRemoteContent ?? false;
        final hasHotelRows = hotels.isNotEmpty || bundleHotel != null;
        final hasTravelAdmin = insurance != null || checklist != null;

        if (loading) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 48.h),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (err != null) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  text: err,
                  style: textStyle14Regular.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
                16.h.verticalSpace,
                AppButton(
                  title: 'Retry',
                  onTap: tripId == null || tripId.isEmpty
                      ? null
                      : () async {
                          await trip.fetchHotelVoucherDetails(
                            tripId,
                            force: true,
                          );
                          await myTrip.fetchTripDocuments(tripId, force: true);
                        },
                ),
              ],
            ),
          );
        }

        final showEmpty = !hasLocal &&
            !hasRemote &&
            !hasHotelRows &&
            !hasTravelAdmin;

        final apiPassVisaWidgets = <Widget>[];
        final apiFlightWidgets = <Widget>[];
        final apiMedWidgets = <Widget>[];
        if (bundle != null) {
          for (final m in bundle.memberDocuments) {
            final d = m.documents;
            if (d.visa != null) {
              apiPassVisaWidgets.add(
                _buildApiPersonalDocCard(
                  context,
                  doc: d.visa!,
                  typeLabel: 'Visa',
                  memberName: m.name,
                  showMemberName: multiMember,
                ),
              );
            }
            if (d.passport != null) {
              apiPassVisaWidgets.add(
                _buildApiPersonalDocCard(
                  context,
                  doc: d.passport!,
                  typeLabel: 'Passport',
                  memberName: m.name,
                  showMemberName: multiMember,
                ),
              );
            }
            for (final t in d.flightTickets) {
              apiFlightWidgets.add(
                _buildApiFlightTicketCard(
                  context,
                  ticket: t,
                  memberName: m.name,
                  showMemberName: multiMember,
                ),
              );
            }
            if (d.medicalCertificate != null) {
              apiMedWidgets.add(
                _buildApiPersonalDocCard(
                  context,
                  doc: d.medicalCertificate!,
                  typeLabel: 'Medical Certificate',
                  memberName: m.name,
                  showMemberName: multiMember,
                ),
              );
            }
          }
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showEmpty) _emptyDocumentCard(tripId),
                if (!showEmpty) ...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => context.pushNamed(
                        UserAppRoutes.addDocumentScreen.name,
                        extra: tripId == null || tripId.isEmpty
                            ? null
                            : {'tripId': tripId},
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(30.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.setOpacity(0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgIcon(
                              AppAssets.addMore,
                              size: 18.w,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8.w),
                            AppText(
                              text: "Add More",
                              style: textPoppinsMedium.copyWith(
                                color: Colors.white,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],

                if (docs.any(
                      (d) =>
                          d["type"] == "Passport" || d["type"] == "Visa",
                    ) ||
                    hasPassVisaApi) ...[
                  AppText(text: "Passport & Visa", style: textStyle16SemiBold),
                  12.h.verticalSpace,
                  ...docs
                      .where(
                        (d) =>
                            d["type"] == "Passport" || d["type"] == "Visa",
                      )
                      .map(
                        (doc) => Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: DocumentCard(
                            doc: DocumentModel(
                              image: AppAssets.hotel4,
                              title: doc["name"],
                              fileImage: doc["file"],
                              info: {
                                "File Type": "PDF",
                                "Uploaded": doc["date"] ?? "02 Jun 2025",
                              },
                              button1: "View",
                              button2: "Download",
                              icon: AppAssets.save,
                            ),
                            onTap: () {
                              context.pushNamed(
                                UserAppRoutes.viewDocumentScreen.name,
                                extra: {
                                  'file': doc["file"],
                                  'assetImage': AppAssets.hotel4,
                                  'title': "${doc["name"]} copy",
                                },
                              );
                            },
                            onSecondaryTap: () => _shareDocument(
                              context,
                              file: doc["file"] as File?,
                              title: doc["name"]?.toString() ?? 'Document',
                            ),
                          ),
                        ),
                      ),
                  ...apiPassVisaWidgets,
                  20.h.verticalSpace,
                ],

                if (docs.any((d) => d["type"] == "Flight Ticket") ||
                    hasFlightApi) ...[
                  AppText(
                    text: "Round Trip Tickets",
                    style: textStyle16SemiBold,
                  ),
                  SizedBox(height: 12.h),
                  ...docs
                      .where((d) => d["type"] == "Flight Ticket")
                      .map(
                        (doc) => Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: DocumentCard(
                            doc: DocumentModel(
                              subtitle: "Return Ticket",
                              image: AppAssets.hotel,
                              title: doc["name"],
                              fileImage: doc["file"],
                              info: {
                                "Airline": " Saudia SV773",
                                "File Type": "PDF",
                                "Date": "20 Feb 2025",
                              },
                              button1: "View",
                              button2: "Download",
                              icon: AppAssets.save,
                            ),
                            onTap: () {
                              context.pushNamed(
                                UserAppRoutes.viewDocumentScreen.name,
                                extra: {
                                  'file': doc["file"],
                                  'assetImage': AppAssets.hotel4,
                                  'title': "E-ticket",
                                },
                              );
                            },
                            onSecondaryTap: () => _shareDocument(
                              context,
                              file: doc["file"] as File?,
                              title: doc["name"]?.toString() ?? 'E-ticket',
                            ),
                          ),
                        ),
                      ),
                  ...apiFlightWidgets,
                  20.h.verticalSpace,
                ],

                if (docs.any((d) => d["type"] == "Medical Certificate") ||
                    hasMedApi) ...[
                  AppText(
                    text: "Medical Certificate",
                    style: textStyle16SemiBold,
                  ),
                  SizedBox(height: 12.h),
                  ...docs
                      .where((d) => d["type"] == "Medical Certificate")
                      .map(
                        (doc) => Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: DocumentCard(
                            doc: DocumentModel(
                              image: AppAssets.hotel2,
                              title: "Medical Certificate",
                              fileImage: doc["file"],
                              info: {"File Type": "JPG"},
                              button1: "View",
                              button2: "Download",
                              icon: AppAssets.call,
                            ),
                            onTap: () {
                              context.pushNamed(
                                UserAppRoutes.viewDocumentScreen.name,
                                extra: {
                                  'file': doc["file"],
                                  'assetImage': AppAssets.hotel4,
                                  'title': doc["name"],
                                },
                              );
                            },
                            onSecondaryTap: () => _shareDocument(
                              context,
                              file: doc["file"] as File?,
                              title: doc["name"]?.toString() ?? 'Medical',
                            ),
                          ),
                        ),
                      ),
                  ...apiMedWidgets,
                  20.h.verticalSpace,
                ],

                if (hasHotelRows) ...[
                  AppText(text: "Hotel Vouchers", style: textStyle16SemiBold),
                  SizedBox(height: 12.h),
                  if (bundleHotel != null)
                    _buildBundleHotelDocCard(context, bundleHotel),
                  ...hotels.map(
                    (h) => _buildHotelVoucherDocumentCard(context, h),
                  ),
                  SizedBox(height: 20.h),
                ],

                if (hasTravelAdmin) ...[
                  AppText(text: "Travel Document", style: textStyle16SemiBold),
                  SizedBox(height: 12.h),
                  if (insurance != null)
                    _buildBundleInsuranceCard(context, insurance),
                  if (checklist != null)
                    _buildBundleChecklistCard(context, checklist),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _emptyDocumentCard(String? tripId) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 32.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primaryColor.setOpacity(0.1)),

        boxShadow: [
          BoxShadow(
            color: Colors.black.setOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Image.asset(AppAssets.upload, width: 60.w, height: 60.h),
          SizedBox(height: 10.h),
          AppText(
            text: "No documents uploaded yet",
            style: textStyle16SemiBold.copyWith(
              fontSize: 21.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          10.h.verticalSpace,
          AppText(
            text: "Add your Passport, Visa, Tickets here.",
            style: textStyle14Regular.copyWith(
              fontSize: 16.sp,
              color: AppColors.primaryColor.setOpacity(0.6),
            ),
          ),
          40.h.verticalSpace,
          AppButton(
            title: "Add New Document",
            onTap: () {
              context.pushNamed(
                UserAppRoutes.addDocumentScreen.name,
                extra: tripId == null || tripId.isEmpty
                    ? null
                    : {'tripId': tripId},
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String title, String value) {
    Color textColor;

    if (title == "Paid") {
      textColor = AppColors.primaryColor.setOpacity(0.6);
    } else if (title == "Pending") {
      textColor = AppColors.primaryColor.setOpacity(0.6);
    } else {
      textColor = AppColors.primaryColor;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      child: Row(
        children: [
          Expanded(
            child: AppText(
              text: title,
              style: textStyle14Medium.copyWith(
                color: textColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Spacer(),
          AppText(
            text: ":",
            style: textStyle14Medium.copyWith(
              color: AppColors.primaryColor.setOpacity(0.6),
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          24.w.horizontalSpace,
          AppText(
            text: value,
            style: textStyle14Medium.copyWith(
              color: AppColors.primaryColor,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // (removed unused _cardDetailsSection)
}
