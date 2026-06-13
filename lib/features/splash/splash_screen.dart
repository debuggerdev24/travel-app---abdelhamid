import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';
import 'package:travel_app_abdelhamid/core/extensions/routes_extensions.dart';
import 'package:travel_app_abdelhamid/core/utils/pref_helper.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_app_abdelhamid/routes/user_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        final isLoggedIn = PrefHelper.isLoggedIn();
        context.pushReplacement(
          isLoggedIn
              ? UserAppRoutes.tabScreen.path
              : UserAppRoutes.signInScreen.path,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: SvgIcon(AppAssets.homeIcon, size: 100.sp)),
    );
  }
}
