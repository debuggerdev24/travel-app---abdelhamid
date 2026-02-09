import 'package:go_router/go_router.dart';
import 'package:trael_app_abdelhamid/core/core.dart';
import 'package:trael_app_abdelhamid/routes/route_pages/auth_routes.dart';
import 'package:trael_app_abdelhamid/routes/route_pages/booking_routes.dart';
import 'package:trael_app_abdelhamid/routes/route_pages/chat_routes.dart';
import 'package:trael_app_abdelhamid/routes/route_pages/profile_routes.dart';
import 'package:trael_app_abdelhamid/routes/route_pages/trip_routes.dart';
import 'package:trael_app_abdelhamid/routes/user_routes.dart';

/// Central GoRouter configuration.
/// Route definitions are split by feature in [route_pages/].
class UserAppRoute {
  static final GoRouter goRouter = GoRouter(
    initialLocation: PrefHelper.isLoggedIn()
        ? UserAppRoutes.tabScreen.path
        : UserAppRoutes.signInScreen.path,
    routes: [
      ...authRoutes,
      ...bookingRoutes,
      ...tripRoutes,
      ...chatRoutes,
      ...profileRoutes,
    ],
  );
}
