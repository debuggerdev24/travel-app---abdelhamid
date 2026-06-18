import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';
import 'package:travel_app_abdelhamid/core/widgets/past_payment_item.dart';
import 'package:travel_app_abdelhamid/model/home/user_payment_history_item.dart';
import 'package:travel_app_abdelhamid/routes/user_routes.dart';
import 'package:provider/provider.dart';
import 'package:travel_app_abdelhamid/provider/home/home_provider.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key, this.bookingId});

  final String? bookingId;

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripProvider>().loadPaymentHistory(widget.bookingId);
    });
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                    child: SvgIcon(
                      AppAssets.backIcon,
                      size: 26.w,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                AppText(
                  text: 'Payment History'.tr(),
                  style: textStyle32Bold.copyWith(
                    fontSize: 26.sp,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<TripProvider>(
              builder: (context, provider, child) {
                if (provider.isPaymentHistoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items = provider.paymentHistoryItems;
                if (items.isEmpty) {
                  return Center(
                    child: AppText(
                      text: 'No payments yet.'.tr(),
                      style: textStyle14Regular.copyWith(
                        color: AppColors.primaryColor.setOpacity(0.6),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.only(bottom: 10.h),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final e = items[index];
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
                            extra: <String, dynamic>{'paymentId': e.paymentId},
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
