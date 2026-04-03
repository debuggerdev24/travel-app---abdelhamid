import 'package:trael_app_abdelhamid/core/constants/app_constants.dart';
import 'package:trael_app_abdelhamid/core/network/base_api_service.dart';
import 'package:trael_app_abdelhamid/core/network/endpoints.dart';
import 'package:trael_app_abdelhamid/core/network/network_errors.dart';
import 'package:trael_app_abdelhamid/core/utils/log_helper.dart';
import 'package:trael_app_abdelhamid/model/essential/currency_info_model.dart';
import 'package:trael_app_abdelhamid/model/essential/emergency_contacts_model.dart';
import 'package:trael_app_abdelhamid/model/essential/health_tip_model.dart';
import 'package:trael_app_abdelhamid/model/essential/local_info_model.dart';
import 'package:trael_app_abdelhamid/model/essential/packing_list_model.dart';

/// Backend returns HTTP 400 with `{ status: 0, message: "... not found" }` when a section has no CMS data.
bool _isEssentialNotFoundEmpty(ApiException e, {required String messageMustContain}) {
  if (e.statusCode == 400) return true;
  final raw = e.data; 
  if (raw is Map) {
    final m = Map<String, dynamic>.from(raw);
    if (m['status'] == 0) {
      final msg = m['message']?.toString().toLowerCase() ?? '';
      return msg.contains(messageMustContain.toLowerCase()) &&
          msg.contains('not found');
    }
  }
  return false;
}

class EssentialService {
  EssentialService._internal();
  static final EssentialService instance = EssentialService._internal();

  String get _apiRoot => AppConstants.imageBaseUrl;

  Future<PackingListResponse> getPackingList({bool showErrorToast = false}) async {
    try {
      final url = '$_apiRoot${Endpoints.essentialPackingList}';
      final response = await BaseApiService.instance.get(
        url,
        showErrorToast: showErrorToast,
      );

      final data = response['data'];
      if (data is Map) {
        return PackingListResponse.fromJson(data.cast<String, dynamic>());
      }
      throw Exception('Packing list not found');
    } on ApiException catch (e) {
      // If backend returns "No Packing List Found" etc.
      if (e.statusCode == 404) {
        return PackingListResponse(categories: const []);
      }
      rethrow;
    }
  }

  Future<CurrencyInfoData?> getCurrencyInfo({
    bool showErrorToast = false,
  }) async {
    try {
      final url = '$_apiRoot${Endpoints.essentialCurrencyInfo}';
      final response = await BaseApiService.instance.get(
        url,
        showErrorToast: showErrorToast,
      );
      _ensureSuccessBody(response);
      final data = response['data'];
      if (data is Map) {
        try {
          return CurrencyInfoData.fromJson(data.cast<String, dynamic>());
        } catch (e, st) {
          LogHelper.instance.error(
            'getCurrencyInfo parse',
            e,
            st,
          );
          throw ApiException(
            statusCode: 0,
            message: 'Invalid currency data from server.',
          );
        }
      }
      return null;
    } on ApiException catch (e) {
      if (_isEssentialNotFoundEmpty(e, messageMustContain: 'currency')) {
        return null;
      }
      rethrow;
    }
  }

  Future<EmergencyContactsData?> getEmergencyContacts({
    bool showErrorToast = false,
  }) async {
    try {
      final url = '$_apiRoot${Endpoints.essentialEmergencyContacts}';
      final response = await BaseApiService.instance.get(
        url,
        showErrorToast: showErrorToast,
      );
      _ensureSuccessBody(response);
      final data = response['data'];
      if (data is Map) {
        try {
          return EmergencyContactsData.fromJson(data.cast<String, dynamic>());
        } catch (e, st) {
          LogHelper.instance.error(
            'getEmergencyContacts parse',
            e,
            st,
          );
          throw ApiException(
            statusCode: 0,
            message: 'Invalid emergency contacts data from server.',
          );
        }
      }
      return null;
    } on ApiException catch (e) {
      if (_isEssentialNotFoundEmpty(e, messageMustContain: 'emergency')) {
        return null;
      }
      rethrow;
    }
  }

  Future<List<LocalInfoItem>> getLocalInfo({
    bool showErrorToast = false,
  }) async {
    final url = '$_apiRoot${Endpoints.essentialLocalInfo}';
    final response = await BaseApiService.instance.get(
      url,
      showErrorToast: showErrorToast,
    );
    _ensureSuccessBody(response);
    final data = response['data'];
    if (data is! List) return <LocalInfoItem>[];
    final out = <LocalInfoItem>[];
    for (var i = 0; i < data.length; i++) {
      final e = data[i];
      if (e is! Map) continue;
      try {
        out.add(LocalInfoItem.fromJson(e.cast<String, dynamic>()));
      } catch (err, st) {
        LogHelper.instance.error(
          'getLocalInfo item $i',
          err,
          st,
        );
      }
    }
    return out;
  }

  Future<List<HealthTipItem>> getHealthTips({
    bool showErrorToast = false,
  }) async {
    final url = '$_apiRoot${Endpoints.essentialHealthTips}';
    final response = await BaseApiService.instance.get(
      url,
      showErrorToast: showErrorToast,
    );
    _ensureSuccessBody(response);
    final data = response['data'];
    if (data is! List) return <HealthTipItem>[];
    final out = <HealthTipItem>[];
    for (var i = 0; i < data.length; i++) {
      final e = data[i];
      if (e is! Map) continue;
      try {
        out.add(HealthTipItem.fromJson(e.cast<String, dynamic>()));
      } catch (err, st) {
        LogHelper.instance.error(
          'getHealthTips item $i',
          err,
          st,
        );
      }
    }
    return out;
  }

  /// Backend uses `{ status: 1, message, data }`. Missing [status] is treated as success.
  void _ensureSuccessBody(dynamic response) {
    if (response is! Map) {
      throw ApiException(
        statusCode: 0,
        message: 'Invalid response from server.',
      );
    }
    final s = response['status'];
    if (s == null || s == 1 || s == true) return;
    final msg = response['message']?.toString() ?? 'Request failed';
    throw ApiException(statusCode: 0, message: msg);
  }
}






