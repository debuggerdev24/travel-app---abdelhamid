import 'package:trael_app_abdelhamid/core/constants/app_constants.dart';
import 'package:trael_app_abdelhamid/core/network/base_api_service.dart';
import 'package:trael_app_abdelhamid/core/network/endpoints.dart';
import 'package:trael_app_abdelhamid/core/utils/prayer_time_helpers.dart';
import 'package:trael_app_abdelhamid/model/prayer/prayer_time_model.dart';

class PrayerService {
  PrayerService._internal();
  static final PrayerService instance = PrayerService._internal();

  Future<List<PrayerTimeItem>> fetchPrayerTimes({bool showErrorToast = false}) async {
    final url = '${AppConstants.apiPublicRoot}${Endpoints.prayerDetails}';
    final response = await BaseApiService.instance.get(
      url,
      showErrorToast: showErrorToast,
    );
    final data = response['data'];
    if (data is List) {
      final raw = data
          .whereType<Map>()
          .map((e) => PrayerTimeItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return sortPrayerItemsByTimeOfDay(raw);
    }
    if (data is Map) {
      return sortPrayerItemsByTimeOfDay([
        PrayerTimeItem.fromJson(Map<String, dynamic>.from(data)),
      ]);
    }
    return [];
  }
}
