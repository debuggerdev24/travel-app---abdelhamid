class HealthTipItem {
  final String? id;
  final int tipNumber;
  final String tipTitle;
  final String? description;
  final String? bannerImagePath;

  HealthTipItem({
    this.id,
    required this.tipNumber,
    required this.tipTitle,
    this.description,
    this.bannerImagePath,
  });

  factory HealthTipItem.fromJson(Map<String, dynamic> json) {
    final numRaw = json['tipNumber'];
    return HealthTipItem(
      id: json['_id']?.toString(),
      tipNumber: numRaw is int
          ? numRaw
          : int.tryParse(numRaw?.toString() ?? '') ?? 0,
      tipTitle: json['tipTitle']?.toString() ?? '',
      description: json['description']?.toString(),
      bannerImagePath: json['bannerImage']?.toString(),
    );
  }
}
