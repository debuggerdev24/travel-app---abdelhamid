/// Row from `GET /api/user-payment/history`.
class UserPaymentHistoryItem {
  const UserPaymentHistoryItem({
    required this.paymentId,
    required this.invoiceLabel,
    required this.amount,
    required this.currency,
    required this.date,
    required this.status,
    this.receiptUrl,
    this.invoicePdfUrl,
  });

  final String paymentId;
  /// Shown on the main line (Stripe invoice id, PI id, or payment id).
  final String invoiceLabel;
  final double amount;
  final String currency;
  final DateTime? date;
  final String status;

  /// Backend should set `succeeded` after Stripe confirms; some APIs use synonyms.
  bool get isSucceeded {
    final s = status.toLowerCase().trim();
    return const {
      'succeeded',
      'paid',
      'completed',
      'complete',
      'successful',
    }.contains(s);
  }

  /// Terminal failure — hide from “activity” lists if you only want attempts/charges.
  bool get isFailed {
    final s = status.toLowerCase().trim();
    return const {
      'failed',
      'canceled',
      'cancelled',
      'refunded',
    }.contains(s);
  }

  /// Show in trip/history lists (everything except failed/canceled/refunded).
  bool get includeInHistoryList => !isFailed;

  /// Short label for UI (your sample API returns `pending` for all rows until webhook updates).
  String get statusLabel {
    final s = status.toLowerCase().trim();
    if (isSucceeded) return 'Paid';
    if (isFailed) return 'Failed';
    if (s == 'pending' || s == 'processing' || s == 'requires_action') {
      return 'Pending';
    }
    if (s.isEmpty) return 'Unknown';
    return status;
  }

  final String? receiptUrl;
  final String? invoicePdfUrl;

  String? get pdfDownloadUrl {
    final pdf = invoicePdfUrl?.trim();
    if (pdf != null && pdf.isNotEmpty) return pdf;
    final r = receiptUrl?.trim();
    if (r != null && r.isNotEmpty) return r;
    return null;
  }

  factory UserPaymentHistoryItem.fromJson(Map<String, dynamic> json) {
    DateTime? d;
    final raw = json['date'];
    if (raw != null) {
      d = DateTime.tryParse(raw.toString());
    }
    final inv = json['invoiceId']?.toString().trim();
    final pid = json['paymentId']?.toString() ?? '';
    final label = (inv != null && inv.isNotEmpty) ? inv : pid;
    return UserPaymentHistoryItem(
      paymentId: pid,
      invoiceLabel: label,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency']?.toString().toLowerCase() ?? 'eur',
      date: d,
      status: json['status']?.toString() ?? '',
      receiptUrl: json['receiptUrl']?.toString(),
      invoicePdfUrl: json['invoicePdfUrl']?.toString(),
    );
  }
}
