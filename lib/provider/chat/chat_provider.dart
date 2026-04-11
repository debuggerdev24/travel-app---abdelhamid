import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:trael_app_abdelhamid/core/utils/jwt_user_id.dart';
import 'package:trael_app_abdelhamid/core/utils/log_helper.dart';
import 'package:trael_app_abdelhamid/core/utils/media_url.dart';
import 'package:trael_app_abdelhamid/core/utils/toast_helper.dart';
import 'package:trael_app_abdelhamid/model/chat/chat_model.dart';
import 'package:trael_app_abdelhamid/services/chat_api_service.dart';
import 'package:trael_app_abdelhamid/services/chat_socket_service.dart';

class ChatProvider extends ChangeNotifier {
  int selectedTabIndex = 0;

  List<ChatModel> _conversations = [];
  bool loadingConversations = false;
  String? conversationsError;

  String? _activeChatId;
  List<Map<String, dynamic>> _messages = [];
  bool loadingMessages = false;

  final List<StreamSubscription<dynamic>> _socketSubs = [];

  /// Debounced reload of the conversation list while the user is inside a chat
  /// (so last-message preview stays in sync with socket events).
  Timer? _conversationListRefreshDebounce;

  /// Deduplicates [enterChatRoom] when both list tap and detail screen call it.
  Future<void>? _roomLoadFuture;
  String? _roomLoadFutureChatId;

  List<Map<String, dynamic>> get messages => _messages;
  String? get activeChatId => _activeChatId;

  List<ChatModel> get chatList {
    if (selectedTabIndex == 0) return _conversations;
    if (selectedTabIndex == 1) {
      return _conversations.where((c) => c.isGroup).toList();
    }
    return _conversations.where((c) => !c.isGroup).toList();
  }

  void changeTab(int index) {
    selectedTabIndex = index;
    notifyListeners();
  }

  /// Prepares state for [enterChatRoom] **without** [notifyListeners].
  ///
  /// Call from the chat list **before** [context.push]. Skipping notification
  /// avoids rebuilding the whole [ChatScreen] [Consumer] (and other listeners)
  /// on the same frame as the tap, which was delaying the transition. The
  /// detail screen reads this state on its first [build].
  void primeChatOpen(String chatId) {
    if (chatId.isEmpty) return;
    _roomLoadFuture = null;
    _roomLoadFutureChatId = null;
    _detachSocketListeners();
    _activeChatId = chatId;
    _messages = [];
    loadingMessages = true;
  }

  Future<void> loadConversations({bool silent = false}) async {
    final uid = currentUserIdOrNull();
    if (uid == null) {
      conversationsError = 'Please sign in again to use chat.';
      if (!silent) notifyListeners();
      return;
    }

    loadingConversations = !silent;
    conversationsError = null;
    if (!silent) notifyListeners();

    try {
      await ChatSocketService.instance.connect(uid);
      final raw = await ChatApiService.instance.getConversations(
        userId: uid,
        showErrorToast: !silent,
      );
      _conversations = raw.map(_conversationFromJson).toList();
    } catch (e, st) {
      conversationsError = 'Could not load conversations.';
      LogHelper.instance.error('loadConversations', e, st);
    } finally {
      loadingConversations = false;
      notifyListeners();
    }
  }

  /// Loads history + socket for [chatId]. Called from [ChatDetailScreen]
  /// [didChangeDependencies]. The same in-flight [Future] is reused if invoked twice.
  Future<void> enterChatRoom({
    required String chatId,
    required String title,
    String? avatarUrl,
    required bool isGroup,
  }) {
    if (_roomLoadFutureChatId == chatId && _roomLoadFuture != null) {
      return _roomLoadFuture!;
    }

    final future = _enterChatRoomImpl(chatId: chatId);
    _roomLoadFutureChatId = chatId;
    _roomLoadFuture = future;
    future.whenComplete(() {
      if (_roomLoadFutureChatId == chatId) {
        _roomLoadFuture = null;
        _roomLoadFutureChatId = null;
      }
    });
    return future;
  }

  Future<void> _enterChatRoomImpl({required String chatId}) async {
    if (_activeChatId != chatId) {
      _detachSocketListeners();
      _activeChatId = chatId;
      _messages = [];
      loadingMessages = true;
      notifyListeners();
    }

    final uid = currentUserIdOrNull();
    if (uid == null) {
      if (_activeChatId == chatId) {
        loadingMessages = false;
        notifyListeners();
      }
      return;
    }

    final historyFuture = ChatApiService.instance.getChatHistory(
      chatId: chatId,
      userId: uid,
      showErrorToast: true,
    );

    await ChatSocketService.instance.connect(uid);
    if (_activeChatId != chatId) return;

    _attachSocketListeners();

    try {
      final raw = await historyFuture;
      if (_activeChatId != chatId) return;
      final list = raw['messages'];
      if (list is List) {
        _messages = list
            .whereType<Map>()
            .map((e) => _serverMessageToBubble(
                  Map<String, dynamic>.from(e),
                  uid,
                ))
            .toList();
      }
    } catch (e, st) {
      if (_activeChatId == chatId) {
        LogHelper.instance.error('enterChatRoom history', e, st);
      }
    } finally {
      if (_activeChatId == chatId) {
        loadingMessages = false;
        notifyListeners();
      }
    }
  }

