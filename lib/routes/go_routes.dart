import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_app_abdelhamid/core/extensions/routes_extensions.dart';
import 'package:travel_app_abdelhamid/routes/route_pages/auth_routes.dart';
import 'package:travel_app_abdelhamid/routes/route_pages/booking_routes.dart';
import 'package:travel_app_abdelhamid/routes/route_pages/chat_routes.dart';
import 'package:travel_app_abdelhamid/routes/route_pages/profile_routes.dart';
import 'package:travel_app_abdelhamid/routes/route_pages/trip_routes.dart';
import 'package:travel_app_abdelhamid/routes/user_routes.dart';

/// Central GoRouter configuration.
/// Route definitions are split by feature in [route_pages/].
class UserAppRoute {
  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter goRouter = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: UserAppRoutes.splashScreen.path,
    routes: [
      ...authRoutes,
      ...bookingRoutes,
      ...tripRoutes,
      ...chatRoutes,
      ...profileRoutes,
    ],
  );
}
