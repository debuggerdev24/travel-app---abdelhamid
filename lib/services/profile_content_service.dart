import 'package:trael_app_abdelhamid/core/constants/app_constants.dart';
import 'package:trael_app_abdelhamid/core/network/base_api_service.dart';
import 'package:trael_app_abdelhamid/core/network/endpoints.dart';
import 'package:trael_app_abdelhamid/model/profile/office_location_model.dart';
import 'package:trael_app_abdelhamid/model/profile/team_member_model.dart';

/// Locations & team under `/api/...`, app/trip reviews under `/api/user/...`.
class ProfileContentService {
  ProfileContentService._internal();
  static final ProfileContentService instance = ProfileContentService._internal();

  String _public(String path) => '${AppConstants.apiPublicRoot}$path';

  /// Country → office rows (sorted by country on the server).
  Future<Map<String, List<OfficeLocation>>> getLocations({
    bool showErrorToast = false,
  }) async {
    final response = await BaseApiService.instance.get(
      _public(Endpoints.locationGetList),
      showErrorToast: showErrorToast,
    );
    final data = response['data'];
    if (data is! Map) return {};

    final out = <String, List<OfficeLocation>>{};
    for (final entry in data.entries) {
      final key = entry.key.toString();
      final raw = entry.value;
      if (raw is! List) continue;
      final list = <OfficeLocation>[];
      for (final e in raw) {
        if (e is Map) {
          list.add(
            OfficeLocation.fromJson(Map<String, dynamic>.from(e)),
          );
        }
      }
      if (list.isNotEmpty) {
        out[key] = list;
      }
    }
    return out;
  }

  Future<List<TeamMemberModel>> getTeamMembers({
    bool showErrorToast = false,
  }) async {
    final response = await BaseApiService.instance.get(
      _public(Endpoints.teamGetMembers),
      showErrorToast: showErrorToast,
    );
    final data = response['data'];
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => TeamMemberModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    if (data is Map) {
      return [
        TeamMemberModel.fromJson(Map<String, dynamic>.from(data)),
      ];
    }
    return [];
  }

  /// [tripId] required when [forTrip] is true.
  Future<void> submitReview({
    required bool forTrip,
    required int rating,
    required String review,
    String? tripId,
    bool showErrorToast = true,
  }) async {
    final body = <String, dynamic>{
      'purpose': forTrip ? 'trip' : 'app',
      'rating': rating,
      'review': review,
    };

    await BaseApiService.instance.post(
      Endpoints.reviewsNewReview,
      body: body,
      queryParameters: forTrip && tripId != null ? {'tripId': tripId} : null,
      showErrorToast: showErrorToast,
    );
  }
}
