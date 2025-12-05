class ChatModel {
  final String name;
  final String message;
  final String time;
  final int unread;
  final String image;
  final bool isGroup;

  ChatModel({
    required this.name,
    required this.message,
    required this.time,
    required this.unread,
    required this.image,
    required this.isGroup,
  });
}
