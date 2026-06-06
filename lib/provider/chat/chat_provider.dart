import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:travel_app_abdelhamid/core/utils/jwt_user_id.dart';
import 'package:travel_app_abdelhamid/core/utils/log_helper.dart';
import 'package:travel_app_abdelhamid/core/utils/media_url.dart';
import 'package:travel_app_abdelhamid/core/utils/server_media_url.dart';
import 'package:travel_app_abdelhamid/core/utils/toast_helper.dart';
import 'package:travel_app_abdelhamid/model/chat/chat_model.dart';
import 'package:travel_app_abdelhamid/services/chat_api_service.dart';
import 'package:travel_app_abdelhamid/services/chat_socket_service.dart';

class ChatProvider extends ChangeNotifier {
  int selectedTabIndex = 0;

  List<ChatModel> _conversations = [];
  bool loadingConversations = false;
  String? conversationsError;

  String? _activeChatId;
  List<Map<String, dynamic>> _messages = [];
  bool loadingMessages = false;

  final List<StreamSubscription<dynamic>> _socketSubs = [];
  bool _socketListenersAttached = false;

  /// Debounced reload when socket payload is incomplete (unknown chat, edits, deletes).
  Timer? _conversationListRefreshDebounce;

  /// Debounced mark-as-read while viewing an active chat (WhatsApp-style).
  Timer? _markReadDebounce;

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

