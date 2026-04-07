import 'package:trael_app_abdelhamid/core/constants/app_constants.dart';
import 'package:trael_app_abdelhamid/core/network/base_api_service.dart';
import 'package:trael_app_abdelhamid/core/network/network_errors.dart';

/// REST client for `/api/chat/*` (mounted on the server root, not `/api/user`).
class ChatApiService {
  ChatApiService._internal();
  static final ChatApiService instance = ChatApiService._internal();

  final BaseApiService _api = BaseApiService.instance;

  String get _root => '${AppConstants.imageBaseUrl}/api/chat';

  void _ensureSuccess(dynamic response) {
    if (response is! Map) {
      throw ApiException(statusCode: 0, message: 'Invalid response from server.');
    }
    final s = response['status'];
    if (s == null || s == 1 || s == true) return;
    final msg = response['message']?.toString() ?? 'Request failed';
    throw ApiException(statusCode: 0, message: msg);
  }

  /// `GET /api/chat/conversations?userId=`
  Future<List<Map<String, dynamic>>> getConversations({
    required String userId,
    bool showErrorToast = false,
  }) async {
    final response = await _api.get(
      '$_root/conversations',
      queryParameters: {'userId': userId},
      showErrorToast: showErrorToast,
    );
    _ensureSuccess(response);
    final data = response['data'];
    if (data is! List) return [];
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// `GET /api/chat/history?chatId=&userId=&page=&limit=`
  Future<Map<String, dynamic>> getChatHistory({
    required String chatId,
    required String userId,
    int page = 1,
    int limit = 50,
    bool showErrorToast = false,
  }) async {
    final response = await _api.get(
      '$_root/history',
      queryParameters: {
        'chatId': chatId,
        'userId': userId,
        'page': page,
        'limit': limit,
      },
      showErrorToast: showErrorToast,
    );
    _ensureSuccess(response);
    final data = response['data'];
    if (data is Map) return Map<String, dynamic>.from(data);
    throw ApiException(statusCode: 0, message: 'Invalid chat history payload.');
  }

  /// `POST /api/chat/read` body: chatId, userId
  Future<void> markChatAsRead({
    required String chatId,
    required String userId,
    bool showErrorToast = false,
  }) async {
    final response = await _api.post(
      '$_root/read',
      body: {'chatId': chatId, 'userId': userId},
      showErrorToast: showErrorToast,
    );
    _ensureSuccess(response);
  }

  /// `POST /api/chat/location` — static location pin (server broadcasts via socket).
  Future<Map<String, dynamic>> sendLocation({
    required String chatId,
    required String userId,
    required double latitude,
    required double longitude,
    String? address,
    bool showErrorToast = true,
  }) async {
    final response = await _api.post(
      '$_root/location',
      body: {
        'chatId': chatId,
        'senderId': userId,
        'latitude': latitude,
        'longitude': longitude,
        if (address != null && address.isNotEmpty) 'address': address,
      },
      showErrorToast: showErrorToast,
    );
    _ensureSuccess(response);
    final data = response['data'];
    if (data is Map) return Map<String, dynamic>.from(data);
    throw ApiException(statusCode: 0, message: 'Invalid location response.');
  }
}
