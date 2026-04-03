/// Row from prayer times API (`name` + `time` string from admin).
class PrayerTimeItem {
  final String? id;
  final String name;
  final String time;

  PrayerTimeItem({this.id, required this.name, required this.time});

  factory PrayerTimeItem.fromJson(Map<String, dynamic> json) {
    return PrayerTimeItem(
      id: json['_id']?.toString(),
      name: (json['name'] ?? '').toString(),
      time: (json['time'] ?? '').toString(),
    );
  }
}
