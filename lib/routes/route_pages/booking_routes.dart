import 'package:go_router/go_router.dart';
import 'package:trael_app_abdelhamid/core/extensions/routes_extensions.dart';
import 'package:trael_app_abdelhamid/routes/user_routes.dart';
import 'package:trael_app_abdelhamid/features/home/feedback_screen.dart';
import 'package:trael_app_abdelhamid/features/home/package_summary_screen.dart';
import 'package:trael_app_abdelhamid/features/home/payment_failed_screen.dart';
import 'package:trael_app_abdelhamid/features/home/payment_option_screen.dart';
import 'package:trael_app_abdelhamid/features/home/payment_successfull_screen.dart';
import 'package:trael_app_abdelhamid/features/home/personal_details_screen.dart';
import 'package:trael_app_abdelhamid/features/home/personal_details_screen2.dart';
import 'package:trael_app_abdelhamid/features/home/room_details_screen.dart';
import 'package:trael_app_abdelhamid/features/home/trip_details.dart';

List<RouteBase> get bookingRoutes => [
  GoRoute(
    path: UserAppRoutes.tripDetailsScreen.path,
    name: UserAppRoutes.tripDetailsScreen.name,
    builder: (context, state) => TripDetailsScreen(),
  ),
  GoRoute(
    path: UserAppRoutes.feedbackScreen.path,
    name: UserAppRoutes.feedbackScreen.name,
    builder: (context, state) => FeedbackScreen(),
  ),
  GoRoute(
    path: UserAppRoutes.roomDetailScren.path,
    name: UserAppRoutes.roomDetailScren.name,
    builder: (context, state) => RoomDetailsScreen(),
  ),
  GoRoute(
    path: UserAppRoutes.personalDetailsScreen.path,
    name: UserAppRoutes.personalDetailsScreen.name,
    builder: (context, state) => PersonalDetailsScreen(),
  ),
  GoRoute(
    path: UserAppRoutes.personalDetailsScreen2.path,
    name: UserAppRoutes.personalDetailsScreen2.name,
    builder: (context, state) => FamilyMembersScreen(),
  ),
  GoRoute(
    path: UserAppRoutes.packageSummaryScreen.path,
    name: UserAppRoutes.packageSummaryScreen.name,
    builder: (context, state) => PackageSummaryScreen(),
  ),
  GoRoute(
    path: UserAppRoutes.paymentOptionScreen.path,
    name: UserAppRoutes.paymentOptionScreen.name,
    builder: (context, state) => PaymentOptionScreen(),
  ),
  GoRoute(
    path: UserAppRoutes.paymentSuccessfullScreen.path,
    name: UserAppRoutes.paymentSuccessfullScreen.name,
    builder: (context, state) => PaymentSuccessfullScreen(),
  ),
  GoRoute(
    path: UserAppRoutes.paymentFailedScreen.path,
    name: UserAppRoutes.paymentFailedScreen.name,
    builder: (context, state) => PaymentFailedScreen(),
  ),
];
