import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_app_abdelhamid/model/essential/exchange_rate_model.dart';

// Synchronous fallback rates to ensure converter always works
Map<String, double> _fallbackRates = {
  'USD_USD': 1.0,
  'USD_EUR': 0.92,
  'USD_GBP': 0.79,
  'USD_SAR': 3.75,
  'USD_AED': 3.67,
  'USD_QAR': 3.64,
  'USD_KWD': 0.31,
  'USD_BHD': 0.38,
  'USD_OMR': 0.38,
  'USD_EGP': 48.5,
  'USD_TRY': 32.5,
  'USD_PKR': 278.0,
  'USD_INR': 94.68,
  'USD_IDR': 15600.0,
  'USD_MYR': 4.75,
  'EUR_USD': 1.09,
  'EUR_GBP': 0.86,
  'EUR_SAR': 4.08,
  'EUR_AED': 3.99,
  'EUR_QAR': 3.96,
  'EUR_KWD': 0.34,
  'EUR_BHD': 0.41,
  'EUR_OMR': 0.41,
  'EUR_EGP': 52.72,
  'EUR_TRY': 35.33,
  'EUR_PKR': 302.17,
  'EUR_INR': 90.76,
  'EUR_IDR': 16956.52,
  'EUR_MYR': 5.16,
  'GBP_USD': 1.27,
  'GBP_EUR': 1.17,
  'GBP_SAR': 4.75,
  'GBP_AED': 4.64,
  'GBP_QAR': 4.60,
  'GBP_KWD': 0.39,
  'GBP_BHD': 0.48,
  'GBP_OMR': 0.48,
  'GBP_EGP': 61.39,
  'GBP_TRY': 41.14,
  'GBP_PKR': 351.90,
  'GBP_INR': 105.65,
  'GBP_IDR': 19747.47,
  'GBP_MYR': 6.01,
  'SAR_USD': 0.27,
  'SAR_EUR': 0.25,
  'SAR_GBP': 0.21,
  'SAR_AED': 0.98,
  'SAR_QAR': 0.97,
  'SAR_KWD': 0.08,
  'SAR_BHD': 0.10,
  'SAR_OMR': 0.10,
  'SAR_EGP': 12.93,
  'SAR_TRY': 8.67,
  'SAR_PKR': 74.13,
  'SAR_INR': 22.27,
  'SAR_IDR': 4160.0,
  'SAR_MYR': 1.27,
  'AED_USD': 0.27,
  'AED_EUR': 0.25,
  'AED_GBP': 0.22,
  'AED_SAR': 1.02,
  'AED_QAR': 0.99,
  'AED_KWD': 0.08,
  'AED_BHD': 0.10,
  'AED_OMR': 0.10,
  'AED_EGP': 13.21,
  'AED_TRY': 8.86,
  'AED_PKR': 75.75,
  'AED_INR': 22.76,
  'AED_IDR': 4248.23,
  'AED_MYR': 1.29,
  'QAR_USD': 0.27,
  'QAR_EUR': 0.25,
  'QAR_GBP': 0.22,
  'QAR_SAR': 1.03,
  'QAR_AED': 1.01,
  'QAR_KWD': 0.09,
  'QAR_BHD': 0.10,
  'QAR_OMR': 0.10,
  'QAR_EGP': 13.32,
  'QAR_TRY': 8.93,
  'QAR_PKR': 76.37,
  'QAR_INR': 22.92,
  'QAR_IDR': 4285.71,
  'QAR_MYR': 1.30,
  'KWD_USD': 3.23,
  'KWD_EUR': 2.97,
  'KWD_GBP': 2.55,
  'KWD_SAR': 12.10,
  'KWD_AED': 11.84,
  'KWD_QAR': 11.74,
  'KWD_BHD': 1.23,
  'KWD_OMR': 1.23,
  'KWD_EGP': 156.45,
  'KWD_TRY': 104.84,
  'KWD_PKR': 893.55,
  'KWD_INR': 268.87,
  'KWD_IDR': 50322.58,
  'KWD_MYR': 15.32,
  'BHD_USD': 2.63,
  'BHD_EUR': 2.42,
  'BHD_GBP': 2.08,
  'BHD_SAR': 9.84,
  'BHD_AED': 9.63,
  'BHD_QAR': 9.53,
  'BHD_KWD': 0.81,
  'BHD_OMR': 1.00,
  'BHD_EGP': 127.24,
  'BHD_TRY': 85.26,
  'BHD_PKR': 726.32,
  'BHD_INR': 218.60,
  'BHD_IDR': 40894.74,
  'BHD_MYR': 12.45,
  'OMR_USD': 2.63,
  'OMR_EUR': 2.42,
  'OMR_GBP': 2.08,
  'OMR_SAR': 9.84,
  'OMR_AED': 9.63,
  'OMR_QAR': 9.53,
  'OMR_KWD': 0.81,
  'OMR_BHD': 1.00,
  'OMR_EGP': 127.24,
  'OMR_TRY': 85.26,
  'OMR_PKR': 726.32,
  'OMR_INR': 218.60,
  'OMR_IDR': 40894.74,
  'OMR_MYR': 12.45,
  'EGP_USD': 0.021,
  'EGP_EUR': 0.019,
  'EGP_GBP': 0.016,
  'EGP_SAR': 0.077,
  'EGP_AED': 0.076,
  'EGP_QAR': 0.075,
  'EGP_KWD': 0.0064,
  'EGP_BHD': 0.0079,
  'EGP_OMR': 0.0079,
  'EGP_TRY': 0.67,
  'EGP_PKR': 5.71,
  'EGP_INR': 1.72,
  'EGP_IDR': 321.55,
  'EGP_MYR': 0.098,
  'TRY_USD': 0.031,
  'TRY_EUR': 0.028,
  'TRY_GBP': 0.024,
  'TRY_SAR': 0.115,
  'TRY_AED': 0.113,
  'TRY_QAR': 0.112,
  'TRY_KWD': 0.0095,
  'TRY_BHD': 0.012,
  'TRY_OMR': 0.012,
  'TRY_EGP': 1.49,
  'TRY_PKR': 8.55,
  'TRY_INR': 2.57,
  'TRY_IDR': 480.0,
  'TRY_MYR': 0.146,
  'PKR_USD': 0.0036,
  'PKR_EUR': 0.0033,
  'PKR_GBP': 0.0028,
  'PKR_SAR': 0.0135,
  'PKR_AED': 0.0132,
  'PKR_QAR': 0.0131,
  'PKR_KWD': 0.0011,
  'PKR_BHD': 0.0014,
  'PKR_OMR': 0.0014,
  'PKR_EGP': 0.175,
  'PKR_TRY': 0.117,
  'PKR_INR': 0.30,
  'PKR_IDR': 56.12,
  'PKR_MYR': 0.017,
  'INR_USD': 0.012,
  'INR_EUR': 0.011,
  'INR_GBP': 0.0095,
  'INR_SAR': 0.045,
  'INR_AED': 0.044,
  'INR_QAR': 0.044,
  'INR_KWD': 0.0037,
  'INR_BHD': 0.0046,
  'INR_OMR': 0.0046,
  'INR_EGP': 0.582,
  'INR_TRY': 0.389,
  'INR_PKR': 3.33,
  'INR_IDR': 186.95,
  'INR_MYR': 0.057,
  'IDR_USD': 0.000064,
  'IDR_EUR': 0.000059,
  'IDR_GBP': 0.000051,
  'IDR_SAR': 0.00024,
  'IDR_AED': 0.00024,
  'IDR_QAR': 0.00023,
  'IDR_KWD': 0.000020,
  'IDR_BHD': 0.000024,
  'IDR_OMR': 0.000024,
  'IDR_EGP': 0.0031,
  'IDR_TRY': 0.0021,
  'IDR_PKR': 0.018,
  'IDR_INR': 0.0053,
  'IDR_MYR': 0.00030,
  'MYR_USD': 0.21,
  'MYR_EUR': 0.19,
  'MYR_GBP': 0.17,
  'MYR_SAR': 0.79,
  'MYR_AED': 0.77,
  'MYR_QAR': 0.77,
  'MYR_KWD': 0.065,
  'MYR_BHD': 0.080,
  'MYR_OMR': 0.080,
  'MYR_EGP': 10.21,
  'MYR_TRY': 6.84,
  'MYR_PKR': 58.53,
  'MYR_INR': 17.58,
  'MYR_IDR': 3284.21,
};

