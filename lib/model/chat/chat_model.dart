import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';

class ChatModel {
  final String chatId;
  final String name;
  final String message;
  final String time;
  final int unread;
  /// Local asset path used when [avatarUrl] is null.
  final String image;
  final String? avatarUrl;
  final bool isGroup;

  ChatModel({
    required this.chatId,
    required this.name,
    required this.message,
    required this.time,
    required this.unread,
    this.image = AppAssets.profilePhoto,
    this.avatarUrl,
    required this.isGroup,
  });
}