  void leaveChatRoom() {
    _roomLoadFuture = null;
    _roomLoadFutureChatId = null;
    _conversationListRefreshDebounce?.cancel();
    _conversationListRefreshDebounce = null;
    _detachSocketListeners();
    _activeChatId = null;
    _messages = [];
    notifyListeners();
    // List was stale while messages arrived over the socket; sync from API
    // after the detail route is popped (dispose runs leaveChatRoom).
    loadConversations(silent: true);
  }

  void _scheduleConversationListRefreshFromSocket() {
    _conversationListRefreshDebounce?.cancel();
    _conversationListRefreshDebounce = Timer(
      const Duration(milliseconds: 400),
      () {
        _conversationListRefreshDebounce = null;
        loadConversations(silent: true);
      },
    );
  }

  void sendSocketText(String trimmed) {
    final cid = _activeChatId;
    final uid = currentUserIdOrNull();
    if (cid == null || uid == null || trimmed.isEmpty) return;
    ChatSocketService.instance.sendTextMessage(
      chatId: cid,
      senderId: uid,
      text: trimmed,
    );
  }

  Future<void> sharePinnedLocation({
    required double lat,
    required double lng,
  }) async {
    final cid = _activeChatId;
    final uid = currentUserIdOrNull();
    if (cid == null || uid == null) return;
    try {
      await ChatApiService.instance.sendLocation(
        chatId: cid,
        userId: uid,
        latitude: lat,
        longitude: lng,
      );
      await refreshActiveChatMessages();
      await loadConversations(silent: true);
    } catch (e, st) {
      LogHelper.instance.error('sharePinnedLocation', e, st);
    }
  }

  Future<bool> _ensureLocationReady() async {
    final serviceOn = await Geolocator.isLocationServiceEnabled();
    if (!serviceOn) {
      ToastHelper.showError('Please turn on location services.');
      return false;
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      ToastHelper.showError('Location permission is required.');
      return false;
    }
    return true;
  }

  /// GPS → static location message (`POST /api/chat/location`).
  Future<void> sendCurrentLocationFromGps() async {
    final cid = _activeChatId;
    final uid = currentUserIdOrNull();
    if (cid == null || uid == null) return;
    try {
      if (!await _ensureLocationReady()) return;
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await ChatApiService.instance.sendLocation(
        chatId: cid,
        userId: uid,
        latitude: pos.latitude,
        longitude: pos.longitude,
      );
      await refreshActiveChatMessages();
      await loadConversations(silent: true);
    } catch (e, st) {
      LogHelper.instance.error('sendCurrentLocationFromGps', e, st);
      ToastHelper.showError('Could not get current location.');
    }
  }

  /// GPS → live location session (`POST /api/chat/location/live/start`).
  Future<void> startLiveLocationFromGps({int durationMinutes = 60}) async {
    final cid = _activeChatId;
    final uid = currentUserIdOrNull();
    if (cid == null || uid == null) return;
    try {
      if (!await _ensureLocationReady()) return;
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await ChatApiService.instance.startLiveLocation(
        chatId: cid,
        userId: uid,
        latitude: pos.latitude,
        longitude: pos.longitude,
        durationMinutes: durationMinutes,
      );
      await refreshActiveChatMessages();
      await loadConversations(silent: true);
    } catch (e, st) {
      LogHelper.instance.error('startLiveLocationFromGps', e, st);
      ToastHelper.showError('Could not start live location.');
    }
  }

  /// Image file from gallery/camera (`POST /api/chat/upload`).
  Future<void> uploadChatImage(String filePath) async {
    final cid = _activeChatId;
    final uid = currentUserIdOrNull();
    if (cid == null || uid == null) return;
    try {
      await ChatApiService.instance.uploadChatFile(
        chatId: cid,
        senderId: uid,
        filePath: filePath,
      );
      await refreshActiveChatMessages();
      await loadConversations(silent: true);
    } catch (e, st) {
      LogHelper.instance.error('uploadChatImage', e, st);
      ToastHelper.showError('Could not send image. Please try again.');
    }
  }

