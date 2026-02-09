import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:trael_app_abdelhamid/core/theme/app_theme.dart';
import 'package:trael_app_abdelhamid/features/auth/provider/auth_provider.dart';
import 'package:trael_app_abdelhamid/provider/chat/chat_provider.dart';
import 'package:trael_app_abdelhamid/provider/home/home_provider.dart' as hp;
import 'package:trael_app_abdelhamid/provider/profile/profile_provider.dart';
import 'package:trael_app_abdelhamid/provider/trip/my_trip_provider.dart';
import 'package:trael_app_abdelhamid/routes/go_routes.dart';

/// Root widget of the application.
/// Wraps the app with [MultiProvider] and configures [MaterialApp.router].
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => hp.TripProvider()),
        ChangeNotifierProvider(create: (_) => MyTripProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(402, 874),
        builder: (context, child) {
          return MaterialApp.router(
            title: 'TRAEL APP',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            routerConfig: UserAppRoute.goRouter,
          );
        },
      ),
    );
  }
}
