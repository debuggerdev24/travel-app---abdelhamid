import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/core/widgets/past_payment_item.dart';
import 'package:trael_app_abdelhamid/model/home/user_payment_history_item.dart';
import 'package:trael_app_abdelhamid/routes/user_routes.dart';
import 'package:trael_app_abdelhamid/services/trips_service.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key, this.bookingId});

  final String? bookingId;

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  List<UserPaymentHistoryItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await TripsService.instance.fetchUserPaymentHistory(
        bookingId: widget.bookingId,
        showErrorToast: true,
      );
      final ok = list.where((e) => e.includeInHistoryList).toList()
        ..sort((a, b) {
          final da = a.date;
          final db = b.date;
          if (da == null && db == null) return 0;
          if (da == null) return 1;
          if (db == null) return -1;
          return db.compareTo(da);
        });
      if (mounted) setState(() => _items = ok);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _displayId(UserPaymentHistoryItem e) {
    final inv = e.invoiceLabel;
    if (inv.length <= 18 && !inv.startsWith('pi_')) {
      return '#${inv.toUpperCase()}';
    }
    final tail = e.paymentId.length >= 6
        ? e.paymentId.substring(e.paymentId.length - 6)
        : e.paymentId;
    return '#TRX$tail'.toUpperCase();
  }

  String _fmtAmount(UserPaymentHistoryItem e) {
    final n = NumberFormat('#,##0', 'en_US');
    return '€${n.format(e.amount)}';
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return '';
    return DateFormat('dd MMM yyyy').format(d.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Column(
        children: [
          60.h.verticalSpace,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 27.w, vertical: 12.h),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: SvgIcon(AppAssets.backIcon, size: 26.w),
                  ),
                ),
                AppText(
                  text: 'Payment History',
                  style: textStyle32Bold.copyWith(
                    fontSize: 26.sp,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? Center(
                        child: AppText(
                          text: 'No payments yet.',
                          style: textStyle14Regular.copyWith(
                            color: AppColors.primaryColor.setOpacity(0.6),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.only(bottom: 10.h),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final e = _items[index];
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            child: PastPaymentItem(
                              id: _displayId(e),
                              amount: _fmtAmount(e),
                              date: _fmtDate(e.date),
                              isConfirmed: e.isSucceeded,
                              onViewReceiptTap: () {
                                context.pushNamed(
                                  UserAppRoutes.viewPaymentReceiptScreen.name,
                                  extra: <String, dynamic>{
                                    'paymentId': e.paymentId,
                                  },
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
