import 'package:go_router/go_router.dart';
import 'package:trael_app_abdelhamid/core/extensions/routes_extensions.dart';
import 'package:trael_app_abdelhamid/routes/user_routes.dart';
import 'package:trael_app_abdelhamid/features/profile/app_setting_screen.dart';
import 'package:trael_app_abdelhamid/features/profile/edit_profile_screen.dart';
import 'package:trael_app_abdelhamid/features/profile/faq_screen.dart';
import 'package:trael_app_abdelhamid/features/profile/meet_our_team_screen.dart';
import 'package:trael_app_abdelhamid/features/profile/our_location_screen.dart';
import 'package:trael_app_abdelhamid/features/profile/prayer_time_screen.dart';
import 'package:trael_app_abdelhamid/features/profile/privacy_policy_screen.dart';
import 'package:trael_app_abdelhamid/features/profile/profile_feed_back_screen.dart';
import 'package:trael_app_abdelhamid/features/profile/social_media_screen.dart';
import 'package:trael_app_abdelhamid/features/profile/terms_condition_screen.dart';

List<RouteBase> get profileRoutes => [
  GoRoute(
    path: UserAppRoutes.editProfileScreen.path,
    name: UserAppRoutes.editProfileScreen.name,
    builder: (context, state) => EditProfileScreen(),
  ),
  GoRoute(
    path: UserAppRoutes.faqScreen.path,
    name: UserAppRoutes.faqScreen.name,
    builder: (context, state) => FaqScreen(),
  ),
  GoRoute(
    path: UserAppRoutes.socialMediaScreen.path,
    name: UserAppRoutes.socialMediaScreen.name,
    builder: (context, state) => SocialMediaScreen(),
  ),
  GoRoute(
    path: UserAppRoutes.termsConditionScreen.path,
    name: UserAppRoutes.termsConditionScreen.name,
    builder: (context, state) => TermsConditionScreen(),
  ),
  GoRoute(
    path: UserAppRoutes.privacyPolicyScreen.path,
    name: UserAppRoutes.privacyPolicyScreen.name,
    builder: (context, state) => PrivacyPolicyScreen(),
  ),
  GoRoute(
    path: UserAppRoutes.ourLocationsScreen.path,
    name: UserAppRoutes.ourLocationsScreen.name,
    builder: (context, state) => OurLocationsScreen(),
  ),
  GoRoute(
    path: UserAppRoutes.meetOurTeamScreen.path,
    name: UserAppRoutes.meetOurTeamScreen.name,
    builder: (context, state) => MeetOurTeamScreen(),
  ),
  GoRoute(
    path: UserAppRoutes.appSettignScreen.path,
    name: UserAppRoutes.appSettignScreen.name,
    builder: (context, state) => AppSettingsScreen(),
  ),
  GoRoute(
    path: UserAppRoutes.profileFeedbackScreen.path,
    name: UserAppRoutes.profileFeedbackScreen.name,
    builder: (context, state) => ProfileFeedbackScreen(),
  ),
  GoRoute(
    path: UserAppRoutes.prayerTimesScreen.path,
    name: UserAppRoutes.prayerTimesScreen.name,
    builder: (context, state) => PrayerTimesScreen(),
  ),
];
