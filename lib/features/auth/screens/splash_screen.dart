import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';
import 'package:travel_app_abdelhamid/core/network/base_api_service.dart';
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

  Future<void> _openNextScreen() async {
    if (!mounted) return;

    final access = PrefHelper.getAccessToken();

    // Guide demo account
    if (access == 'static_guide_token') {
      context.goNamed(UserAppRoutes.guideDashboard.name);
      return;
    }

    final hasAccess = access != null && access.isNotEmpty;
    final refresh = PrefHelper.getRefreshToken();
    final hasRefresh = refresh != null && refresh.isNotEmpty;

    // No session at all → login
    if (!hasAccess && !hasRefresh) {
      context.goNamed(UserAppRoutes.signInScreen.name);
      return;
    }

    // Access missing/expired but refresh exists → get a new access token
    if (PrefHelper.isAccessTokenExpiredOrMissing()) {
      final refreshed =
          await BaseApiService.instance.ensureValidAccessToken();
      if (!mounted) return;

      if (!refreshed) {
        await PrefHelper.clearTokens();
        context.goNamed(UserAppRoutes.signInScreen.name);
        return;
      }
    }

    context.goNamed(UserAppRoutes.tabScreen.name);
  }

  @override
  Widget build(BuildContext context) {
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
