class UmrahGuideStepModel {
  final String id;
  final String title;
  final List<String> bullets;

  UmrahGuideStepModel({
    required this.id,
    required this.title,
    required this.bullets,
  });

  factory UmrahGuideStepModel.fromJson(Map<String, dynamic> json) {
    final desc = json['description'];
    final bullets = <String>[];
    if (desc is List) {
      for (final e in desc) {
        final s = e?.toString().trim() ?? '';
        if (s.isNotEmpty) bullets.add(s);
      }
    } else if (desc is String && desc.trim().isNotEmpty) {
      bullets.add(desc.trim());
    }

    return UmrahGuideStepModel(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      bullets: bullets,
    );
  }
}