class CurrencyConverterProvider extends ChangeNotifier {
  static const String _cachedRatesKey = 'cached_exchange_rates';
  static const String _lastSyncKey = 'last_exchange_rate_sync';
  static const String _baseUrl = 'https://api.frankfurter.app/latest';

  final Dio _dio = Dio();
  final Map<String, ExchangeRate> _exchangeRates = {};
  bool _isLoading = false;
  String? _error;
  CurrencyData _fromCurrency = CurrencyData.commonCurrencies.firstWhere(
    (c) => c.code == 'EUR',
    orElse: () => CurrencyData.commonCurrencies.first,
  );
  CurrencyData _toCurrency = CurrencyData.commonCurrencies.firstWhere(
    (c) => c.code == 'SAR',
    orElse: () => CurrencyData.commonCurrencies[1],
  );
  double _amount = 1.0;
  double? _convertedAmount;

  Map<String, ExchangeRate> get exchangeRates => _exchangeRates;
  bool get isLoading => _isLoading;
  String? get error => _error;
  CurrencyData get fromCurrency => _fromCurrency;
  CurrencyData get toCurrency => _toCurrency;
  double get amount => _amount;
  double? get convertedAmount => _convertedAmount;
  bool get hasOfflineData => _exchangeRates.isNotEmpty;

