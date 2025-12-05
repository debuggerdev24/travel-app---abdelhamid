import 'dart:io';

import 'package:go_router/go_router.dart';
import 'package:trael_app_abdelhamid/core/constants/extensions/routes_extensions.dart';
import 'package:trael_app_abdelhamid/routes/user_routes.dart';
import 'package:trael_app_abdelhamid/screens/auth/forgot_password_screen.dart';
import 'package:trael_app_abdelhamid/screens/auth/otp_verification_screen.dart';
import 'package:trael_app_abdelhamid/screens/auth/sign_in_screen.dart';
import 'package:trael_app_abdelhamid/screens/auth/sign_up_screen.dart';
import 'package:trael_app_abdelhamid/screens/chat/live_location_screen.dart';
import 'package:trael_app_abdelhamid/screens/home/feedback_screen.dart';
import 'package:trael_app_abdelhamid/screens/home/package_summary_screen.dart';
import 'package:trael_app_abdelhamid/screens/home/payment_failed_screen.dart';
import 'package:trael_app_abdelhamid/screens/home/payment_option_screen.dart';
import 'package:trael_app_abdelhamid/screens/home/payment_successfull_screen.dart';
import 'package:trael_app_abdelhamid/screens/home/personal_details_screen.dart';
import 'package:trael_app_abdelhamid/screens/home/personal_details_screen2.dart';
import 'package:trael_app_abdelhamid/screens/home/room_details_screen.dart';
import 'package:trael_app_abdelhamid/screens/home/trip_details.dart';
import 'package:trael_app_abdelhamid/screens/profile/app_setting_screen.dart';
import 'package:trael_app_abdelhamid/screens/profile/edit_profile_screen.dart';
import 'package:trael_app_abdelhamid/screens/profile/faq_screen.dart';
import 'package:trael_app_abdelhamid/screens/profile/meet_our_team_screen.dart';
import 'package:trael_app_abdelhamid/screens/profile/our_location_screen.dart';
import 'package:trael_app_abdelhamid/screens/profile/prayer_time_screen.dart';
import 'package:trael_app_abdelhamid/screens/profile/privacy_policy_screen.dart';
import 'package:trael_app_abdelhamid/screens/profile/profile_feed_back_screen.dart';
import 'package:trael_app_abdelhamid/screens/profile/social_media_screen.dart';
import 'package:trael_app_abdelhamid/screens/profile/terms_condition_screen.dart';
import 'package:trael_app_abdelhamid/screens/tabs/tab_screen.dart';
import 'package:trael_app_abdelhamid/screens/trip/add_document_screen.dart';
import 'package:trael_app_abdelhamid/screens/trip/currency_money_screen.dart';
import 'package:trael_app_abdelhamid/screens/trip/dua_list_screen.dart';
import 'package:trael_app_abdelhamid/screens/trip/emergency_contact_screen.dart';
import 'package:trael_app_abdelhamid/screens/trip/health_saftey_screen.dart';
import 'package:trael_app_abdelhamid/screens/trip/hotel_voucher_screen.dart';
import 'package:trael_app_abdelhamid/screens/trip/local_information_screen.dart';
import 'package:trael_app_abdelhamid/screens/trip/packing_list_screen.dart';
import 'package:trael_app_abdelhamid/screens/trip/payment_history.dart';
import 'package:trael_app_abdelhamid/screens/trip/travel_insurance_screen.dart';
import 'package:trael_app_abdelhamid/screens/trip/trip_screen.dart';
import 'package:trael_app_abdelhamid/screens/trip/umrah_guide_screen.dart';
import 'package:trael_app_abdelhamid/screens/trip/view_receipt_screen.dart';
import 'package:trael_app_abdelhamid/screens/trip/view_screen.dart';
import 'package:trael_app_abdelhamid/screens/chat/chat_screen.dart';
import 'package:trael_app_abdelhamid/screens/chat/chat_detail_screen.dart';
import 'package:trael_app_abdelhamid/screens/chat/group_info_screen.dart';

class UserAppRoute {
  static final GoRouter goRouter = GoRouter(
    initialLocation: UserAppRoutes.signUpScreen.path,
    routes: routes,
  );

