import 'dart:developer' as developer;

/// Structured logs for the Stripe + enrolled-trip payment flow.
/// Filter device logs by name **PaymentFlow** (Android Studio / Xcode / `flutter run`).
class PaymentFlowLog {
  PaymentFlowLog._();

  static const String _name = 'PaymentFlow';

  static void log(String message, [Map<String, Object?>? fields]) {
    if (fields != null && fields.isNotEmpty) {
      final buf = StringBuffer(message);
      for (final e in fields.entries) {
        buf.write(' | ${e.key}=${e.value}');
      }
      developer.log(buf.toString(), name: _name);
    } else {
      developer.log(message, name: _name);
    }
  }

  /// Never log full Stripe client secrets — only a short prefix/suffix.
  static String maskClientSecret(String? s) {
    if (s == null || s.isEmpty) return '(empty)';
    if (s.length <= 16) return '***';
    return '${s.substring(0, 12)}…${s.substring(s.length - 4)}';
  }
}
