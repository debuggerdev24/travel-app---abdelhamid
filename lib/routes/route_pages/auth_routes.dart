import 'package:go_router/go_router.dart';
import 'package:trael_app_abdelhamid/core/extensions/routes_extensions.dart';
import 'package:trael_app_abdelhamid/routes/user_routes.dart';
import 'package:trael_app_abdelhamid/features/auth/screens/forgot_password_screen.dart';
import 'package:trael_app_abdelhamid/features/auth/screens/otp_verification_screen.dart';
import 'package:trael_app_abdelhamid/features/auth/screens/reset_password_screen.dart';
import 'package:trael_app_abdelhamid/features/auth/screens/sign_in_screen.dart';
import 'package:trael_app_abdelhamid/features/auth/screens/sign_up_screen.dart';
import 'package:trael_app_abdelhamid/features/tabs/tab_screen.dart';

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
    builder: (context, state) =>
        OtpVerificationScreen(email: state.uri.queryParameters['email']!),
  ),
  GoRoute(
    path: UserAppRoutes.resetPasswordScreen.path,
    name: UserAppRoutes.resetPasswordScreen.name,
    builder: (context, state) =>
        ResetPasswordScreen(email: state.uri.queryParameters['email'] ?? ""),
  ),
  GoRoute(
    path: UserAppRoutes.tabScreen.path,
    name: UserAppRoutes.tabScreen.name,
    builder: (context, state) => TabScreen(),
  ),
];