  Future<void> editOwnTextMessage({
    required String messageId,
    required String newText,
  }) async {
    final uid = currentUserIdOrNull();
    if (uid == null) return;
    final trimmed = newText.trim();
    if (trimmed.isEmpty) return;
    try {
      await ChatApiService.instance.editMessage(
        messageId: messageId,
        userId: uid,
        text: trimmed,
      );
      await refreshActiveChatMessages();
      await loadConversations(silent: true);
    } catch (e, st) {
      LogHelper.instance.error('editOwnTextMessage', e, st);
    }
  }

  Future<void> deleteOwnMessage(String messageId) async {
    final uid = currentUserIdOrNull();
    if (uid == null) return;
    try {
      await ChatApiService.instance.deleteMessage(
        messageId: messageId,
        userId: uid,
      );
      await refreshActiveChatMessages();
      await loadConversations(silent: true);
    } catch (e, st) {
      LogHelper.instance.error('deleteOwnMessage', e, st);
    }
  }

  Future<void> refreshActiveChatMessages() async {
    final cid = _activeChatId;
    final uid = currentUserIdOrNull();
    if (cid == null || uid == null) return;
    try {
      final raw = await ChatApiService.instance.getChatHistory(
        chatId: cid,
        userId: uid,
        showErrorToast: false,
      );
      final list = raw['messages'];
      if (list is List) {
        _messages = list
            .whereType<Map>()
            .map(
              (e) => _serverMessageToBubble(
                Map<String, dynamic>.from(e),
                uid,
              ),
            )
            .toList();
        notifyListeners();
      }
    } catch (e, st) {
      LogHelper.instance.error('refreshActiveChatMessages', e, st);
    }
  }

  void _attachSocketListeners() {
    _detachSocketListeners();
    _socketSubs.add(
      ChatSocketService.instance.envelopeStream.listen(_handleEnvelope),
    );
    _socketSubs.add(
      ChatSocketService.instance.messageUpdatedStream.listen(_handleMessageUpdated),
    );
    _socketSubs.add(
      ChatSocketService.instance.messageDeletedStream.listen(_handleMessageDeleted),
    );
  }

  void _detachSocketListeners() {
    for (final s in _socketSubs) {
      s.cancel();
    }
    _socketSubs.clear();
  }

  void _handleEnvelope(Map<String, dynamic> env) {
    final msg = env['message'];
    if (msg is! Map) return;
    final m = Map<String, dynamic>.from(msg);
    final chatId = m['chat']?.toString();
    final myId = currentUserIdOrNull();
    if (myId == null) return;

    if (chatId != _activeChatId) {
      loadConversations(silent: true);
      return;
    }

    final bubble = _serverMessageToBubble(m, myId);
    _appendDedup(bubble);
    notifyListeners();
    _scheduleConversationListRefreshFromSocket();
  }

  void _handleMessageUpdated(Map<String, dynamic> e) {
    if (e['chatId']?.toString() != _activeChatId) return;
    final mid = e['messageId']?.toString();
    final msg = e['message'];
    if (mid == null || msg is! Map) return;
    final myId = currentUserIdOrNull();
    if (myId == null) return;
    final updated = _serverMessageToBubble(Map<String, dynamic>.from(msg), myId);
    final i = _messages.indexWhere((x) => x['_id']?.toString() == mid);
    if (i >= 0) {
      _messages[i] = updated;
      notifyListeners();
      _scheduleConversationListRefreshFromSocket();
    }
  }

  void _handleMessageDeleted(Map<String, dynamic> e) {
    if (e['chatId']?.toString() != _activeChatId) return;
    final mid = e['messageId']?.toString();
    if (mid == null) return;
    final i = _messages.indexWhere((x) => x['_id']?.toString() == mid);
    if (i >= 0) {
      final copy = Map<String, dynamic>.from(_messages[i]);
      copy['type'] = 'text';
      copy['message'] = 'This message was deleted';
      _messages[i] = copy;
      notifyListeners();
      _scheduleConversationListRefreshFromSocket();
    }
  }

  void _appendDedup(Map<String, dynamic> bubble) {
    final id = bubble['_id']?.toString();
    if (id != null && id.isNotEmpty) {
      if (_messages.any((x) => x['_id']?.toString() == id)) return;
    }
    _messages.add(bubble);
  }

  ChatModel _conversationFromJson(Map<String, dynamic> item) {
    final id = item['_id']?.toString() ?? '';
    final name = item['name']?.toString() ?? 'Chat';
    final isGroup = item['isGroup'] == true;
    final unread = _parseUnreadCount(item['unreadCount']);

    final last = item['lastMessage'];
    var preview = '';
    var time = '';
    if (last is Map) {
      final lm = Map<String, dynamic>.from(last);
      preview = _previewFromLastMessage(lm);
      time = _formatListTime(lm['createdAt']);
    }

    final imageUrl = resolveMediaUrl(item['imageUrl']?.toString());

    return ChatModel(
      chatId: id,
      name: name,
      message: preview,
      time: time,
      unread: unread,
      avatarUrl: imageUrl,
      isGroup: isGroup,
    );
  }

