import 'package:flutter/material.dart';
import 'package:travel_app_abdelhamid/core/network/base_api_service.dart';
import 'package:travel_app_abdelhamid/core/network/endpoints.dart';
import 'package:travel_app_abdelhamid/core/utils/log_helper.dart';
import 'package:travel_app_abdelhamid/core/utils/pref_helper.dart';
import 'package:travel_app_abdelhamid/model/profile/app_notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final BaseApiService _apiService = BaseApiService.instance;

  List<AppNotificationModel> _notifications = [];
  List<AppNotificationModel> get notifications => _notifications;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchNotifications() async {
    if (!PrefHelper.isLoggedIn()) {
      _notifications = [];
      _isLoading = false;
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get(Endpoints.notificationList, showErrorToast: false);
      if (response != null && response['data'] != null) {
        final List data = response['data'] is List ? response['data'] : (response['data']['data'] ?? []);
        _notifications = data.map((e) => AppNotificationModel.fromJson(e)).toList();
      } else if (response is List) {
        _notifications = response.map((e) => AppNotificationModel.fromJson(e)).toList();
      } else if (response is Map<String, dynamic> && response['notifications'] != null) {
        final List data = response['notifications'];
        _notifications = data.map((e) => AppNotificationModel.fromJson(e)).toList();
      }
    } catch (e) {
      LogHelper.instance.error('Error fetching notifications', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _apiService.post('${Endpoints.readNotification}/$id', showErrorToast: false);
      final index = _notifications.indexWhere((element) => element.id == id);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }
    } catch (e) {
      LogHelper.instance.error('Error marking notification as read', e);
    }
  }

  Future<void> sendDeviceToken(String token) async {
    try {
      await _apiService.post(
        Endpoints.deviceToken,
        body: {
          'device_token': token,
          'fcm_token': token,
          'fcmToken': token,
          'token': token,
        },
        showErrorToast: false,
      );
      LogHelper.instance.info('Device token sent successfully');
    } catch (e) {
      LogHelper.instance.error('Error sending device token', e);
    }
  }
}
