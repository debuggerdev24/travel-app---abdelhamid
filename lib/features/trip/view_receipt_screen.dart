import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:trael_app_abdelhamid/core/utils/toast_helper.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/model/home/payment_receipt_detail.dart';
import 'package:trael_app_abdelhamid/services/trips_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewReceiptScreen extends StatefulWidget {
  const ViewReceiptScreen({super.key, this.paymentId});

  final String? paymentId;

  @override
  State<ViewReceiptScreen> createState() => _ViewReceiptScreenState();
}

class _ViewReceiptScreenState extends State<ViewReceiptScreen> {
  PaymentReceiptDetail? _detail;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final id = widget.paymentId;
    if (id != null && id.isNotEmpty) {
      _fetch(id);
    }
  }

  Future<void> _fetch(String paymentId) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final d = await TripsService.instance.fetchPaymentReceipt(
        paymentId,
        showErrorToast: true,
      );
      if (!mounted) return;
      setState(() {
        _detail = d;
        _loading = false;
        if (d == null) _error = 'Receipt not found';
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  String _fmtDate(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    final d = DateTime.tryParse(raw);
    if (d == null) return raw;
    return DateFormat('MMMM d, yyyy').format(d.toLocal());
  }

  Future<void> _openReceiptPdf() async {
    final url = _detail?.pdfDownloadUrl;
    if (url == null || url.isEmpty) {
      ToastHelper.showError(
        'Receipt PDF is not available yet. It usually appears after Stripe confirms the payment.',
      );
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null || !(uri.isScheme('https') || uri.isScheme('http'))) {
      ToastHelper.showError('Invalid receipt link.');
      return;
    }
    try {
      final ok = await canLaunchUrl(uri);
      if (!ok) {
        ToastHelper.showError('Cannot open receipt on this device.');
        return;
      }
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      ToastHelper.showError('Could not open receipt.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = _detail;
    final hasPdf = d?.pdfDownloadUrl != null && d!.pdfDownloadUrl!.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      bottomNavigationBar: hasPdf
          ? SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                child: GestureDetector(
                  onTap: hasPdf
                      ? _openReceiptPdf
                      : () {
                          ToastHelper.showError(
                            'Receipt PDF is not available yet. It usually appears after Stripe confirms the payment.',
                          );
                        },
                  child: Container(
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: hasPdf
                          ? AppColors.blueColor
                          : AppColors.blueColor.setOpacity(0.45),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    alignment: Alignment.center,
                    child: AppText(
                      text: hasPdf
                          ? 'Download / open PDF'
                          : 'Download PDF (unavailable)',
                      style: textStyle16SemiBold.copyWith(
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: SvgIcon(AppAssets.backIcon, size: 26.w),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Center(
                            child: AppText(
                              text: 'Payment Receipt',
                              style: textStyle32Bold.copyWith(
                                fontSize: 24.sp,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                        ),
                        26.w.horizontalSpace,
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 16.h,
                      ),
                      child: Column(
                        children: [
                          Center(
                            child: AppText(
                              text: 'Company Pvt. Ltd.',
                              style: textStyle16SemiBold.copyWith(
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          if (_error != null && d == null)
                            AppText(
                              text: _error!,
                              style: textStyle14Regular.copyWith(
                                color: Colors.red,
                              ),
                            )
                          else if (d != null) ...[
                            _section('Invoice & Transaction', [
                              _info('Invoice No.', d.invoiceNo),
                              _info('Date', _fmtDate(d.invoiceDate)),
                              _info(
                                'Payment Status',
                                d.paymentStatus,
                                color: AppColors.blueColor,
                              ),
                              _info(
                                'Amount Paid',
                                '${d.amountPaid.isNotEmpty ? d.amountPaid : '—'} ${d.currency.isNotEmpty ? d.currency.toUpperCase() : ''}',
                              ),
                              _info('Transaction ID', d.transactionId ?? '—'),
                              _info('Method', d.method),
                            ]),
                            SizedBox(height: 20.h),
                            _section('Customer Info', [
                              _info('Name', d.customerName),
                              _info('Email', d.customerEmail ?? '—'),
                              _info('Phone', d.customerPhone ?? '—'),
                            ]),
                            SizedBox(height: 20.h),
                            _section('Booking Details', [
                              _info('Package', d.packageName),
                              _info('Passengers', d.passengers),
                              _info(
                                'Travel Dates',
                                '${_fmtDate(d.travelStart)} – ${_fmtDate(d.travelEnd)}',
                              ),
                            ]),
                          ] else ...[
                            _section('Invoice & Transaction', [
                              _info('Invoice No.', 'INV-20240715-001'),
                              _info('Date', 'July 15, 2024'),
                              _info(
                                'Payment Status',
                                'Successful',
                                color: AppColors.blueColor,
                              ),
                              _info('Amount Paid', '\$1,250.00'),
                              _info('Transaction ID', 'TXN-20240715-001'),
                              _info('Method', 'Credit Card'),
                            ]),
                            SizedBox(height: 20.h),
                            _section('Customer Info', [
                              _info('Name', 'Aaliyah Khan'),
                              _info('Email', 'aaliyah@email.com'),
                              _info('Phone', '+91 98765 43210'),
                            ]),
                            SizedBox(height: 20.h),
                            _section('Booking Details', [
                              _info('Package', 'Luxury Maldives Getaway'),
                              _info('Passengers', '2 Adults, 1 Child'),
                              _info('Travel Dates', 'Aug 15 - 22, 2024'),
                            ]),
                          ],
                          SizedBox(height: 30.h),
                          Center(
                            child: AppText(
                              text: '"Thank you for booking with us."',
                              style: textStyle14Regular.copyWith(
                                color: AppColors.primaryColor.setOpacity(.5),
                              ),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Center(
                            child: AppText(
                              text: 'Support: +91 XXXXX XXXXX',
                              style: textStyle14Regular.copyWith(
                                color: AppColors.primaryColor.setOpacity(.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _section(String title, List<Widget> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: title,
          style: textStyle16SemiBold.copyWith(color: AppColors.primaryColor),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          margin: EdgeInsets.only(top: 10.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.primaryColor.setOpacity(0.2)),
          ),
          child: Column(
            children: List.generate(
              rows.length,
              (i) => Column(
                children: [
                  rows[i],
                  if (i != rows.length - 1)
                    Divider(
                      color: AppColors.primaryColor.setOpacity(0.1),
                      height: 10.h,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _info(String title, String value, {Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: AppText(
              text: title,
              style: textStyle14Medium.copyWith(
                color: AppColors.primaryColor.setOpacity(0.6),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: AppText(
              text: value,
              style: textStyle14Regular.copyWith(
                color: color ?? AppColors.primaryColor,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
