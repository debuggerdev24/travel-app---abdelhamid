import 'package:trael_app_abdelhamid/core/constants/app_constants.dart';
import 'package:trael_app_abdelhamid/core/network/base_api_service.dart';
import 'package:trael_app_abdelhamid/core/network/endpoints.dart';
import 'package:trael_app_abdelhamid/core/network/network_errors.dart';
import 'package:trael_app_abdelhamid/core/utils/log_helper.dart';
import 'package:trael_app_abdelhamid/model/umrah/umrah_guide_step_model.dart';

/// CMS stores Umrah steps as [Tour Guide] documents (see backend `tourGuideController`).
class UmrahGuideService {
  UmrahGuideService._internal();
  static final UmrahGuideService instance = UmrahGuideService._internal();

  String get _apiRoot => AppConstants.imageBaseUrl;

  Future<List<UmrahGuideStepModel>> fetchSteps({bool showErrorToast = false}) async {
    final url = '$_apiRoot${Endpoints.tourGuideFetchDetails}';
    final response = await BaseApiService.instance.get(
      url,
      showErrorToast: showErrorToast,
    );
    _ensureSuccessBody(response);
    final data = response['data'];
    return _parseSteps(data);
  }

  List<UmrahGuideStepModel> _parseSteps(dynamic data) {
    if (data == null) return <UmrahGuideStepModel>[];
    if (data is List) {
      final out = <UmrahGuideStepModel>[];
      for (var i = 0; i < data.length; i++) {
        final e = data[i];
        if (e is! Map) continue;
        try {
          out.add(
            UmrahGuideStepModel.fromJson(e.cast<String, dynamic>()),
          );
        } catch (err, st) {
          LogHelper.instance.error('fetchSteps item $i', err, st);
        }
      }
      return out;
    }
    if (data is Map) {
      try {
        return [
          UmrahGuideStepModel.fromJson(data.cast<String, dynamic>()),
        ];
      } catch (err, st) {
        LogHelper.instance.error('fetchSteps single', err, st);
      }
    }
    return <UmrahGuideStepModel>[];
  }

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