  String _previewFromLastMessage(Map<String, dynamic> lm) {
    if (lm['isDeleted'] == true) return 'Message deleted';
    final ct = lm['contentType']?.toString() ?? 'text';
    switch (ct) {
      case 'text':
        return lm['text']?.toString() ?? '';
      case 'location':
        return lm['isLiveLocation'] == true ? 'Live location' : 'Location';
      case 'voice':
        return 'Voice message';
      case 'file':
        return lm['fileName']?.toString() ?? '[File]';
      default:
        return '';
    }
  }

  Map<String, dynamic> _serverMessageToBubble(
    Map<String, dynamic> m,
    String myId,
  ) {
    final id = m['_id']?.toString();
    final sender = m['sender']?.toString() ?? '';
    final isMe = sender == myId;
    final time = _formatMsgTime(m['createdAt']);

    if (m['isDeleted'] == true) {
      return {
        '_id': id,
        'isMe': isMe,
        'type': 'text',
        'message': 'This message was deleted',
        'sender': m['senderName']?.toString() ?? '',
        'time': time,
        'edited': false,
      };
    }

    final ct = m['contentType']?.toString() ?? 'text';
    if (ct == 'location' ||
        (m['latitude'] != null && m['longitude'] != null)) {
      return {
        '_id': id,
        'isMe': isMe,
        'type': 'location',
        'lat': (m['latitude'] as num?)?.toDouble() ?? 0,
        'lng': (m['longitude'] as num?)?.toDouble() ?? 0,
        'time': time,
        'sender': m['senderName']?.toString() ?? '',
        'isLive': m['isLiveLocation'] == true,
      };
    }
    if (ct == 'voice') {
      return {
        '_id': id,
        'isMe': isMe,
        'type': 'audio',
        'message': '',
        'sender': m['senderName']?.toString() ?? '',
        'time': time,
        'duration': '00:00',
      };
    }
    if (ct == 'file') {
      final mime = m['mimeType']?.toString().toLowerCase() ?? '';
      final url = resolveMediaUrl(m['fileUrl']?.toString());
      final name = (m['fileName'] ?? '').toString().toLowerCase();
      final extImg = name.endsWith('.jpg') ||
          name.endsWith('.jpeg') ||
          name.endsWith('.png') ||
          name.endsWith('.gif') ||
          name.endsWith('.webp');
      if (mime.startsWith('image/') || extImg) {
        if (url != null && url.isNotEmpty) {
          return {
            '_id': id,
            'isMe': isMe,
            'type': 'image',
            'imageUrl': url,
            'sender': m['senderName']?.toString() ?? '',
            'time': time,
          };
        }
      }
      return {
        '_id': id,
        'isMe': isMe,
        'type': 'text',
        'message': m['fileName']?.toString() ?? '[File]',
        'sender': m['senderName']?.toString() ?? '',
        'time': time,
        'edited': false,
      };
    }

    final edited = m['editedAt'] != null &&
        m['editedAt'].toString().isNotEmpty &&
        m['editedAt'].toString() != 'null';

    return {
      '_id': id,
      'isMe': isMe,
      'type': 'text',
      'message': m['text']?.toString() ?? '',
      'sender': m['senderName']?.toString() ?? '',
      'time': time,
      'edited': edited,
    };
  }

  String _formatListTime(dynamic raw) {
    final d = _parseDate(raw);
    if (d == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(d.year, d.month, d.day);
    if (day == today) {
      return DateFormat.jm().format(d);
    }
    if (today.difference(day).inDays < 7) {
      return DateFormat.E().format(d);
    }
    return DateFormat.yMMMd().format(d);
  }

  String _formatMsgTime(dynamic raw) {
    final d = _parseDate(raw);
    if (d == null) return '';
    return DateFormat.jm().format(d);
  }

  DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw;
    if (raw is String) return DateTime.tryParse(raw);
    if (raw is Map) {
      final d = raw[r'$date'] ?? raw['\$date'] ?? raw['date'];
      if (d is String) return DateTime.tryParse(d);
      if (d is int) {
        return DateTime.fromMillisecondsSinceEpoch(d, isUtc: true).toLocal();
      }
    }
    return null;
  }

  int _parseUnreadCount(dynamic raw) {
    if (raw == null) return 0;
    if (raw is int) return raw < 0 ? 0 : raw;
    if (raw is double) {
      final n = raw.round();
      return n < 0 ? 0 : n;
    }
    return int.tryParse(raw.toString()) ?? 0;
  }

  @override
  void dispose() {
    _conversationListRefreshDebounce?.cancel();
    _conversationListRefreshDebounce = null;
    _detachSocketListeners();
    super.dispose();
  }
}
