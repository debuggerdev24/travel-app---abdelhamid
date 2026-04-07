import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trael_app_abdelhamid/core/utils/jwt_user_id.dart';
import 'package:trael_app_abdelhamid/core/utils/log_helper.dart';
import 'package:trael_app_abdelhamid/core/utils/media_url.dart';
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

  Future<void> enterChatRoom({
    required String chatId,
    required String title,
    String? avatarUrl,
    required bool isGroup,
  }) async {
    _detachSocketListeners();
    _activeChatId = chatId;
    _messages = [];
    loadingMessages = true;
    notifyListeners();

    final uid = currentUserIdOrNull();
    if (uid == null) {
      loadingMessages = false;
      notifyListeners();
      return;
    }

    await ChatSocketService.instance.connect(uid);
    _attachSocketListeners();

    try {
      final raw = await ChatApiService.instance.getChatHistory(
        chatId: chatId,
        userId: uid,
        showErrorToast: true,
      );
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
      LogHelper.instance.error('enterChatRoom history', e, st);
    } finally {
      loadingMessages = false;
      notifyListeners();
    }
  }

  void leaveChatRoom() {
    _detachSocketListeners();
    _activeChatId = null;
    _messages = [];
    notifyListeners();
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
      await loadConversations(silent: true);
    } catch (e, st) {
      LogHelper.instance.error('sharePinnedLocation', e, st);
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
    final unreadRaw = item['unreadCount'];
    final unread = unreadRaw is int
        ? unreadRaw
        : int.tryParse(unreadRaw?.toString() ?? '0') ?? 0;

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
      return {
        '_id': id,
        'isMe': isMe,
        'type': 'text',
        'message': m['fileName']?.toString() ?? '[File]',
        'sender': m['senderName']?.toString() ?? '',
        'time': time,
      };
    }

    return {
      '_id': id,
      'isMe': isMe,
      'type': 'text',
      'message': m['text']?.toString() ?? '',
      'sender': m['senderName']?.toString() ?? '',
      'time': time,
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
    return null;
  }

  bool _isRecording = false;
  bool _showAttachmentMenu = false;

  bool get isRecording => _isRecording;
  bool get showAttachmentMenu => _showAttachmentMenu;

  void toggleRecording() {
    _isRecording = !_isRecording;
    notifyListeners();
  }

  void startRecording() {
    _isRecording = true;
    _showAttachmentMenu = false;
    notifyListeners();
  }

  void stopRecording() {
    _isRecording = false;
    notifyListeners();
  }

  void toggleAttachmentMenu() {
    _showAttachmentMenu = !_showAttachmentMenu;
    notifyListeners();
  }

  void closeAttachmentMenu() {
    _showAttachmentMenu = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _detachSocketListeners();
    super.dispose();
  }
}
