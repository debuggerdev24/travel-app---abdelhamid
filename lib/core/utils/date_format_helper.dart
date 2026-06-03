const _monthAbbrev = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Normalizes API date strings (ISO timestamps, etc.) to `YYYY-MM-DD` for forms.
String formatDateToYyyyMmDd(String? raw) {
  if (raw == null) return '';
  final s = raw.trim();
  if (s.isEmpty) return '';
  if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(s)) return s;

  final dateOnly = s.split('T').first.split(' ').first;
  if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateOnly)) {
    return dateOnly;
  }

  try {
    final dt = DateTime.parse(s);
    final normalized = dt.isUtc ? dt : dt.toUtc();
    final y = normalized.year.toString().padLeft(4, '0');
    final m = normalized.month.toString().padLeft(2, '0');
    final d = normalized.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  } catch (_) {
    return dateOnly;
  }
}

/// Age in full years from [dateOfBirth] (`YYYY-MM-DD` or ISO timestamp).
int? ageFromDateOfBirth(String? dateOfBirth) {
  if (dateOfBirth == null || dateOfBirth.trim().isEmpty) return null;

  DateTime? dob;
  final normalized = formatDateToYyyyMmDd(dateOfBirth);
  if (normalized.isNotEmpty) {
    final parts = normalized.split('-');
    if (parts.length == 3) {
      final y = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final d = int.tryParse(parts[2]);
      if (y != null && m != null && d != null) {
        dob = DateTime(y, m, d);
      }
    }
  }
  dob ??= DateTime.tryParse(dateOfBirth.trim());
  if (dob == null) return null;

  final today = DateTime.now();
  var age = today.year - dob.year;
  final hadBirthdayThisYear =
      today.month > dob.month ||
      (today.month == dob.month && today.day >= dob.day);
  if (!hadBirthdayThisYear) age -= 1;
  if (age < 0 || age > 130) return null;
  return age;
}

DateTime? parseApiDate(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  try {
    return DateTime.parse(raw.trim());
  } catch (_) {
    final normalized = formatDateToYyyyMmDd(raw);
    if (normalized.isEmpty) return null;
    final parts = normalized.split('-');
    if (parts.length != 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    return DateTime(y, m, d);
  }
}

/// Trip-style display, e.g. `8 Jun 2026` (matches trip date headers).
String formatDateForDisplay(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '—';
  final dt = parseApiDate(raw);
  if (dt == null) return raw.trim();
  return '${dt.day} ${_monthAbbrev[dt.month - 1]} ${dt.year}';
}

/// Date with optional local time, e.g. `10 Jun 2026 · 11:11` for ISO timestamps.
String formatDateTimeForDisplay(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '—';
  final dt = parseApiDate(raw);
  if (dt == null) return raw.trim();
  final local = dt.toLocal();
  final date =
      '${local.day} ${_monthAbbrev[local.month - 1]} ${local.year}';
  final trimmed = raw.trim();
  final hasTime =
      trimmed.contains('T') ||
      RegExp(r'\d{1,2}:\d{2}').hasMatch(trimmed);
  if (!hasTime) return date;
  final h = local.hour.toString().padLeft(2, '0');
  final m = local.minute.toString().padLeft(2, '0');
  return '$date · $h:$m';
}

/// Trip-style range, e.g. `8 Jun – 24 Jun 2026`.
String formatDateRangeForDisplay(String? start, String? end) {
  final startDt = parseApiDate(start);
  final endDt = parseApiDate(end);
  if (startDt == null || endDt == null) return '—';
  return '${startDt.day} ${_monthAbbrev[startDt.month - 1]} – '
      '${endDt.day} ${_monthAbbrev[endDt.month - 1]} ${endDt.year}';
}
