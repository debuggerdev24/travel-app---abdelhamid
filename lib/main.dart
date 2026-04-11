import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:trael_app_abdelhamid/core/constants/app_constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:trael_app_abdelhamid/app/app.dart';
import 'package:trael_app_abdelhamid/core/utils/pref_helper.dart';
import 'package:trael_app_abdelhamid/firebase_options.dart';
import 'package:trael_app_abdelhamid/services/push_notification_service.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid || Platform.isIOS) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await PushNotificationService.instance.init();
  }   

  await PrefHelper.init();

  if (AppConstants.stripePublishableKey.isNotEmpty) {
    Stripe.publishableKey = AppConstants.stripePublishableKey;
  }
  if (Platform.isIOS && AppConstants.stripeApplePayMerchantId.isNotEmpty) {
    Stripe.merchantIdentifier = AppConstants.stripeApplePayMerchantId;
  }

  runApp(const App());
}
 

/*

TRV-2026-1B9E29
demouser@mailinator.com
Pass@123

*/