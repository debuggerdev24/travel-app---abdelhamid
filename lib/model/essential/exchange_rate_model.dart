class ExchangeRate {
  final String fromCurrency;
  final String toCurrency;
  final double rate;
  final DateTime lastUpdated;

  ExchangeRate({
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'fromCurrency': fromCurrency,
      'toCurrency': toCurrency,
      'rate': rate,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    return ExchangeRate(
      fromCurrency: json['fromCurrency'] as String,
      toCurrency: json['toCurrency'] as String,
      rate: (json['rate'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  bool isExpired({Duration maxAge = const Duration(hours: 24)}) {
    return DateTime.now().difference(lastUpdated) > maxAge;
  }
}

class CurrencyData {
  final String code;
  final String name;
  final String flag;

  CurrencyData({
    required this.code,
    required this.name,
    required this.flag,
  });

  static List<CurrencyData> get commonCurrencies => [
    CurrencyData(code: 'USD', name: 'US Dollar', flag: '🇺🇸'),
    CurrencyData(code: 'EUR', name: 'Euro', flag: '🇪🇺'),
    CurrencyData(code: 'GBP', name: 'British Pound', flag: '🇬🇧'),
    CurrencyData(code: 'SAR', name: 'Saudi Riyal', flag: '🇸🇦'),
    CurrencyData(code: 'AED', name: 'UAE Dirham', flag: '🇦🇪'),
    CurrencyData(code: 'QAR', name: 'Qatari Riyal', flag: '🇶🇦'),
    CurrencyData(code: 'KWD', name: 'Kuwaiti Dinar', flag: '🇰🇼'),
    CurrencyData(code: 'BHD', name: 'Bahraini Dinar', flag: '🇧🇭'),
    CurrencyData(code: 'OMR', name: 'Omani Rial', flag: '🇴🇲'),
    CurrencyData(code: 'EGP', name: 'Egyptian Pound', flag: '🇪🇬'),
    CurrencyData(code: 'TRY', name: 'Turkish Lira', flag: '🇹🇷'),
    CurrencyData(code: 'PKR', name: 'Pakistani Rupee', flag: '🇵🇰'),
    CurrencyData(code: 'INR', name: 'Indian Rupee', flag: '🇮🇳'),
    CurrencyData(code: 'IDR', name: 'Indonesian Rupiah', flag: '🇮🇩'),
    CurrencyData(code: 'MYR', name: 'Malaysian Ringgit', flag: '🇲🇾'),
  ];
}