  static final List<RouteBase> routes = [
    GoRoute(
      path: UserAppRoutes.signUpScreen.path,
      name: UserAppRoutes.signUpScreen.name,
      builder: (context, state) {
        return SignUpScreen();
      },
    ),
    GoRoute(
      path: UserAppRoutes.signInScreen.path,
      name: UserAppRoutes.signInScreen.name,
      builder: (context, state) {
        return SignInScreen();
      },
    ),
    GoRoute(
      path: UserAppRoutes.forgotPasswordScreen.path,
      name: UserAppRoutes.forgotPasswordScreen.name,
      builder: (context, state) {
        return ForgotPasswordScreen();
      },
    ),
    GoRoute(
      path: UserAppRoutes.verifyOtpScreen.path,
      name: UserAppRoutes.verifyOtpScreen.name,
      builder: (context, state) {
        return OtpVerificationScreen();
      },
    ),
    GoRoute(
      path: UserAppRoutes.tabScreen.path,
      name: UserAppRoutes.tabScreen.name,
      builder: (context, state) {
        return TabScreen();
      },
    ),
    GoRoute(
      path: UserAppRoutes.tripDetailsScreen.path,
      name: UserAppRoutes.tripDetailsScreen.name,
      builder: (context, state) {
        return TripDetailsScreen();
      },
    ),
    GoRoute(
      path: UserAppRoutes.feedbackScreen.path,
      name: UserAppRoutes.feedbackScreen.name,
      builder: (context, state) {
        return FeedbackScreen();
      },
    ),
    GoRoute(
      path: UserAppRoutes.roomDetailScren.path,
      name: UserAppRoutes.roomDetailScren.name,
      builder: (context, state) {
        return RoomDetailsScreen();
      },
    ),
    GoRoute(
      path: UserAppRoutes.personalDetailsScreen.path,
      name: UserAppRoutes.personalDetailsScreen.name,
      builder: (context, state) {
        return PersonalDetailsScreen();
      },
    ),
    GoRoute(
      path: UserAppRoutes.personalDetailsScreen2.path,
      name: UserAppRoutes.personalDetailsScreen2.name,
      builder: (context, state) {
        return FamilyMembersScreen();
      },
    ),
    GoRoute(
      path: UserAppRoutes.packageSummaryScreen.path,
      name: UserAppRoutes.packageSummaryScreen.name,
      builder: (context, state) {
        return PackageSummaryScreen();
      },
    ),
    GoRoute(
      path: UserAppRoutes.paymentOptionScreen.path,
      name: UserAppRoutes.paymentOptionScreen.name,
      builder: (context, state) {
        return PaymentOptionScreen();
      },
    ),
    GoRoute(
      path: UserAppRoutes.paymentSuccessfullScreen.path,
      name: UserAppRoutes.paymentSuccessfullScreen.name,
      builder: (context, state) {
        return PaymentSuccessfullScreen();
      },
    ),
    GoRoute(
      path: UserAppRoutes.paymentFailedScreen.path,
      name: UserAppRoutes.paymentFailedScreen.name,
      builder: (context, state) {
        return PaymentFailedScreen();
      },
    ),
    GoRoute(
      path: UserAppRoutes.paymentHistoryScreen.path,
      name: UserAppRoutes.paymentHistoryScreen.name,
      builder: (context, state) {
        return PaymentHistoryScreen();
      },
    ),
    GoRoute(
      path: UserAppRoutes.viewPaymentReceiptScreen.path,
      name: UserAppRoutes.viewPaymentReceiptScreen.name,
      builder: (context, state) {
        return ViewReceiptScreen();
      },
    ),
    GoRoute(
      path: UserAppRoutes.myTripScreen.path,
      name: UserAppRoutes.myTripScreen.name,
      builder: (context, state) {
        return TripScreen();
      },
    ),
    GoRoute(
      path: UserAppRoutes.packageListScreen.path,
      name: UserAppRoutes.packageListScreen.name,
      builder: (context, state) {
        return PackageListScreen();
      },
    ),
    GoRoute(
      path: UserAppRoutes.currencyMoneyScreen.path,
      name: UserAppRoutes.currencyMoneyScreen.name,
      builder: (context, state) {
        return CurrencyMoneyScreen();
      },
    ),
    GoRoute(
      path: UserAppRoutes.emergencyContactScreen.path,
      name: UserAppRoutes.emergencyContactScreen.name,
      builder: (context, state) {
        return EmergencyContactsScreen();
      },
    ),
    GoRoute(
      path: UserAppRoutes.localInformationScreen.path,
      name: UserAppRoutes.localInformationScreen.name,
      builder: (context, state) {
        return LocalInformationScreen();
      },
    ),
    GoRoute(
      path: UserAppRoutes.umrahGuideScreen.path,
      name: UserAppRoutes.umrahGuideScreen.name,
      builder: (context, state) {
        return UmrahGuideScreen();
      },
    ),
    GoRoute(
      path: UserAppRoutes.duaListScreen.path,
      name: UserAppRoutes.duaListScreen.name,
      builder: (context, state) {
        return DuaListScreen();
      },
    ),
    GoRoute(
      path: UserAppRoutes.healthSafteyScreen.path,
      name: UserAppRoutes.healthSafteyScreen.name,
      builder: (context, state) {
        return HealthSafetyScreen();
      },
    ),
    GoRoute(
      path: UserAppRoutes.addDocumentScreen.path,
      name: UserAppRoutes.addDocumentScreen.name,
      builder: (context, state) {
        return AddDocumentScreen();
      },
    ),
    GoRoute(
      path: UserAppRoutes.viewDocumetScreen.path,
      name: UserAppRoutes.viewDocumetScreen.name,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;

        return FullScreenDocumentViewer(
          file: data['file'] as File?,
          assetImage: data['assetImage'] as String,
          title: data['title'] as String,
        );
      },
    ),
    GoRoute(
      path: UserAppRoutes.hotelVoucherScreen.path,
      name: UserAppRoutes.hotelVoucherScreen.name,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;

        return HotelVoucherScreen(
          imageFile: data['imageFile'] as String?,
          hotelName: data['hotelName'] as String,
          address: data['address'] as String,
        );
      },
    ),

    GoRoute(
      path: UserAppRoutes.travelInsuranceScreen.path,
      name: UserAppRoutes.travelInsuranceScreen.name,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return TravelInsuranceScreen(
          imageFile: data['imageFile'] as String?,
          hotelName: data['hotelName'] as String,
          address: data['address'] as String,
        );
      },
    ),
    GoRoute(
      path: UserAppRoutes.chatScreen.path,
      name: UserAppRoutes.chatScreen.name,
      builder: (context, state) {
        return ChatScreen();
      },
    ),
    GoRoute(
      path: UserAppRoutes.chatDetailScreen.path,
      name: UserAppRoutes.chatDetailScreen.name,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return ChatDetailScreen(
          name: data['name'],
          image: data['image'],
          isGroup: data['isGroup'] ?? false,
        );
      },
    ),
    GoRoute(
      path: UserAppRoutes.groupInfoScreen.path,
      name: UserAppRoutes.groupInfoScreen.name,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return GroupInfoScreen(name: data['name'], image: data['image']);
      },
    ),
     GoRoute(
      path: UserAppRoutes.liveLocationScreen.path,
      name: UserAppRoutes.liveLocationScreen.name,
      builder: (context, state) {
        return LiveLocationScreen();
      },
    ),
     GoRoute(
      path: UserAppRoutes.editProfileScreen.path,
      name: UserAppRoutes.editProfileScreen.name,
      builder: (context, state) {
        return EditProfileScreen();
      },
    ),
      GoRoute(
      path: UserAppRoutes.faqScreen.path,
      name: UserAppRoutes.faqScreen.name,
      builder: (context, state) {
        return FaqScreen();
      },
    ),
      GoRoute(
      path: UserAppRoutes.socialMediaScreen.path,
      name: UserAppRoutes.socialMediaScreen.name,
      builder: (context, state) {
        return SocialMediaScreen();
      },
    ),
       GoRoute(
      path: UserAppRoutes.termsConditionScreen.path,
      name: UserAppRoutes.termsConditionScreen.name,
      builder: (context, state) {
        return TermsConditionScreen();
      },
    ),
    GoRoute(
      path: UserAppRoutes.privacyPolicyScreen.path,
      name: UserAppRoutes.privacyPolicyScreen.name,
      builder: (context, state) {
        return PrivacyPolicyScreen();
      },
    ),
      GoRoute(
      path: UserAppRoutes.ourLocationsScreen.path,
      name: UserAppRoutes.ourLocationsScreen.name,
      builder: (context, state) {
        return OurLocationsScreen();
      },
    ),
        GoRoute(
      path: UserAppRoutes.meetOurTeamScreen.path,
      name: UserAppRoutes.meetOurTeamScreen.name,
      builder: (context, state) {
        return MeetOurTeamScreen();
      },
    ),
     GoRoute(
      path: UserAppRoutes.appSettignScreen.path,
      name: UserAppRoutes.appSettignScreen.name,
      builder: (context, state) {
        return AppSettingsScreen();
      },
    ),
      GoRoute(
      path: UserAppRoutes.profileFeedbackScreen.path,
      name: UserAppRoutes.profileFeedbackScreen.name,
      builder: (context, state) {
        return ProfileFeedbackScreen();
      },
    ),
     GoRoute(
      path: UserAppRoutes.prayerTimesScreen.path,
      name: UserAppRoutes.prayerTimesScreen.name,
      builder: (context, state) {
        return PrayerTimesScreen();
      },
    ),
  ];
}
