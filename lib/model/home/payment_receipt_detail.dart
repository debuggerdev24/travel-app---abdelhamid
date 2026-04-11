/// `GET /api/user-payment/receipt?paymentId=` → `data` payload.
class PaymentReceiptDetail {
  const PaymentReceiptDetail({
    required this.invoiceNo,
    required this.invoiceDate,
    required this.paymentStatus,
    required this.amountPaid,
    required this.currency,
    required this.transactionId,
    required this.method,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.packageName,
    required this.passengers,
    required this.travelStart,
    required this.travelEnd,
    this.invoicePdfUrl,
    this.receiptUrl,
  });

  final String invoiceNo;
  final String? invoiceDate;
  final String paymentStatus;
  final String amountPaid;
  final String currency;
  final String? transactionId;
  final String method;
  final String customerName;
  final String? customerEmail;
  final String? customerPhone;
  final String packageName;
  final String passengers;
  final String? travelStart;
  final String? travelEnd;

  /// Stripe hosted invoice PDF (preferred for download).
  final String? invoicePdfUrl;

  /// Stripe charge receipt URL (fallback).
  final String? receiptUrl;

  /// Best URL to open for “download / view PDF”, if any.
  String? get pdfDownloadUrl {
    final pdf = invoicePdfUrl?.trim();
    if (pdf != null && pdf.isNotEmpty) return pdf;
    final r = receiptUrl?.trim();
    if (r != null && r.isNotEmpty) return r;
    return null;
  }

  factory PaymentReceiptDetail.fromJson(Map<String, dynamic> json) {
    final inv = Map<String, dynamic>.from(json['invoice'] as Map? ?? {});
    final cust = Map<String, dynamic>.from(json['customer'] as Map? ?? {});
    final book = Map<String, dynamic>.from(json['booking'] as Map? ?? {});
    final td = Map<String, dynamic>.from(book['travelDates'] as Map? ?? {});
    final dl = Map<String, dynamic>.from(json['downloadUrls'] as Map? ?? {});

    String fmt(dynamic v) => v?.toString() ?? '';

    final amount = inv['amountPaid'];
    final amountStr = amount != null ? amount.toString() : '';

    return PaymentReceiptDetail(
      invoiceNo: fmt(inv['invoiceNo']),
      invoiceDate: inv['date']?.toString(),
      paymentStatus: fmt(inv['paymentStatus']),
      amountPaid: amountStr,
      currency: fmt(inv['currency']),
      transactionId: inv['transactionId']?.toString(),
      method: fmt(inv['method']),
      customerName: fmt(cust['name']),
      customerEmail: cust['email']?.toString(),
      customerPhone: cust['phone']?.toString(),
      packageName: fmt(book['package']),
      passengers: fmt(book['passengers']),
      travelStart: td['start']?.toString(),
      travelEnd: td['end']?.toString(),
      invoicePdfUrl: dl['invoicePdfUrl']?.toString(),
      receiptUrl: dl['receiptUrl']?.toString(),
    );
  }
}
