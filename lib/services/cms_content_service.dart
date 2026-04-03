import 'package:trael_app_abdelhamid/core/constants/app_constants.dart';
import 'package:trael_app_abdelhamid/core/network/base_api_service.dart';
import 'package:trael_app_abdelhamid/core/network/endpoints.dart';
import 'package:trael_app_abdelhamid/core/network/network_errors.dart';
import 'package:trael_app_abdelhamid/model/cms/cms_models.dart';

/// FAQ, social links, terms & privacy from `/api` (Bearer auth).
class CmsContentService {
  CmsContentService._internal();
  static final CmsContentService instance = CmsContentService._internal();

  String _url(String path) => '${AppConstants.apiPublicRoot}$path';

  Future<List<FaqItem>> getFaqs({bool showErrorToast = false}) async {
    final response = await BaseApiService.instance.get(
      _url(Endpoints.faqList),
      showErrorToast: showErrorToast,
    );
    final data = response['data'];
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => FaqItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    if (data is Map) {
      return [FaqItem.fromJson(Map<String, dynamic>.from(data))];
    }
    return [];
  }

  Future<List<SocialLinkItem>> getSocials({bool showErrorToast = false}) async {
    final response = await BaseApiService.instance.get(
      _url(Endpoints.socialList),
      showErrorToast: showErrorToast,
    );
    final data = response['data'];
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => SocialLinkItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    if (data is Map) {
      return [SocialLinkItem.fromJson(Map<String, dynamic>.from(data))];
    }
    return [];
  }

  /// `type`: `terms` or `privacy` (backend defaults to privacy if omitted).
  /// Returns an empty list when the rules document is missing (`404` / "Rules not found").
  Future<List<RuleSection>> getRules(
    String type, {
    bool showErrorToast = false,
  }) async {
    try {
      final response = await BaseApiService.instance.get(
        _url(Endpoints.rulesGet),
        queryParameters: {'type': type},
        showErrorToast: showErrorToast,
      );
      final data = response['data'];
      if (data is! Map) return [];

      final key = type == 'terms' ? 'termsAndConditions' : 'privacyPolicy';
      final list = data[key];
      if (list is! List) return [];

      return list
          .whereType<Map>()
          .map((e) => RuleSection.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on ApiException catch (e) {
      if (e.statusCode == 404) return [];
      final msg = e.message.toLowerCase();
      if (msg.contains('rules not found')) return [];
      rethrow;
    }
  }
}
