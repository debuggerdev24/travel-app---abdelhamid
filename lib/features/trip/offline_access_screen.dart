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

import 'package:provider/provider.dart';

class OfflineAccessState extends ChangeNotifier {
  List<TripModel> _savedTrips = [];
  bool _isLoading = true;

  List<TripModel> get savedTrips => _savedTrips;
  bool get isLoading => _isLoading;

  OfflineAccessState() {
    loadSavedTrips();
  }

  Future<void> loadSavedTrips() async {
    _isLoading = true;
    notifyListeners();
    final trips = await OfflineStorageHelper.getSavedOfflineTrips();
    _savedTrips = trips;
    _isLoading = false;
    notifyListeners();
  }
}

class TripOfflineCardState extends ChangeNotifier {
  final TripModel trip;
  UserItineraryResponseModel? _itinerary;
  TripDocumentsBundle? _documents;
  bool _isLoadingData = false;

  UserItineraryResponseModel? get itinerary => _itinerary;
  TripDocumentsBundle? get documents => _documents;
  bool get isLoadingData => _isLoadingData;

  TripOfflineCardState(this.trip);

  Future<void> loadTripData() async {
    if (_itinerary != null || _documents != null) return;
    _isLoadingData = true;
    notifyListeners();

    final it = await OfflineStorageHelper.getOfflineItinerary(
      trip.id ?? '',
    );
    final docs = await OfflineStorageHelper.getOfflineDocuments(
      trip.id ?? '',
    );

    _itinerary = it;
    _documents = docs;
    _isLoadingData = false;
    notifyListeners();
  }
}

class OfflineAccessScreen extends StatelessWidget {
  const OfflineAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OfflineAccessState(),
      child: const _OfflineAccessScreenView(),
    );
  }
}

class _OfflineAccessScreenView extends StatelessWidget {
  const _OfflineAccessScreenView();

  Widget build(BuildContext context) {
    final state = context.watch<OfflineAccessState>();

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
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.savedTrips.isEmpty
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
              itemCount: state.savedTrips.length,
              itemBuilder: (context, index) {
                final trip = state.savedTrips[index];
                return _TripOfflineCard(trip: trip, onRemove: () => context.read<OfflineAccessState>().loadSavedTrips());
              },
            ),
    );
  }
}

class _TripOfflineCard extends StatelessWidget {
  final TripModel trip;
  final VoidCallback onRemove;

  const _TripOfflineCard({required this.trip, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TripOfflineCardState(trip),
      child: _TripOfflineCardView(onRemove: onRemove),
    );
  }
}

class _TripOfflineCardView extends StatelessWidget {
  final VoidCallback onRemove;

  const _TripOfflineCardView({required this.onRemove});

  Widget build(BuildContext context) {
    final state = context.watch<TripOfflineCardState>();

    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: ExpansionTile(
        title: AppText(
          text: state.trip.title.isNotEmpty
              ? state.trip.title
              : "Unnamed Trip",
          style: textStyle16SemiBold.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: AppText(
          text: state.trip.date,
          style: textStyle12Regular.copyWith(color: Colors.grey),
        ),
        onExpansionChanged: (expanded) {
          if (expanded) {
            context.read<TripOfflineCardState>().loadTripData();
          }
        },
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.isLoadingData)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  _buildItinerarySection(state),
                  20.h.verticalSpace,
                  _buildDocumentsSection(state, context),
                  20.h.verticalSpace,
                  AppButton(
                    title: "Remove from Offline".tr(),
                    onTap: () async {
                      await OfflineStorageHelper.removeOfflineTrip(
                        state.trip.id ?? '',
                      );
                      onRemove();
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

  Widget _buildItinerarySection(TripOfflineCardState state) {
    if (state.itinerary == null) {
      return AppText(
        text: "No itinerary saved.".tr(),
        style: textStyle14Regular.copyWith(color: Colors.grey),
      );
    }

    final activities = (state.itinerary?.itinerary.activities ?? []).toList()
      ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: "Itinerary - ${state.itinerary?.itinerary.dayTitle ?? 'Day'}",
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

  Widget _buildDocumentsSection(TripOfflineCardState state, BuildContext context) {
    if (state.documents == null || !state.documents!.hasAnyRemoteContent) {
      return AppText(
        text: "No documents saved.".tr(),
        style: textStyle14Regular.copyWith(color: Colors.grey),
      );
    }

    // Simplistic view for offline docs showing what is available
    List<String> availableDocs = [];
    final tDocs = state.documents!.tripDocuments;
    if (tDocs.hotel != null) {
      availableDocs.add("Hotel Voucher: ${tDocs.hotel?.hotelName}");
    }
    if (tDocs.insurance != null) {
      availableDocs.add("Insurance: ${tDocs.insurance?.policyName}");
    }
    if (tDocs.checklist != null) availableDocs.add("Checklist Document");

    for (var m in state.documents!.memberDocuments) {
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