  CurrencyConverterProvider() {
    // Load fallback rates immediately to ensure converter works
    _loadFallbackRatesSync();
    // Notify listeners after build phase to update UI
    Future.microtask(() {
      notifyListeners();
      // Try to fetch fresh rates from API in background
      fetchExchangeRates(forceRefresh: false);
    });
  }

  void _loadFallbackRatesSync() {
    final commonCurrencies = CurrencyData.commonCurrencies;

    if (kDebugMode) {
      print('Loading fallback rates for ${commonCurrencies.length} currencies');
    }

    for (final from in commonCurrencies) {
      for (final to in commonCurrencies) {
        if (from.code != to.code) {
          final key = '${from.code}_${to.code}';
          final rate = _fallbackRates[key];
          if (rate != null) {
            _exchangeRates[key] = ExchangeRate(
              fromCurrency: from.code,
              toCurrency: to.code,
              rate: rate,
              lastUpdated: DateTime.now(),
            );
          } else if (kDebugMode) {
            print('Missing fallback rate for key: $key');
          }
        }
      }
    }

    _performConversion(notify: false);

    if (kDebugMode) {
      print('Loaded ${_exchangeRates.length} fallback rates synchronously');
      print('Default conversion: ${_fromCurrency.code} to ${_toCurrency.code}');
      print('Exchange rate key: ${_fromCurrency.code}_${_toCurrency.code}');
      print(
        'Exchange rate: ${_exchangeRates['${_fromCurrency.code}_${_toCurrency.code}']?.rate}',
      );
      print('Converted amount: $_convertedAmount');
      print('Available rate keys: ${_exchangeRates.keys.take(10).toList()}...');
    }
  }

