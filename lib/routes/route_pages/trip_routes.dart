import 'dart:io';

import 'package:go_router/go_router.dart';
import 'package:trael_app_abdelhamid/core/extensions/routes_extensions.dart';
import 'package:trael_app_abdelhamid/routes/user_routes.dart';
import 'package:trael_app_abdelhamid/screens/trip/add_document_screen.dart';
import 'package:trael_app_abdelhamid/screens/trip/currency_money_screen.dart';
import 'package:trael_app_abdelhamid/screens/trip/dua_list_screen.dart';
import 'package:trael_app_abdelhamid/screens/trip/emergency_contact_screen.dart';
import 'package:trael_app_abdelhamid/screens/trip/health_saftey_screen.dart';
import 'package:trael_app_abdelhamid/screens/trip/hotel_voucher_screen.dart';
import 'package:trael_app_abdelhamid/screens/trip/local_information_screen.dart';
import 'package:trael_app_abdelhamid/screens/trip/packing_list_screen.dart';
import 'package:trael_app_abdelhamid/screens/trip/payment_history.dart';
import 'package:trael_app_abdelhamid/screens/trip/travel_insurance_screen.dart';
import 'package:trael_app_abdelhamid/screens/trip/trip_screen.dart';
import 'package:trael_app_abdelhamid/screens/trip/umrah_guide_screen.dart';
import 'package:trael_app_abdelhamid/screens/trip/view_receipt_screen.dart';
import 'package:trael_app_abdelhamid/screens/trip/view_screen.dart';

List<RouteBase> get tripRoutes => [
  GoRoute(
    path: UserAppRoutes.paymentHistoryScreen.path,
    name: UserAppRoutes.paymentHistoryScreen.name,
    builder: (context, state) => PaymentHistoryScreen(),
  ),
  GoRoute(
    path: UserAppRoutes.viewPaymentReceiptScreen.path,
    name: UserAppRoutes.viewPaymentReceiptScreen.name,
    builder: (context, state) => ViewReceiptScreen(),
  ),
  GoRoute(
    path: UserAppRoutes.myTripScreen.path,
    name: UserAppRoutes.myTripScreen.name,
    builder: (context, state) => TripScreen(),
  ),
  GoRoute(
    path: UserAppRoutes.packageListScreen.path,
    name: UserAppRoutes.packageListScreen.name,
    builder: (context, state) => PackageListScreen(),
  ),
  GoRoute(
    path: UserAppRoutes.currencyMoneyScreen.path,
    name: UserAppRoutes.currencyMoneyScreen.name,
    builder: (context, state) => CurrencyMoneyScreen(),
  ),
  GoRoute(
    path: UserAppRoutes.emergencyContactScreen.path,
    name: UserAppRoutes.emergencyContactScreen.name,
    builder: (context, state) => EmergencyContactsScreen(),
  ),
  GoRoute(
    path: UserAppRoutes.localInformationScreen.path,
    name: UserAppRoutes.localInformationScreen.name,
    builder: (context, state) => LocalInformationScreen(),
  ),
  GoRoute(
    path: UserAppRoutes.umrahGuideScreen.path,
    name: UserAppRoutes.umrahGuideScreen.name,
    builder: (context, state) => UmrahGuideScreen(),
  ),
  GoRoute(
    path: UserAppRoutes.duaListScreen.path,
    name: UserAppRoutes.duaListScreen.name,
    builder: (context, state) => DuaListScreen(),
  ),
  GoRoute(
    path: UserAppRoutes.healthSafteyScreen.path,
    name: UserAppRoutes.healthSafteyScreen.name,
    builder: (context, state) => HealthSafetyScreen(),
  ),
  GoRoute(
    path: UserAppRoutes.addDocumentScreen.path,
    name: UserAppRoutes.addDocumentScreen.name,
    builder: (context, state) => AddDocumentScreen(),
  ),
  GoRoute(
    path: UserAppRoutes.viewDocumetScreen.path,
    name: UserAppRoutes.viewDocumetScreen.name,
    builder: (context, state) {
      final data = state.extra as Map<String, dynamic>;
      return FullScreenDocumentViewer(
        file: data['file'] as File?,
        assetImage: data['assetImage'] as String,
        title: data['title'] as String,
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
