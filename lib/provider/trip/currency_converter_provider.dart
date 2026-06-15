import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_app_abdelhamid/model/essential/exchange_rate_model.dart';
import 'package:travel_app_abdelhamid/services/essential_service.dart';

class CurrencyConverterProvider extends ChangeNotifier {
  static const String _cachedRatesKey = 'cached_exchange_rates';
  static const String _lastSyncKey = 'last_exchange_rate_sync';
  
  Map<String, ExchangeRate> _exchangeRates = {};
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
    _loadCachedRates();
  }

  Future<void> _loadCachedRates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cachedRatesKey);
      if (cachedData != null) {
        final Map<String, dynamic> decoded = json.decode(cachedData);
        _exchangeRates = decoded.map((key, value) {
          return MapEntry(key, ExchangeRate.fromJson(value as Map<String, dynamic>));
        });
        _performConversion();
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading cached rates: $e');
      }
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
        if (DateTime.now().difference(lastSync) < const Duration(hours: 24)) {
          return;
        }
      }
    }

    setState(true, null);
    try {
      final currencyInfo = await EssentialService.instance.getCurrencyInfo(
        showErrorToast: false,
      );
      
      if (currencyInfo != null && currencyInfo.exchangeRate.isNotEmpty) {
        await _parseAndStoreRates(currencyInfo.exchangeRate);
        setState(false, null);
      } else {
        if (_exchangeRates.isEmpty) {
          setState(false, 'Unable to fetch exchange rates. Using offline data if available.');
        } else {
          setState(false, null);
        }
      }
    } catch (e) {
      if (_exchangeRates.isEmpty) {
        setState(false, 'Failed to load exchange rates. Please check your connection.');
      } else {
        setState(false, 'Using cached exchange rates (offline mode)');
      }
    }
  }

  Future<void> _parseAndStoreRates(String exchangeRateString) async {
    try {
      final commonCurrencies = CurrencyData.commonCurrencies;
      
      for (final from in commonCurrencies) {
        for (final to in commonCurrencies) {
          if (from.code != to.code) {
            final rate = _calculateRate(from.code, to.code, exchangeRateString);
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
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing rates: $e');
      }
    }
  }

  double? _calculateRate(String from, String to, String rateString) {
    try {
      final baseRate = _extractRate('SAR', rateString);
      if (baseRate == null) return null;
      
      final Map<String, double> sarRates = {
        'USD': 1.0 / baseRate,
        'EUR': 0.92,
        'GBP': 0.79,
        'SAR': 1.0,
        'AED': 0.98,
        'QAR': 0.97,
        'KWD': 0.08,
        'BHD': 0.11,
        'OMR': 0.11,
        'EGP': 0.065,
        'TRY': 0.09,
        'PKR': 0.0036,
        'INR': 0.027,
        'IDR': 0.00019,
        'MYR': 0.27,
      };

      final fromRate = sarRates[from];
      final toRate = sarRates[to];
      
      if (fromRate != null && toRate != null) {
        return toRate / fromRate;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  double? _extractRate(String currency, String rateString) {
    try {
      final regex = RegExp(r'(\d+\.?\d*)\s*($currency|$currency\/\w+|\w+\/$currency)', caseSensitive: false);
      final match = regex.firstMatch(rateString);
      if (match != null) {
        return double.parse(match.group(1)!);
      }
      
      final parts = rateString.split(RegExp(r'[=\s]'));
      for (final part in parts) {
        if (part.contains(currency) || part.toUpperCase().contains(currency)) {
          final numMatch = RegExp(r'(\d+\.?\d*)').firstMatch(part);
          if (numMatch != null) {
            return double.parse(numMatch.group(1)!);
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void setFromCurrency(CurrencyData currency) {
    _fromCurrency = currency;
    _performConversion();
    notifyListeners();
  }

  void setToCurrency(CurrencyData currency) {
    _toCurrency = currency;
    _performConversion();
    notifyListeners();
  }

  void setAmount(double value) {
    _amount = value;
    _performConversion();
    notifyListeners();
  }

  void swapCurrencies() {
    final temp = _fromCurrency;
    _fromCurrency = _toCurrency;
    _toCurrency = temp;
    _performConversion();
    notifyListeners();
  }

  void _performConversion() {
    final key = '${_fromCurrency.code}_${_toCurrency.code}';
    final rate = _exchangeRates[key];
    
    if (rate != null) {
      _convertedAmount = _amount * rate.rate;
    } else {
      _convertedAmount = null;
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
