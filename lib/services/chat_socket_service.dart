import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:trael_app_abdelhamid/core/constants/app_constants.dart';
import 'package:trael_app_abdelhamid/core/utils/log_helper.dart';

/// Socket.IO client aligned with [travel-admin-backend/socket/socketHandler.js].
class ChatSocketService {
  ChatSocketService._internal();
  static final ChatSocketService instance = ChatSocketService._internal();

  io.Socket? _socket;
  String? _joinedUserId;

  final StreamController<Map<String, dynamic>> _envelope =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _messageUpdated =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _messageDeleted =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get envelopeStream => _envelope.stream;
  Stream<Map<String, dynamic>> get messageUpdatedStream => _messageUpdated.stream;
  Stream<Map<String, dynamic>> get messageDeletedStream => _messageDeleted.stream;

  bool get isConnected => _socket?.connected == true;

  Future<void> connect(String userId) async {
    if (userId.isEmpty) return;
    if (_socket?.connected == true && _joinedUserId == userId) return;

    disconnect();

    final socket = io.io(
      AppConstants.chatSocketBaseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableReconnection()
          .build(),
    );

    socket.on('connect', (_) {
      socket.emit('join', userId);
      _joinedUserId = userId;
    });

    socket.on('connect_error', (err) {
      LogHelper.instance.debug('Chat socket connect_error: $err');
    });

    socket.on('receiveMessage', _pushEnvelope);
    socket.on('messageSent', _pushEnvelope);
    socket.on('messageUpdated', (data) => _pushMap(_messageUpdated, data));
    socket.on('messageDeleted', (data) => _pushMap(_messageDeleted, data));

    socket.connect();
    _socket = socket;
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _joinedUserId = null;
  }

  void sendTextMessage({
    required String chatId,
    required String senderId,
    String senderModel = 'user',
    required String text,
  }) {
    _socket?.emit('sendMessage', {
      'chatId': chatId,
      'senderId': senderId,
      'senderModel': senderModel,
      'contentType': 'text',
      'text': text,
    });
  }

  void emitTyping({
    required String chatId,
    required String senderId,
    required bool isTyping,
  }) {
    _socket?.emit('typing', {
      'chatId': chatId,
      'senderId': senderId,
      'isTyping': isTyping,
    });
  }

  void _pushEnvelope(dynamic data) {
    final map = _asMap(data);
    if (map != null) _envelope.add(map);
  }

  void _pushMap(StreamController<Map<String, dynamic>> sink, dynamic data) {
    final map = _asMap(data);
    if (map != null) sink.add(map);
  }

  Map<String, dynamic>? _asMap(dynamic data) {
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }
}
