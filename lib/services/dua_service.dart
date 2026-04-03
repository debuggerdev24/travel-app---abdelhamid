import 'package:trael_app_abdelhamid/core/constants/app_constants.dart';
import 'package:trael_app_abdelhamid/core/network/base_api_service.dart';
import 'package:trael_app_abdelhamid/core/network/endpoints.dart';
import 'package:trael_app_abdelhamid/core/network/network_errors.dart';
import 'package:trael_app_abdelhamid/core/utils/log_helper.dart';
import 'package:trael_app_abdelhamid/model/dua/dua_item_model.dart';

class DuaService {
  DuaService._internal();
  static final DuaService instance = DuaService._internal();

  String get _apiRoot => AppConstants.imageBaseUrl;

  Future<List<DuaItemModel>> fetchDuas({bool showErrorToast = false}) async {
    final url = '$_apiRoot${Endpoints.duaFetchDetails}';
    final response = await BaseApiService.instance.get(
      url,
      showErrorToast: showErrorToast,
    );
    _ensureSuccessBody(response);
    final data = response['data'];
    if (data is! List) return <DuaItemModel>[];
    final out = <DuaItemModel>[];
    for (var i = 0; i < data.length; i++) {
      final e = data[i];
      if (e is! Map) continue;
      try {
        out.add(DuaItemModel.fromJson(e.cast<String, dynamic>()));
      } catch (err, st) {
        LogHelper.instance.error('fetchDuas item $i', err, st);
      }
    }
    return out;
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
