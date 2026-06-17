import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/utils/offline_storage_helper.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_button.dart';
import 'package:travel_app_abdelhamid/model/home/trip_model.dart';
import 'package:travel_app_abdelhamid/model/home/user_itinerary_model.dart';
import 'package:travel_app_abdelhamid/model/trip/trip_documents_bundle_model.dart';
import 'package:travel_app_abdelhamid/core/widgets/itinerarystep_card.dart';

class OfflineAccessScreen extends StatefulWidget {
  const OfflineAccessScreen({super.key});

  @override
  State<OfflineAccessScreen> createState() => _OfflineAccessScreenState();
}

class _OfflineAccessScreenState extends State<OfflineAccessScreen> {
  List<TripModel> _savedTrips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedTrips();
  }

  Future<void> _loadSavedTrips() async {
    setState(() {
      _isLoading = true;
    });
    final trips = await OfflineStorageHelper.getSavedOfflineTrips();
    setState(() {
      _savedTrips = trips;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText(
          text: "Offline Access".tr(),
          style: textStyle18Bold.copyWith(
            fontSize: 20.sp,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedTrips.isEmpty
          ? Center(
              child: AppText(
                text: "No trips saved for offline access.".tr(),
                style: textStyle16SemiBold.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              itemCount: _savedTrips.length,
              itemBuilder: (context, index) {
                final trip = _savedTrips[index];
                return _TripOfflineCard(trip: trip, onRemove: _loadSavedTrips);
              },
            ),
    );
  }
}

class _TripOfflineCard extends StatefulWidget {
  final TripModel trip;
  final VoidCallback onRemove;

  const _TripOfflineCard({required this.trip, required this.onRemove});

  @override
  State<_TripOfflineCard> createState() => _TripOfflineCardState();
}

class _TripOfflineCardState extends State<_TripOfflineCard> {
  UserItineraryResponseModel? _itinerary;
  TripDocumentsBundle? _documents;
  bool _isLoadingData = false;

  Future<void> _loadTripData() async {
    if (_itinerary != null || _documents != null) return;
    setState(() => _isLoadingData = true);

    final it = await OfflineStorageHelper.getOfflineItinerary(
      widget.trip.id ?? '',
    );
    final docs = await OfflineStorageHelper.getOfflineDocuments(
      widget.trip.id ?? '',
    );

    setState(() {
      _itinerary = it;
      _documents = docs;
      _isLoadingData = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: ExpansionTile(
        title: AppText(
          text: widget.trip.title.isNotEmpty
              ? widget.trip.title
              : "Unnamed Trip",
          style: textStyle16SemiBold.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: AppText(
          text: widget.trip.date,
          style: textStyle12Regular.copyWith(color: Colors.grey),
        ),
        onExpansionChanged: (expanded) {
          if (expanded) {
            _loadTripData();
          }
        },
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isLoadingData)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  _buildItinerarySection(),
                  20.h.verticalSpace,
                  _buildDocumentsSection(),
                  20.h.verticalSpace,
                  AppButton(
                    title: "Remove from Offline".tr(),
                    onTap: () async {
                      await OfflineStorageHelper.removeOfflineTrip(
                        widget.trip.id ?? '',
                      );
                      widget.onRemove();
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItinerarySection() {
    if (_itinerary == null) {
      return AppText(
        text: "No itinerary saved.".tr(),
        style: textStyle14Regular.copyWith(color: Colors.grey),
      );
    }

    final activities = (_itinerary?.itinerary.activities ?? []).toList()
      ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: "Itinerary - ${_itinerary?.itinerary.dayTitle ?? 'Day'}",
          style: textStyle16SemiBold.copyWith(color: AppColors.primaryColor),
        ),
        10.h.verticalSpace,
        if (activities.isEmpty)
          AppText(
            text: "No activities found.".tr(),
            style: textStyle14Regular.copyWith(color: Colors.grey),
          )
        else
          ...activities.map((a) {
            return ItineraryStep(
              time: a.times,
              title: a.activityTitle,
              icon: a.icon,
              isCompleted: false,
            );
          }),
      ],
    );
  }

  Widget _buildDocumentsSection() {
    if (_documents == null || !_documents!.hasAnyRemoteContent) {
      return AppText(
        text: "No documents saved.".tr(),
        style: textStyle14Regular.copyWith(color: Colors.grey),
      );
    }

    // Simplistic view for offline docs showing what is available
    List<String> availableDocs = [];
    final tDocs = _documents!.tripDocuments;
    if (tDocs.hotel != null) {
      availableDocs.add("Hotel Voucher: ${tDocs.hotel?.hotelName}");
    }
    if (tDocs.insurance != null) {
      availableDocs.add("Insurance: ${tDocs.insurance?.policyName}");
    }
    if (tDocs.checklist != null) availableDocs.add("Checklist Document");

    for (var m in _documents!.memberDocuments) {
      if (m.documents.visa != null) availableDocs.add("Visa for ${m.name}");
      if (m.documents.passport != null) {
        availableDocs.add("Passport for ${m.name}");
      }
      if (m.documents.flightTickets.isNotEmpty) {
        availableDocs.add("Flight Tickets for ${m.name}");
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: "Documents Available".tr(),
          style: textStyle16SemiBold.copyWith(color: AppColors.primaryColor),
        ),
        10.h.verticalSpace,
        if (availableDocs.isEmpty)
          AppText(
            text: "No specific documents found.".tr(),
            style: textStyle14Regular.copyWith(color: Colors.grey),
          )
        else
          ...availableDocs.map(
            (doc) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16.w),
                  8.w.horizontalSpace,
                  Expanded(
                    child: AppText(
                      text: doc,
                      style: textStyle14Regular.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
