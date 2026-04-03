class LocalInfoItem {
  final String? id;
  final String title;
  final String? shortDescription;
  final String? description;

  LocalInfoItem({
    this.id,
    required this.title,
    this.shortDescription,
    this.description,
  });

  factory LocalInfoItem.fromJson(Map<String, dynamic> json) {
    return LocalInfoItem(
      id: json['_id']?.toString(),
      title: json['title']?.toString() ?? '',
      shortDescription: json['shortDescription']?.toString(),
      description: json['description']?.toString(),
    );
  }
}
