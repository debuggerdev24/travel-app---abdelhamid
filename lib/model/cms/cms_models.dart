/// FAQ row from `GET /api/faq/get-faqs`.
class FaqItem {
  final String? id;
  final String question;
  final String answer;

  FaqItem({this.id, required this.question, required this.answer});

  factory FaqItem.fromJson(Map<String, dynamic> json) {
    return FaqItem(
      id: json['_id']?.toString(),
      question: (json['question'] ?? '').toString(),
      answer: (json['answer'] ?? '').toString(),
    );
  }
}

/// Social link from `GET /api/social/get-socials`.
class SocialLinkItem {
  final String? id;
  final String name;
  final String description;
  final String link;
  final String? iconRaw;

  SocialLinkItem({
    this.id,
    required this.name,
    required this.description,
    required this.link,
    this.iconRaw,
  });

  factory SocialLinkItem.fromJson(Map<String, dynamic> json) {
    return SocialLinkItem(
      id: json['_id']?.toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      link: (json['link'] ?? '').toString(),
      iconRaw: json['icon']?.toString(),
    );
  }
}

/// Section from `GET /api/rules/get-rules?type=terms|privacy`.
class RuleSection {
  final String title;
  final List<String> terms;

  RuleSection({required this.title, required this.terms});

  factory RuleSection.fromJson(Map<String, dynamic> json) {
    final raw = json['terms'];
    final List<String> lines = [];
    if (raw is List) {
      for (final e in raw) {
        lines.add(e.toString());
      }
    }
    return RuleSection(
      title: (json['title'] ?? '').toString(),
      terms: lines,
    );
  }
}