  void updateConversationAvatar(String chatId, String avatarUrl) {
    if (avatarUrl.isEmpty) return;
    final idx = _conversations.indexWhere((c) => c.chatId == chatId);
    if (idx < 0) return;
    _conversations[idx] = _conversations[idx].copyWith(avatarUrl: avatarUrl);
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
    _activeChatId = chatId;
    _messages = [];
    loadingMessages = true;
    _setConversationUnread(chatId, 0);
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
      _ensureSocketListenersAttached();
      final raw = await ChatApiService.instance.getConversations(
        userId: uid,
        showErrorToast: !silent,
      );
      _conversations = raw.map(_conversationFromJson).toList();
      _sortConversationsByRecent();
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

    _ensureSocketListenersAttached();

    try {
      final raw = await historyFuture;
      if (_activeChatId != chatId) return;
      final list = raw['messages'];
      if (list is List) {
        final senderAvatars = mergeParticipantImages(
          senderAvatarMapFromMessages(list),
          raw,
        );
        _messages = list
            .whereType<Map>()
            .map(
              (e) => _serverMessageToBubble(
                Map<String, dynamic>.from(e),
                uid,
                senderAvatars: senderAvatars,
              ),
            )
            .toList();
      }
      await _markChatAsRead(chatId);
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
    _markReadDebounce?.cancel();
    _markReadDebounce = null;
    _activeChatId = null;
    _messages = [];
    notifyListeners();
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
        final senderAvatars = mergeParticipantImages(
          senderAvatarMapFromMessages(list),
          raw,
        );
        _messages = list
            .whereType<Map>()
            .map(
              (e) => _serverMessageToBubble(
                Map<String, dynamic>.from(e),
                uid,
                senderAvatars: senderAvatars,
              ),
            )
            .toList();
        notifyListeners();
      }
    } catch (e, st) {
      LogHelper.instance.error('refreshActiveChatMessages', e, st);
    }
  }

  void _ensureSocketListenersAttached() {
    if (_socketListenersAttached) return;
    _socketSubs.add(
      ChatSocketService.instance.envelopeStream.listen(_handleEnvelope),
    );
    _socketSubs.add(
      ChatSocketService.instance.messageUpdatedStream.listen(
        _handleMessageUpdated,
      ),
    );
    _socketSubs.add(
      ChatSocketService.instance.messageDeletedStream.listen(
        _handleMessageDeleted,
      ),
    );
    _socketListenersAttached = true;
  }

  void _detachSocketListeners() {
    for (final s in _socketSubs) {
      s.cancel();
    }
    _socketSubs.clear();
    _socketListenersAttached = false;
  }

  Future<void> _markChatAsRead(String chatId) async {
    final uid = currentUserIdOrNull();
    if (uid == null || chatId.isEmpty) return;
    _setConversationUnread(chatId, 0);
    notifyListeners();
    try {
      await ChatApiService.instance.markChatAsRead(
        chatId: chatId,
        userId: uid,
        showErrorToast: false,
      );
    } catch (e, st) {
      LogHelper.instance.error('markChatAsRead', e, st);
    }
  }

  void _scheduleMarkActiveChatRead() {
    final chatId = _activeChatId;
    if (chatId == null) return;
    _markReadDebounce?.cancel();
    _markReadDebounce = Timer(const Duration(milliseconds: 300), () {
      _markReadDebounce = null;
      if (_activeChatId == chatId) {
        unawaited(_markChatAsRead(chatId));
      }
    });
  }

  void _setConversationUnread(String chatId, int unread) {
    final idx = _conversations.indexWhere((c) => c.chatId == chatId);
    if (idx < 0) return;
    _conversations[idx] = _conversations[idx].copyWith(unread: unread);
  }

  void _promoteConversation(
    String chatId, {
    required String preview,
    required String time,
    required DateTime? lastMessageAt,
    required int unread,
  }) {
    final idx = _conversations.indexWhere((c) => c.chatId == chatId);
    if (idx < 0) {
      _scheduleConversationListRefreshFromSocket();
      return;
    }
    final updated = _conversations[idx].copyWith(
      message: preview,
      time: time,
      lastMessageAt: lastMessageAt,
      unread: unread,
    );
    _conversations.removeAt(idx);
    _conversations.insert(0, updated);
  }

  void _sortConversationsByRecent() {
    _conversations.sort((a, b) {
      final at = a.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bt = b.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bt.compareTo(at);
    });
  }

  void _applyIncomingMessageToInbox(
    String chatId,
    Map<String, dynamic> m,
    String myId,
  ) {
    final sender = m['sender']?.toString() ?? '';
    final isMe = sender == myId;
    final idx = _conversations.indexWhere((c) => c.chatId == chatId);
    if (idx < 0) {
      _scheduleConversationListRefreshFromSocket();
      return;
    }

    final old = _conversations[idx];
    final preview = _listPreviewFromMessage(
      m,
      isGroup: old.isGroup,
      isMe: isMe,
    );
    final time = _formatListTime(m['createdAt']);
    final lastMessageAt = _parseDate(m['createdAt']) ?? DateTime.now();
    final isActive = chatId == _activeChatId;

    var unread = old.unread;
    if (isActive) {
      unread = 0;
    } else if (!isMe) {
      final isSameLast =
          old.lastMessageAt == lastMessageAt && old.message == preview;
      if (!isSameLast) unread = old.unread + 1;
    }

    _promoteConversation(
      chatId,
      preview: preview,
      time: time,
      lastMessageAt: lastMessageAt,
      unread: unread,
    );
    notifyListeners();

    if (isActive && !isMe) {
      _scheduleMarkActiveChatRead();
    }
  }

  Map<String, String> _senderAvatarsFromExistingMessages() {
    final map = <String, String>{};
    for (final msg in _messages) {
      final sid = msg['senderId']?.toString() ?? msg['sender']?.toString();
      final url = msg['senderAvatarUrl']?.toString();
      if (sid != null && sid.isNotEmpty && url != null && url.isNotEmpty) {
        map[sid] = url;
      }
    }
    return map;
  }

  void _handleEnvelope(Map<String, dynamic> env) {
    final msg = env['message'];
    if (msg is! Map) return;
    final m = Map<String, dynamic>.from(msg);
    final chatId = m['chat']?.toString();
    final myId = currentUserIdOrNull();
    if (myId == null || chatId == null || chatId.isEmpty) return;

    _applyIncomingMessageToInbox(chatId, m, myId);

    if (chatId != _activeChatId) return;

    final senderAvatars = senderAvatarMapFromMessages([m])
      ..addAll(_senderAvatarsFromExistingMessages());
    final bubble = _serverMessageToBubble(
      m,
      myId,
      senderAvatars: senderAvatars,
    );
    _appendDedup(bubble);
    notifyListeners();
  }

  void _handleMessageUpdated(Map<String, dynamic> e) {
    final chatId = e['chatId']?.toString();
    final mid = e['messageId']?.toString();
    final msg = e['message'];
    if (chatId == null || mid == null || msg is! Map) return;
    final myId = currentUserIdOrNull();
    if (myId == null) return;

    if (chatId == _activeChatId) {
      final senderAvatars = _senderAvatarsFromExistingMessages();
      final updated = _serverMessageToBubble(
        Map<String, dynamic>.from(msg),
        myId,
        senderAvatars: senderAvatars,
      );
      final i = _messages.indexWhere((x) => x['_id']?.toString() == mid);
      if (i >= 0) {
        _messages[i] = updated;
        notifyListeners();
      }
    }
    _scheduleConversationListRefreshFromSocket();
  }

  void _handleMessageDeleted(Map<String, dynamic> e) {
    final chatId = e['chatId']?.toString();
    final mid = e['messageId']?.toString();
    if (chatId == null || mid == null) return;

    if (chatId == _activeChatId) {
      final i = _messages.indexWhere((x) => x['_id']?.toString() == mid);
      if (i >= 0) {
        final copy = Map<String, dynamic>.from(_messages[i]);
        copy['type'] = 'text';
        copy['message'] = 'This message was deleted';
        _messages[i] = copy;
        notifyListeners();
      }
    }
    _scheduleConversationListRefreshFromSocket();
  }

  void _appendDedup(Map<String, dynamic> bubble) {
    final id = bubble['_id']?.toString();
    if (id != null && id.isNotEmpty) {
      if (_messages.any((x) => x['_id']?.toString() == id)) return;
    }
    _messages.add(bubble);
  }

  String? _groupConversationAvatarUrl(Map<String, dynamic> item) {
    // Prefer explicit group/trip image fields — not `imageUrl`, which is often a member photo.
    return serverMediaUrl(
      item['groupImage']?.toString() ??
          item['groupImageUrl']?.toString() ??
          item['image']?.toString() ??
          (item['group'] is Map
              ? (item['group'] as Map)['imageUrl']?.toString()
              : null) ??
          (item['trip'] is Map
              ? (item['trip'] as Map)['imageUrl']?.toString()
              : null),
    );
  }

  ChatModel _conversationFromJson(Map<String, dynamic> item) {
    final id = item['_id']?.toString() ?? '';
    final name = item['name']?.toString() ?? 'Chat';
    final isGroup = item['isGroup'] == true;
    final unread = _parseUnreadCount(item['unreadCount']);

    final last = item['lastMessage'];
    var preview = '';
    var time = '';
    DateTime? lastMessageAt;
    if (last is Map) {
      final lm = Map<String, dynamic>.from(last);
      final uid = currentUserIdOrNull();
      final sender = lm['sender']?.toString() ?? '';
      final isMe = uid != null && sender == uid;
      preview = _listPreviewFromMessage(lm, isGroup: isGroup, isMe: isMe);
      time = _formatListTime(lm['createdAt']);
      lastMessageAt = _parseDate(lm['createdAt']);
    }

    final imageUrl = isGroup
        ? _groupConversationAvatarUrl(item)
        : serverMediaUrl(
            item['imageUrl']?.toString() ?? item['profilePicture']?.toString(),
          );

    String? groupId;
    if (isGroup) {
      groupId =
          item['groupId']?.toString() ??
          (item['group'] is Map
              ? (item['group'] as Map)['_id']?.toString()
              : null) ??
          id;
    }

    return ChatModel(
      chatId: id,
      groupId: groupId,
      name: name,
      message: preview,
      time: time,
      unread: unread,
      lastMessageAt: lastMessageAt,
      avatarUrl: imageUrl,
      isGroup: isGroup,
    );
  }

  String _listPreviewFromMessage(
    Map<String, dynamic> lm, {
    required bool isGroup,
    required bool isMe,
  }) {
    final base = _previewFromLastMessage(lm);
    if (isGroup && isMe && base.isNotEmpty) return 'You: $base';
    return base;
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
        return _filePreviewLabel(lm);
      default:
        return '';
    }
  }

  String _filePreviewLabel(Map<String, dynamic> lm) {
    final mime = lm['mimeType']?.toString().toLowerCase() ?? '';
    final name = (lm['fileName'] ?? '').toString().toLowerCase();
    if (mime.startsWith('image/') ||
        name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png') ||
        name.endsWith('.gif') ||
        name.endsWith('.webp')) {
      return 'Photo';
    }
    return lm['fileName']?.toString() ?? '[File]';
  }

  Map<String, dynamic> _serverMessageToBubble(
    Map<String, dynamic> m,
    String myId, {
    Map<String, String>? senderAvatars,
  }) {
    final id = m['_id']?.toString();
    final sender = m['sender']?.toString() ?? '';
    final isMe = sender == myId;
    final time = _formatMsgTime(m['createdAt']);
    final senderAvatarUrl = profilePictureFromMessage(
      m,
      senderAvatars: senderAvatars,
    );

    Map<String, dynamic> baseFields() => {
      'senderId': sender,
      if (senderAvatarUrl != null) 'senderAvatarUrl': senderAvatarUrl,
    };

    if (m['isDeleted'] == true) {
      return {
        '_id': id,
        'isMe': isMe,
        'type': 'text',
        'message': 'This message was deleted',
        'sender': m['senderName']?.toString() ?? '',
        'time': time,
        'edited': false,
        ...baseFields(),
      };
    }

    final ct = m['contentType']?.toString() ?? 'text';
    if (ct == 'location' || (m['latitude'] != null && m['longitude'] != null)) {
      return {
        '_id': id,
        'isMe': isMe,
        'type': 'location',
        'lat': (m['latitude'] as num?)?.toDouble() ?? 0,
        'lng': (m['longitude'] as num?)?.toDouble() ?? 0,
        'time': time,
        'sender': m['senderName']?.toString() ?? '',
        'isLive': m['isLiveLocation'] == true,
        ...baseFields(),
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
        ...baseFields(),
      };
    }
    if (ct == 'file') {
      final mime = m['mimeType']?.toString().toLowerCase() ?? '';
      final url = resolveMediaUrl(m['fileUrl']?.toString());
      final name = (m['fileName'] ?? '').toString().toLowerCase();
      final extImg =
          name.endsWith('.jpg') ||
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
            ...baseFields(),
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
        ...baseFields(),
      };
    }

    final edited =
        m['editedAt'] != null &&
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
      ...baseFields(),
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
    _markReadDebounce?.cancel();
    _markReadDebounce = null;
    _detachSocketListeners();
    super.dispose();
  }
}
