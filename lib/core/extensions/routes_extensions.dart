import 'package:trael_app_abdelhamid/routes/user_routes.dart';

/// Pass as [GoRouterState.extra] on `pushNamed` so detail routes use a [ValueKey]
/// and remount every time—`initState` runs again and APIs refetch.
int freshRouteNonce() => DateTime.now().microsecondsSinceEpoch;

extension AppRouteExtension on UserAppRoutes {
  String get path => this == UserAppRoutes.signUpScreen ? "/" : "/$name";
}