class AppNotificationModel {
  final int id;
  final String title;
  final String message;
  final String? time;
  final String? icon;
  final bool isPremium;
  final bool isRead;

  AppNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.time,
    this.icon,
    this.isPremium = false,
    this.isRead = false,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: _parseId(json['id']),
      title: json['title']?.toString() ?? '',
      message: (json['message'] ?? json['body'])?.toString() ?? '',
      time: json['created_at']?.toString() ?? json['time']?.toString(),
      icon: json['icon']?.toString(),
      isPremium: json['is_premium'] == true || json['is_premium'] == 1 || json['is_premium'] == '1',
      isRead: json['is_read'] == true || json['is_read'] == 1 || json['is_read'] == '1',
    );
  }

  static int _parseId(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  AppNotificationModel copyWith({
    int? id,
    String? title,
    String? message,
    String? time,
    String? icon,
    bool? isPremium,
    bool? isRead,
  }) {
    return AppNotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      icon: icon ?? this.icon,
      isPremium: isPremium ?? this.isPremium,
      isRead: isRead ?? this.isRead,
    );
  }
}
