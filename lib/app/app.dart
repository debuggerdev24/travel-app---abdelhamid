import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:travel_app_abdelhamid/core/theme/app_theme.dart';
import 'package:travel_app_abdelhamid/features/auth/provider/auth_provider.dart';
import 'package:travel_app_abdelhamid/features/auth/screens/guide_dashboard_screen.dart';
import 'package:travel_app_abdelhamid/features/auth/screens/otp_verification_screen.dart';
import 'package:travel_app_abdelhamid/features/chat/group_info_screen.dart';
import 'package:travel_app_abdelhamid/features/chat/live_location_screen.dart';
import 'package:travel_app_abdelhamid/features/chat/track_travelers_screen.dart';
import 'package:travel_app_abdelhamid/features/home/feedback_screen.dart';
import 'package:travel_app_abdelhamid/features/home/home_screen.dart';
import 'package:travel_app_abdelhamid/features/home/payment_option_screen.dart';
import 'package:travel_app_abdelhamid/features/home/room_details_screen.dart';
import 'package:travel_app_abdelhamid/features/profile/app_setting_screen.dart';
import 'package:travel_app_abdelhamid/features/profile/faq_screen.dart';
import 'package:travel_app_abdelhamid/features/profile/meet_our_team_screen.dart';
import 'package:travel_app_abdelhamid/features/profile/our_location_screen.dart';
import 'package:travel_app_abdelhamid/features/profile/privacy_policy_screen.dart';
import 'package:travel_app_abdelhamid/features/profile/profile_feed_back_screen.dart';
import 'package:travel_app_abdelhamid/features/profile/social_media_screen.dart';
import 'package:travel_app_abdelhamid/features/profile/terms_condition_screen.dart';
import 'package:travel_app_abdelhamid/features/tabs/tab_screen.dart';
import 'package:travel_app_abdelhamid/features/trip/dua_list_screen.dart';
import 'package:travel_app_abdelhamid/features/trip/emergency_contact_screen.dart';
import 'package:travel_app_abdelhamid/features/trip/health_saftey_screen.dart';
import 'package:travel_app_abdelhamid/features/trip/local_information_screen.dart';
import 'package:travel_app_abdelhamid/features/trip/offline_access_screen.dart';
import 'package:travel_app_abdelhamid/features/trip/trip_screen.dart';
import 'package:travel_app_abdelhamid/features/trip/umrah_guide_screen.dart';
import 'package:travel_app_abdelhamid/provider/chat/chat_provider.dart';
import 'package:travel_app_abdelhamid/provider/home/home_provider.dart' as hp;
import 'package:travel_app_abdelhamid/provider/home/person_details_provider.dart';
import 'package:travel_app_abdelhamid/provider/home/prayer_times_provider.dart';
import 'package:travel_app_abdelhamid/provider/home/user_flight_provider.dart';
import 'package:travel_app_abdelhamid/provider/profile/profile_provider.dart';
import 'package:travel_app_abdelhamid/provider/booking/trip_booking_provider.dart';
import 'package:travel_app_abdelhamid/provider/trip/my_trip_provider.dart';
import 'package:travel_app_abdelhamid/provider/trip/currency_converter_provider.dart';
import 'package:travel_app_abdelhamid/provider/theme_provider.dart';
import 'package:travel_app_abdelhamid/provider/profile/notification_provider.dart';
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
        ChangeNotifierProvider(create: (_) => NotificationProvider()..fetchNotifications()),
        ChangeNotifierProvider(create: (_) => FaqProvider()),
        ChangeNotifierProvider(create: (_) => SocialMediaState()),
        ChangeNotifierProvider(create: (_) => TermsConditionState()),
        ChangeNotifierProvider(create: (_) => PrivacyPolicyState()),
        ChangeNotifierProvider(create: (_) => OurLocationsState()),
        ChangeNotifierProvider(create: (_) => MeetOurTeamState()),
        ChangeNotifierProvider(create: (_) => AppSettingsState()),
        ChangeNotifierProvider(create: (_) => ProfileFeedbackState()),
        ChangeNotifierProvider(create: (_) => HomeTabState()),
        ChangeNotifierProvider(create: (_) => TabState()),
        ChangeNotifierProvider(create: (_) => TripScreenState()),
        ChangeNotifierProvider(create: (_) => PaymentOptionState()),
        ChangeNotifierProvider(create: (_) => RoomDetailsState()),
        ChangeNotifierProvider(create: (_) => FeedbackState()),
        ChangeNotifierProvider(create: (_) => PersonDetailsProvider()),
        ChangeNotifierProvider(create: (_) => OtpState()),
        ChangeNotifierProvider(create: (_) => GuideDashboardState()),
        ChangeNotifierProvider(create: (_) => EmergencyContactsState()),
        ChangeNotifierProvider(create: (_) => LocalInformationState()),
        ChangeNotifierProvider(create: (_) => HealthSafetyState()),
        ChangeNotifierProvider(create: (_) => DuaListState()),
        ChangeNotifierProvider(create: (_) => UmrahGuideState()),
        ChangeNotifierProvider(create: (_) => OfflineAccessState()),
        ChangeNotifierProvider(create: (_) => GroupInfoState()),
        ChangeNotifierProvider(create: (_) => LiveLocationState()),
        ChangeNotifierProvider(create: (_) => TrackTravelersState()),
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

