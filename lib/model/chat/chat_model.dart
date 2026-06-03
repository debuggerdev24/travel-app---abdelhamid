import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';

class ChatModel {
  final String chatId;
  final String? groupId;
  final String name;
  final String message;
  final String time;
  final int unread;
  final DateTime? lastMessageAt;

  /// Local asset path used when [avatarUrl] is null.
  final String image;
  final String? avatarUrl;
  final bool isGroup;

  ChatModel({
    required this.chatId,
    this.groupId,
    required this.name,
    required this.message,
    required this.time,
    required this.unread,
    this.lastMessageAt,
    this.image = AppAssets.profilePhoto,
    this.avatarUrl,
    required this.isGroup,
  });

  ChatModel copyWith({
    String? name,
    String? message,
    String? time,
    int? unread,
    DateTime? lastMessageAt,
    String? image,
    String? avatarUrl,
    bool? isGroup,
    String? groupId,
  }) {
    return ChatModel(
      chatId: chatId,
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      message: message ?? this.message,
      time: time ?? this.time,
      unread: unread ?? this.unread,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      image: image ?? this.image,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isGroup: isGroup ?? this.isGroup,
    );
  }
}
