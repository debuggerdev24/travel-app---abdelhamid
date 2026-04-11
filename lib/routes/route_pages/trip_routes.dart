import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/extensions/routes_extensions.dart';
import 'package:trael_app_abdelhamid/routes/user_routes.dart';
import 'package:trael_app_abdelhamid/features/trip/add_document_screen.dart';
import 'package:trael_app_abdelhamid/features/trip/currency_money_screen.dart';
import 'package:trael_app_abdelhamid/features/trip/dua_list_screen.dart';
import 'package:trael_app_abdelhamid/features/trip/emergency_contact_screen.dart';
import 'package:trael_app_abdelhamid/features/trip/health_saftey_screen.dart';
import 'package:trael_app_abdelhamid/features/trip/hotel_voucher_screen.dart';
import 'package:trael_app_abdelhamid/features/trip/local_information_screen.dart';
import 'package:trael_app_abdelhamid/features/trip/packing_list_screen.dart';
import 'package:trael_app_abdelhamid/features/trip/payment_history.dart';
import 'package:trael_app_abdelhamid/features/trip/travel_insurance_screen.dart';
import 'package:trael_app_abdelhamid/features/trip/trip_screen.dart';
import 'package:trael_app_abdelhamid/features/trip/umrah_guide_screen.dart';
import 'package:trael_app_abdelhamid/features/trip/view_receipt_screen.dart';
import 'package:trael_app_abdelhamid/features/trip/view_screen.dart';

/// When [GoRouterState.extra] is an [int] from [freshRouteNonce], forces a new
/// widget [State] so essentials detail screens refetch on every navigation.
Key? _navigationKey(GoRouterState state) {
  final extra = state.extra;
  return extra is int ? ValueKey<int>(extra) : null;
}

List<RouteBase> get tripRoutes => [
  GoRoute(
    path: UserAppRoutes.paymentHistoryScreen.path,
    name: UserAppRoutes.paymentHistoryScreen.name,
    builder: (context, state) {
      final extra = state.extra;
      final bookingId = extra is Map<String, dynamic>
          ? extra['bookingId'] as String?
          : null;
      return PaymentHistoryScreen(bookingId: bookingId);
    },
  ),
  GoRoute(
    path: UserAppRoutes.viewPaymentReceiptScreen.path,
    name: UserAppRoutes.viewPaymentReceiptScreen.name,
    builder: (context, state) {
      final extra = state.extra;
      final paymentId = extra is Map<String, dynamic>
          ? extra['paymentId'] as String?
          : null;
      return ViewReceiptScreen(paymentId: paymentId);
    },
  ),
  GoRoute(
    path: UserAppRoutes.myTripScreen.path,
    name: UserAppRoutes.myTripScreen.name,
    builder: (context, state) => TripScreen(),
  ),
  GoRoute(
    path: UserAppRoutes.packageListScreen.path,
    name: UserAppRoutes.packageListScreen.name,
    builder: (context, state) =>
        PackageListScreen(key: _navigationKey(state)),
  ),
  GoRoute(
    path: UserAppRoutes.currencyMoneyScreen.path,
    name: UserAppRoutes.currencyMoneyScreen.name,
    builder: (context, state) =>
        CurrencyMoneyScreen(key: _navigationKey(state)),
  ),
  GoRoute(
    path: UserAppRoutes.emergencyContactScreen.path,
    name: UserAppRoutes.emergencyContactScreen.name,
    builder: (context, state) =>
        EmergencyContactsScreen(key: _navigationKey(state)),
  ),
  GoRoute(
    path: UserAppRoutes.localInformationScreen.path,
    name: UserAppRoutes.localInformationScreen.name,
    builder: (context, state) =>
        LocalInformationScreen(key: _navigationKey(state)),
  ),
  GoRoute(
    path: UserAppRoutes.umrahGuideScreen.path,
    name: UserAppRoutes.umrahGuideScreen.name,
    builder: (context, state) => UmrahGuideScreen(key: _navigationKey(state)),
  ),
  GoRoute(
    path: UserAppRoutes.duaListScreen.path,
    name: UserAppRoutes.duaListScreen.name,
    builder: (context, state) => DuaListScreen(key: _navigationKey(state)),
  ),
  GoRoute(
    path: UserAppRoutes.healthSafteyScreen.path,
    name: UserAppRoutes.healthSafteyScreen.name,
    builder: (context, state) =>
        HealthSafetyScreen(key: _navigationKey(state)),
  ),
  GoRoute(
    path: UserAppRoutes.addDocumentScreen.path,
    name: UserAppRoutes.addDocumentScreen.name,
    builder: (context, state) {
      final extra = state.extra;
      final tripId = extra is Map<String, dynamic>
          ? extra['tripId'] as String?
          : null;
      return AddDocumentScreen(tripId: tripId);
    },
  ),
  GoRoute(
    path: UserAppRoutes.viewDocumentScreen.path,
    name: UserAppRoutes.viewDocumentScreen.name,
    builder: (context, state) {
      final data = state.extra as Map<String, dynamic>;
      return FullScreenDocumentViewer(
        file: data['file'] as File?,
        networkFileUrl: data['networkFileUrl'] as String?,
        assetImage: (data['assetImage'] as String?) ?? AppAssets.hotel4,
        title: (data['title'] as String?) ?? '',
      );
    },
  ),
  GoRoute(
    path: UserAppRoutes.hotelVoucherScreen.path,
    name: UserAppRoutes.hotelVoucherScreen.name,
    builder: (context, state) {
      final data = state.extra as Map<String, dynamic>;
      return HotelVoucherScreen(
        imageFile: data['imageFile'] as String?,
        networkImageUrl: data['networkImageUrl'] as String?,
        hotelName: data['hotelName'] as String,
        address: data['address'] as String,
      );
    },
  ),
  GoRoute(
    path: UserAppRoutes.travelInsuranceScreen.path,
    name: UserAppRoutes.travelInsuranceScreen.name,
    builder: (context, state) {
      final data = state.extra as Map<String, dynamic>;
      return TravelInsuranceScreen(
        imageFile: data['imageFile'] as String?,
        hotelName: data['hotelName'] as String,
        address: data['address'] as String,
      );
    },
  ),
];
