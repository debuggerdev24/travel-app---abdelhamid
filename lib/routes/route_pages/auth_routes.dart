import 'package:go_router/go_router.dart';
import 'package:trael_app_abdelhamid/core/extensions/routes_extensions.dart';
import 'package:trael_app_abdelhamid/routes/user_routes.dart';
import 'package:trael_app_abdelhamid/screens/auth/forgot_password_screen.dart';
import 'package:trael_app_abdelhamid/screens/auth/otp_verification_screen.dart';
import 'package:trael_app_abdelhamid/screens/auth/sign_in_screen.dart';
import 'package:trael_app_abdelhamid/screens/auth/sign_up_screen.dart';
import 'package:trael_app_abdelhamid/screens/tabs/tab_screen.dart';

List<RouteBase> get authRoutes => [
  GoRoute(
    path: UserAppRoutes.signUpScreen.path,
    name: UserAppRoutes.signUpScreen.name,
    builder: (context, state) => SignUpScreen(),
  ),
  GoRoute(
    path: UserAppRoutes.signInScreen.path,
    name: UserAppRoutes.signInScreen.name,
    builder: (context, state) => SignInScreen(),
  ),
  GoRoute(
    path: UserAppRoutes.forgotPasswordScreen.path,
    name: UserAppRoutes.forgotPasswordScreen.name,
    builder: (context, state) => ForgotPasswordScreen(),
  ),
  GoRoute(
    path: UserAppRoutes.verifyOtpScreen.path,
    name: UserAppRoutes.verifyOtpScreen.name,
    builder: (context, state) => OtpVerificationScreen(),
  ),
  GoRoute(
    path: UserAppRoutes.tabScreen.path,
    name: UserAppRoutes.tabScreen.name,
    builder: (context, state) => TabScreen(),
  ),
];
