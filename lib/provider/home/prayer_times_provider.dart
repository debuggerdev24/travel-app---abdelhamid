import 'dart:async';

import 'package:flutter/material.dart';
import 'package:trael_app_abdelhamid/core/utils/prayer_time_helpers.dart';
import 'package:trael_app_abdelhamid/model/prayer/prayer_time_model.dart';
import 'package:trael_app_abdelhamid/services/prayer_service.dart';

/// Loads prayer times from the API and exposes the next prayer + countdown for the home screen.
class PrayerTimesProvider extends ChangeNotifier {
  List<PrayerTimeItem> _items = [];
  List<PrayerTimeItem> get items => List.unmodifiable(_items);

  bool _loading = false;
  bool get isLoading => _loading;

  String? _error;
  String? get error => _error;

  Timer? _tick;

  /// Monotonic id so overlapping calls don't block; only the latest response updates state.
  int _fetchGeneration = 0;

  PrayerTimesProvider() {
    _tick = Timer.periodic(const Duration(seconds: 30), (_) => notifyListeners());
  }

  /// Fetches from API. Uses `showErrorToast: false` so home stays quiet on failure.
  /// Safe to call repeatedly (pull-to-refresh, tab switch, returning from Prayer Times screen).
  Future<void> fetchPrayerTimes() async {
    final id = ++_fetchGeneration;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final list =
          await PrayerService.instance.fetchPrayerTimes(showErrorToast: false);
      if (id != _fetchGeneration) return;
      _items = list;
      _error = null;
    } catch (e) {
      if (id != _fetchGeneration) return;
      _error = e.toString();
      _items = [];
    } finally {
      if (id == _fetchGeneration) {
        _loading = false;
      }
      notifyListeners();
    }
  }

  /// Current next prayer from cached list (recomputed on each read / tick).
  ({String name, String timeLabel, String countdown})? get nextPrayerDisplay {
    final next = computeNextPrayer(_items, DateTime.now());
    if (next == null) return null;
    final left = next.when.difference(DateTime.now());
    return (
      name: next.name,
      timeLabel: next.timeLabel,
      countdown: formatPrayerCountdown(left),
    );
  }

  bool get showHomePrayerLoading => _loading && _items.isEmpty;

  /// Line for home chip: `"Fajr  05:00 AM"` or placeholder.
  String get homePrayerLine {
    if (_items.isEmpty) {
      return _error != null ? '—' : 'No times set';
    }
    final n = nextPrayerDisplay;
    if (n == null) return '—';
    return '${n.name}  ${n.timeLabel}';
  }

  String get homeCountdownLine {
    if (_items.isEmpty) return '—';
    return nextPrayerDisplay?.countdown ?? '—';
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }
}