  Future<void> _saveCachedRates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = json.encode(
        _exchangeRates.map((key, value) => MapEntry(key, value.toJson())),
      );
      await prefs.setString(_cachedRatesKey, encoded);
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
    } catch (e) {
      if (kDebugMode) {
        print('Error saving cached rates: $e');
      }
    }
  }

  Future<void> fetchExchangeRates({bool forceRefresh = false}) async {
    if (!forceRefresh && _exchangeRates.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final lastSyncStr = prefs.getString(_lastSyncKey);
      if (lastSyncStr != null) {
        final lastSync = DateTime.parse(lastSyncStr);
        if (DateTime.now().difference(lastSync) < const Duration(hours: 1)) {
          return;
        }
      }
    }

    setState(true, null);
    try {
      await _fetchRatesFromAPI();
      setState(false, null);
    } catch (e) {
      if (_exchangeRates.isEmpty) {
        setState(
          false,
          'Failed to load exchange rates. Please check your connection.',
        );
      } else {
        setState(false, 'Using cached exchange rates (offline mode)');
      }
    }
  }

  Future<void> _fetchRatesFromAPI() async {
    try {
      final commonCurrencies = CurrencyData.commonCurrencies;
      final baseCurrency = commonCurrencies.first.code;
      final currencyCodes = commonCurrencies.map((c) => c.code).join(',');

      final response = await _dio.get(
        _baseUrl,
        queryParameters: {'from': baseCurrency, 'to': currencyCodes},
      );

      if (response.statusCode == 200 && response.data != null) {
        final rates = response.data['rates'] as Map<String, dynamic>;

        if (kDebugMode) {
          print('API Response rates: $rates');
        }

        for (final from in commonCurrencies) {
          for (final to in commonCurrencies) {
            if (from.code != to.code) {
              final rate = _calculateCrossRate(
                from.code,
                to.code,
                rates,
                baseCurrency,
              );
              if (rate != null) {
                final key = '${from.code}_$to';
                _exchangeRates[key] = ExchangeRate(
                  fromCurrency: from.code,
                  toCurrency: to.code,
                  rate: rate,
                  lastUpdated: DateTime.now(),
                );
              }
            }
          }
        }

        await _saveCachedRates();
        _performConversion();

        if (kDebugMode) {
          print('Successfully loaded ${_exchangeRates.length} exchange rates');
        }
      } else {
        if (kDebugMode) {
          print('API returned status code: ${response.statusCode}');
        }
        throw Exception('API request failed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching rates from API: $e');
      }
      // Fallback rates are already loaded in constructor, no action needed
    }
  }

  double? _calculateCrossRate(
    String from,
    String to,
    Map<String, dynamic> rates,
    String baseCurrency,
  ) {
    try {
      final fromRate = rates[from];
      final toRate = rates[to];

      if (fromRate != null && toRate != null) {
        return toRate / fromRate;
      }

      // Fallback to hardcoded rates for unsupported currencies
      final key = '${from}_$to';
      return _fallbackRates[key];
    } catch (e) {
      final key = '${from}_$to';
      return _fallbackRates[key];
    }
  }

  void setFromCurrency(CurrencyData currency) {
    _fromCurrency = currency;
    _performConversion();
  }

  void setToCurrency(CurrencyData currency) {
    _toCurrency = currency;
    _performConversion();
  }

  void setAmount(double value) {
    _amount = value;
    _performConversion();
  }

  void swapCurrencies() {
    final temp = _fromCurrency;
    _fromCurrency = _toCurrency;
    _toCurrency = temp;
    _performConversion();
  }

  void _performConversion({bool notify = true}) {
    final key = '${_fromCurrency.code}_${_toCurrency.code}';
    final rate = _exchangeRates[key];

    if (kDebugMode) {
      print('Performing conversion:');
      print('  Key: $key');
      print('  Rate found: ${rate != null}');
      print('  Rate value: ${rate?.rate}');
      print('  Amount: $_amount');
    }

    if (rate != null) {
      _convertedAmount = _amount * rate.rate;
    } else {
      _convertedAmount = null;
    }

    if (notify) {
      notifyListeners();
    }
  }

  void setState(bool loading, String? error) {
    _isLoading = loading;
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
