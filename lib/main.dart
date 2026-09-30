import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:travel_app_abdelhamid/core/constants/app_constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:travel_app_abdelhamid/app/app.dart';
import 'package:travel_app_abdelhamid/core/utils/pref_helper.dart';
import 'package:travel_app_abdelhamid/firebase_options.dart';
import 'package:travel_app_abdelhamid/services/push_notification_service.dart';
import 'package:easy_localization/easy_localization.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await PrefHelper.init();

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await PushNotificationService.instance.init();
  }

  if (AppConstants.stripePublishableKey.isNotEmpty) {
    Stripe.publishableKey = AppConstants.stripePublishableKey;
  }
  
  if (!kIsWeb &&
      Platform.isIOS &&
      AppConstants.stripeApplePayMerchantId.isNotEmpty) {
    Stripe.merchantIdentifier = AppConstants.stripeApplePayMerchantId;
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('nl'),
        Locale('fr'),
        Locale('ar'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const App(),
    ),
  );
}
 

/*

TRV-2026-8CD78C
testuser12@mailinator.com
Pass@123


**********************
TRV-2026-F8B8AF
shwetapatel.dds@gmail.com
Test@123

* git add . && git commit -m "30th Sep" && git push origin dev


┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────
│ [http-error] [GET] https://api.temheed.com/api/user/trips/upcoming-bookings
│ Status: 401
│ Message: This exception was thrown because the response has a status code of 401 and RequestOptions.validateStatus was configured to throw for this status code.
│ The status code of 401 has the following meaning: "Client error - the request contains bad syntax or cannot be fulfilled"
│ Read more about status codes at https://developer.mozilla.org/en-US/docs/Web/HTTP/Status
│ In order to resolve this exception you typically have either to verify and fix your request code or you have to fix the server code.
│ 
│ Data: {
│   "status": 0,
│   "message": "Invalid or Expired Token"
│ }
│ Headers: {
│   "connection": [
│     "keep-alive"
│   ],
│   "x-powered-by": [
│     "Express"
│   ],
│   "date": [
│     "Wed, 30 Sep 2026 11:02:26 GMT"
│   ],
│   "access-control-allow-origin": [
│     "*"
│   ],
│   "content-length": [
│     "49"
│   ],
│   "etag": [
│     "W/\"31-wUQ/UJ0FFlneTUR+4TPDF/Ie2eQ\""
│   ],
│   "content-type": [
│     "application/json; charset=utf-8"
│   ],
│   "server": [
│     "nginx/1.24.0 (Ubuntu)"
│   ]
│ }
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────
❌ [ERROR]: API Error: GET /trips/upcoming-bookings
   Details: [401] Invalid or Expired Token

*/