class CurrencyInfoData {
  final String recommendedLabel;
  final String exchangeRate;
  final List<String> paymentOptions;
  final String? tips;
  final String? bannerImagePath;

  CurrencyInfoData({
    required this.recommendedLabel,
    required this.exchangeRate,
    required this.paymentOptions,
    this.tips,
    this.bannerImagePath,
  });

  factory CurrencyInfoData.fromJson(Map<String, dynamic> json) {
    final rc = json['recommendedCurrency'];
    return CurrencyInfoData(
      recommendedLabel: _recommendedLabel(rc),
      exchangeRate: json['exchangeRate']?.toString() ?? '',
      paymentOptions: _stringList(json['paymentOptions']),
      tips: json['tips']?.toString(),
      bannerImagePath: json['bannerImage']?.toString(),
    );
  }

  static String _recommendedLabel(dynamic rc) {
    if (rc is Map) {
      final code = rc['code']?.toString() ?? '';
      final name = rc['name']?.toString() ?? '';
      if (name.isNotEmpty && code.isNotEmpty) return '$name ($code)';
      if (name.isNotEmpty) return name;
      if (code.isNotEmpty) return code;
    }
    if (rc is String && rc.isNotEmpty) return rc;
    return '—';
  }

  static List<String> _stringList(dynamic v) {
    if (v is List) {
      return v.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
    }
    return const [];
  }
}
