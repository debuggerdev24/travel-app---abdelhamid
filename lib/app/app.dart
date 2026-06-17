import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:travel_app_abdelhamid/core/theme/app_theme.dart';
import 'package:travel_app_abdelhamid/features/auth/provider/auth_provider.dart';
import 'package:travel_app_abdelhamid/provider/chat/chat_provider.dart';
import 'package:travel_app_abdelhamid/provider/home/home_provider.dart' as hp;
import 'package:travel_app_abdelhamid/provider/home/prayer_times_provider.dart';
import 'package:travel_app_abdelhamid/provider/home/user_flight_provider.dart';
import 'package:travel_app_abdelhamid/provider/profile/profile_provider.dart';
import 'package:travel_app_abdelhamid/provider/booking/trip_booking_provider.dart';
import 'package:travel_app_abdelhamid/provider/trip/my_trip_provider.dart';
import 'package:travel_app_abdelhamid/provider/trip/currency_converter_provider.dart';
import 'package:travel_app_abdelhamid/provider/theme_provider.dart';
import 'package:travel_app_abdelhamid/routes/go_routes.dart';
import 'package:easy_localization/easy_localization.dart';

/// Root widget of the application.
/// Wraps the app with [MultiProvider] and configures [MaterialApp.router].
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => hp.TripProvider()),
        ChangeNotifierProvider(create: (_) => PrayerTimesProvider()),
        ChangeNotifierProvider(create: (_) => MyTripProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        // Load profile once at app startup (Bearer token must exist in PrefHelper).
        ChangeNotifierProvider(
          create: (_) => ProfileProvider()..loadProfile(force: true),
        ),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TripBookingProvider()),
        ChangeNotifierProvider(create: (_) => FlightProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CurrencyConverterProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(402, 874),
        builder: (context, child) {
          return MaterialApp.router(
            title: 'TRAEL APP'.tr(),
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: context.watch<ThemeProvider>().themeMode,
            routerConfig: UserAppRoute.goRouter,
          );
        },
      ),
    );
  }
}
