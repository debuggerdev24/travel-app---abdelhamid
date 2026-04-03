import 'package:intl/intl.dart';
import 'package:trael_app_abdelhamid/model/prayer/prayer_time_model.dart';

/// Parses admin time strings (e.g. `05:00 AM`, `3:35 PM`) to today's [DateTime] in local time.
/// Tries `h:mm a` before `hh:mm a` so single-digit hours from the API parse correctly.
DateTime? parsePrayerTimeToday(String timeStr) {
  final s = timeStr.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (s.isEmpty) return null;
  final now = DateTime.now();
  const locale = 'en_US';
  for (final pattern in ['h:mm a', 'hh:mm a', 'HH:mm', 'H:mm']) {
    try {
      final t = DateFormat(pattern, locale).parse(s);
      return DateTime(now.year, now.month, now.day, t.hour, t.minute);
    } catch (_) {}
  }
  return null;
}

/// Orders prayers by clock time today (earliest first). Rows that fail to parse go last.
List<PrayerTimeItem> sortPrayerItemsByTimeOfDay(List<PrayerTimeItem> items) {
  int minutes(PrayerTimeItem p) {
    final dt = parsePrayerTimeToday(p.time);
    if (dt == null) return 1 << 30;
    return dt.hour * 60 + dt.minute;
  }

  final copy = List<PrayerTimeItem>.from(items);
  copy.sort((a, b) {
    final cmp = minutes(a).compareTo(minutes(b));
    if (cmp != 0) return cmp;
    return a.name.compareTo(b.name);
  });
  return copy;
}

/// Next upcoming prayer and when it occurs (local). Returns null if nothing could be parsed.
/// Picks the chronologically **soonest** prayer at or after [now] (today or tomorrow).
({String name, String timeLabel, DateTime when})? computeNextPrayer(
  List<PrayerTimeItem> items,
  DateTime now,
) {
  if (items.isEmpty) return null;

  DateTime? bestWhen;
  String? bestName;
  String? bestLabel;

  for (final p in items) {
    final base = parsePrayerTimeToday(p.time);
    if (base == null) continue;

    var candidate = base;
    if (!candidate.isAfter(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    if (bestWhen == null || candidate.isBefore(bestWhen)) {
      bestWhen = candidate;
      bestName = p.name;
      bestLabel = p.time;
    }
  }

  if (bestWhen == null || bestName == null || bestLabel == null) return null;
  return (name: bestName, timeLabel: bestLabel, when: bestWhen);
}

/// Human-readable countdown, e.g. `1h 50m`, `45m`.
String formatPrayerCountdown(Duration d) {
  if (d.isNegative) return '0m';
  final totalMin = d.inMinutes;
  final h = totalMin ~/ 60;
  final m = totalMin % 60;
  if (h > 0) return '${h}h ${m}m';
  if (m > 0) return '${m}m';
  return '<1m';
}
