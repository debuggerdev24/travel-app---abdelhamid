class DuaItemModel {
  final String id;
  final String title;
  final String description;
  final String? audioPath;

  DuaItemModel({
    required this.id,
    required this.title,
    required this.description,
    this.audioPath,
  });

  factory DuaItemModel.fromJson(Map<String, dynamic> json) {
    return DuaItemModel(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      audioPath: json['audio']?.toString(),
    );
  }
}
