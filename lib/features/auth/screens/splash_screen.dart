import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';
import 'package:travel_app_abdelhamid/core/utils/pref_helper.dart';
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
    Future.delayed(const Duration(seconds: 2), _openNextScreen);
  }

  void _openNextScreen() {
    if (!mounted) return;

    if (!PrefHelper.isLoggedIn()) {
      context.goNamed(UserAppRoutes.signInScreen.name);
      return;
    }

    if (PrefHelper.getAccessToken() == 'static_guide_token') {
      context.goNamed(UserAppRoutes.guideDashboard.name);
      return;
    }

    context.goNamed(UserAppRoutes.tabScreen.name);
  }

  @override
  Widget build(BuildContext context) {
    // final logoWidth = MediaQuery.sizeOf(context).width * 0.62;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          AppAssets.splashLogo,
          width: 120,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
