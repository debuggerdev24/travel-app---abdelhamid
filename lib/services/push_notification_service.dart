import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handles permission requests, token retrieval, and local token caching.
class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  static const _tokenKey = 'fcm_token';
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'Used for important FCM notifications.',
        importance: Importance.max,
      );
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();

    await _messaging.setAutoInitEnabled(true);
    await _requestPermission();
    await _initLocalNotifications();

    // Cache the current token then keep it updated.
    await _persistToken(await _messaging.getToken());
    _messaging.onTokenRefresh.listen(_persistToken);

    // Show notifications when the app is in the foreground.
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<NotificationSettings> _requestPermission() async {
    return _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  Future<void> _initLocalNotifications() async {  
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(initSettings);
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('🔥 MESSAGE FOREGROUND: ${message.data}');
    final notification = message.notification;
    final android = notification?.android;

    final title = notification?.title ?? message.data['title']?.toString();
    final body = notification?.body ?? message.data['body']?.toString();

    if (title == null && body == null) return;

    // Use a unique id so new notifications do not overwrite the previous one.
    final notificationId =
        DateTime.now().millisecondsSinceEpoch.remainder(1000000);

    _localNotifications.show(
      notificationId,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          icon: android?.smallIcon ?? '@mipmap/ic_launcher',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: message.data.isEmpty ? null : message.data.toString(),
    );
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    // Hook to navigate users to specific screens when they tap a notification.
    // Example: use message.data to deep-link inside the app.
    print('🔥 MESSAGE OPENED APP: ${message.data}');
  }

  Future<void> _persistToken(String? token) async {
    if (token == null || token.isEmpty) return;
    print('🔥 FCM TOKEN: $token');
    await _prefs?.setString(_tokenKey, token);
  }

  Future<String?> getCachedToken() async {
    _prefs ??= await SharedPreferences.getInstance();
    print('🔥 FCM TOKEN: ${_prefs?.getString(_tokenKey)}');
    return _prefs?.getString(_tokenKey);
  }
}
