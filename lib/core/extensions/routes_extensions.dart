
import 'package:trael_app_abdelhamid/routes/user_routes.dart';

extension AppRouteExtension on UserAppRoutes {
  String get path => this == UserAppRoutes.signUpScreen ? "/" : "/$name";
}