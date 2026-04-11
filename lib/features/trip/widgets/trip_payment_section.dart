import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/app_constants.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/enums/payment_option_enum.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:trael_app_abdelhamid/core/utils/payment_flow_log.dart';
import 'package:trael_app_abdelhamid/core/utils/toast_helper.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_button.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/core/widgets/past_payment_item.dart';
import 'package:trael_app_abdelhamid/core/widgets/payment_option_card.dart';
import 'package:trael_app_abdelhamid/model/home/trip_model.dart';
import 'package:trael_app_abdelhamid/model/home/user_payment_history_item.dart';
import 'package:trael_app_abdelhamid/features/home/payment_successfull_screen.dart';
import 'package:trael_app_abdelhamid/provider/booking/trip_booking_provider.dart';
import 'package:trael_app_abdelhamid/provider/chat/chat_provider.dart';
import 'package:trael_app_abdelhamid/provider/home/home_provider.dart';
import 'package:trael_app_abdelhamid/routes/user_routes.dart';
import 'package:trael_app_abdelhamid/services/payment_service.dart';
import 'package:trael_app_abdelhamid/services/trips_service.dart';

/// Payment summary + method list + Stripe Payment Sheet for the Trip tab.
class TripPaymentSection extends StatefulWidget {
  const TripPaymentSection({super.key});

  @override
  State<TripPaymentSection> createState() => _TripPaymentSectionState();
}

class _TripPaymentSectionState extends State<TripPaymentSection> {
  bool _paying = false;

  /// Whether native Google Pay / Apple Pay is available on this device.
  bool? _platformPaySupported;

  String? _lastHistoryBookingIdForLoad;
  int _lastSeenPaymentHistoryToken = -1;
  List<UserPaymentHistoryItem> _pastPayments = [];
  bool _pastPaymentsLoading = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      _checkPlatformPaySupport();
    } else {
      _platformPaySupported = false;
    }
  }

  Future<void> _checkPlatformPaySupport() async {
    if (AppConstants.stripePublishableKey.isEmpty) {
      if (mounted) setState(() => _platformPaySupported = false);
      return;
    }
    try {
      final ok = await Stripe.instance.isPlatformPaySupported(
        googlePay: IsGooglePaySupportedParams(testEnv: kDebugMode),
      );
      if (mounted) setState(() => _platformPaySupported = ok);
    } catch (_) {
      if (mounted) setState(() => _platformPaySupported = false);
    }
  }

  /// Re-fetch `GET .../user-payment/my-trip` until paid/pending change, or [maxAttempts] exhausted.
  /// If totals never change, the backend is not updating the booking after Stripe (webhook / DB).
  Future<void> _pollEnrolledTripAfterStripeSuccess(
    TripProvider tripProvider, {
    required double priorPending,
    required double priorPaid,
    String? bookingId,
  }) async {
    const maxAttempts = 15;
    const gap = Duration(milliseconds: 1000);

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      await tripProvider.loadEnrolledTripForTripsTab(bookingId: bookingId);
      final p = tripProvider.paymentDetails;
      if (p == null) {
        PaymentFlowLog.log('poll after Stripe: paymentDetails is null');
        return;
      }
      final pendingDropped = p.pendingAmount < priorPending - 0.009;
      final paidIncreased = p.paidAmount > priorPaid + 0.009;
      if (pendingDropped || paidIncreased) {
        PaymentFlowLog.log('poll after Stripe: my-trip reflects payment', {
          'attempt': attempt + 1,
          'pendingAmount': p.pendingAmount,
          'paidAmount': p.paidAmount,
        });
        return;
      }
      PaymentFlowLog.log(
        'poll after Stripe: my-trip still unchanged (webhook slow or missing)',
        {
          'attempt': '${attempt + 1}/$maxAttempts',
          'pendingAmount': p.pendingAmount,
          'paidAmount': p.paidAmount,
        },
      );
      if (attempt < maxAttempts - 1) {
        await Future.delayed(gap);
      }
    }
    PaymentFlowLog.log(
      'poll after Stripe: TIMEOUT — backend never updated booking. '
      'Configure Stripe webhook payment_intent.succeeded (or equivalent) to add this charge to the booking; '
      'GET my-trip must return updated paidAmount / pendingAmount.',
    );
  }

  Future<void> _loadPastPayments(String? bookingId) async {
    if (!mounted) return;
    if (bookingId == null || bookingId.isEmpty) {
      setState(() {
        _pastPayments = [];
        _pastPaymentsLoading = false;
      });
      return;
    }
    setState(() => _pastPaymentsLoading = true);
    try {
      final list = await TripsService.instance.fetchUserPaymentHistory(
        bookingId: bookingId,
        showErrorToast: false,
      );
      final listed = list.where((e) => e.includeInHistoryList).toList()
        ..sort((a, b) {
          final da = a.date;
          final db = b.date;
          if (da == null && db == null) return 0;
          if (da == null) return 1;
          if (db == null) return -1;
          return db.compareTo(da);
        });
      if (mounted) setState(() => _pastPayments = listed);
    } finally {
      if (mounted) setState(() => _pastPaymentsLoading = false);
    }
  }

  String _paymentDisplayId(UserPaymentHistoryItem e) {
    final inv = e.invoiceLabel;
    if (inv.length <= 18 && !inv.startsWith('pi_')) {
      return '#${inv.toUpperCase()}';
    }
    final tail = e.paymentId.length >= 6
        ? e.paymentId.substring(e.paymentId.length - 6)
        : e.paymentId;
    return '#TRX$tail'.toUpperCase();
  }

  String _formatPaymentAmount(UserPaymentHistoryItem e) {
    final n = NumberFormat('#,##0', 'en_US');
    return '€${n.format(e.amount)}';
  }

  String _formatPaymentDate(DateTime? d) {
    if (d == null) return '';
    return DateFormat('dd MMM yyyy').format(d.toLocal());
  }

  Future<void> _onPaymentSucceeded(double paidAmountEur) async {
    PaymentFlowLog.log('_onPaymentSucceeded: start', {
      'paidAmountEur': paidAmountEur,
    });
    if (!mounted) return;
    final tripProvider = context.read<TripProvider>();
    final priorPending =
        tripProvider.paymentDetails?.pendingAmount ?? paidAmountEur;
    final priorPaid = tripProvider.paymentDetails?.paidAmount ?? 0;
    PaymentFlowLog.log('_onPaymentSucceeded: snapshot before refresh', {
      'priorPending': priorPending,
      'priorPaid': priorPaid,
      'chargedThisSession': paidAmountEur,
    });

    final bookingIdForMyTrip =
        tripProvider.enrolledBookingId ??
            context.read<TripBookingProvider>().bookingId;
    tripProvider.rememberLatestPaymentBookingId(bookingIdForMyTrip);
    await _pollEnrolledTripAfterStripeSuccess(
      tripProvider,
      priorPending: priorPending,
      priorPaid: priorPaid,
      bookingId: bookingIdForMyTrip,
    );
    if (!mounted) return;
    PaymentFlowLog.log('_onPaymentSucceeded: after poll', {
      'pendingAmount': tripProvider.paymentDetails?.pendingAmount,
      'paidAmount': tripProvider.paymentDetails?.paidAmount,
    });
    if (bookingIdForMyTrip != null && bookingIdForMyTrip.isNotEmpty) {
      await TripsService.instance.markBookingActive(
        bookingId: bookingIdForMyTrip,
      );
    }
    if (!mounted) return;
    await context.read<ChatProvider>().loadConversations(silent: true);
    if (!mounted) return;
    ToastHelper.showSuccess('Payment successful');
    await context.pushNamed(
      UserAppRoutes.paymentSuccessfullScreen.name,
      extra: PaymentSuccessRouteExtra(amountEur: paidAmountEur),
    );
    if (!mounted) return;
    await tripProvider.loadEnrolledTripForTripsTab(
      bookingId: bookingIdForMyTrip,
    );
    if (!mounted) return;
    PaymentFlowLog.log('_onPaymentSucceeded: after success screen + final refresh', {
      'pendingAmount': tripProvider.paymentDetails?.pendingAmount,
      'paidAmount': tripProvider.paymentDetails?.paidAmount,
    });
    await context.read<ChatProvider>().loadConversations(silent: true);
    if (!mounted) return;
    tripProvider.notifyPaymentHistoryRefresh();
  }

  /// Native wallet flow (Google Pay on Android, Apple Pay on iOS) via [PlatformPayButton].
  Future<void> _payWithPlatformPay() async {
    final tripProvider = context.read<TripProvider>();
    final bookingProvider = context.read<TripBookingProvider>();
    final payment = tripProvider.paymentDetails;

    if (AppConstants.stripePublishableKey.isEmpty) {
      ToastHelper.showError(
        'Add your Stripe publishable key in AppConstants.stripePublishableKey',
      );
      return;
    }

    final bookingId =
        tripProvider.enrolledBookingId ?? bookingProvider.bookingId;
    if (bookingId == null || bookingId.isEmpty) {
      ToastHelper.showError('No booking found. Complete a package first.');
      return;
    }

    if (payment == null) {
      ToastHelper.showError('Payment details unavailable. Pull to refresh.');
      return;
    }

    final pending = payment.pendingAmount;
    if (pending <= 0) {
      ToastHelper.showError('Nothing to pay.');
      return;
    }

    setState(() => _paying = true);
    try {
      PaymentFlowLog.log('_payWithPlatformPay: creating intent', {
        'bookingId': bookingId,
        'pending': pending,
      });
      final result = await PaymentService.instance.createPaymentIntent(
        bookingId: bookingId,
        amount: pending,
        currency: 'eur',
        paymentMethodTypes: const ['card'],
      );
      PaymentFlowLog.log('_payWithPlatformPay: Stripe confirm (platform pay)');

      if (Platform.isAndroid) {
        await Stripe.instance.confirmPlatformPayPaymentIntent(
          clientSecret: result.clientSecret,
          confirmParams: PlatformPayConfirmParams.googlePay(
            googlePay: GooglePayParams(
              testEnv: kDebugMode,
              merchantCountryCode: AppConstants.stripeMerchantCountryCode,
              currencyCode: 'eur',
              merchantName: 'Travel',
            ),
          ),
        );
      } else if (Platform.isIOS) {
        final label = payment.packageName.isNotEmpty
            ? payment.packageName
            : 'Trip payment';
        await Stripe.instance.confirmPlatformPayPaymentIntent(
          clientSecret: result.clientSecret,
          confirmParams: PlatformPayConfirmParams.applePay(
            applePay: ApplePayParams(
              merchantCountryCode: AppConstants.stripeMerchantCountryCode,
              currencyCode: 'eur',
              cartItems: [
                ApplePayCartSummaryItem.immediate(
                  label: label,
                  amount: pending.toStringAsFixed(2),
                ),
              ],
            ),
          ),
        );
      } else {
        return;
      }

      PaymentFlowLog.log('_payWithPlatformPay: Stripe confirm OK, calling _onPaymentSucceeded');
      await _onPaymentSucceeded(pending);
    } on StripeException catch (e) {
      final code = e.error.code;
      if (code == FailureCode.Canceled) {
        PaymentFlowLog.log('_payWithPlatformPay: user canceled');
        return;
      }
      PaymentFlowLog.log('_payWithPlatformPay: StripeException', {
        'code': code.toString(),
        'message': e.error.message,
      });
      ToastHelper.showError(e.error.message ?? 'Payment failed');
    } on StripeError catch (e) {
      PaymentFlowLog.log('_payWithPlatformPay: StripeError', {'message': e.message});
      ToastHelper.showError(e.message);
    } catch (e) {
      PaymentFlowLog.log('_payWithPlatformPay: error', {'error': e.toString()});
      ToastHelper.showError(e.toString());
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  Future<void> _onPayNow() async {
    final tripProvider = context.read<TripProvider>();
    final bookingProvider = context.read<TripBookingProvider>();
    final payment = tripProvider.paymentDetails;
    final method = tripProvider.selectedMethod;

    if (AppConstants.stripePublishableKey.isEmpty) {
      ToastHelper.showError(
        'Add your Stripe publishable key in AppConstants.stripePublishableKey',
      );
      return;
    }

    if (method.isOfflineCash) {
      ToastHelper.showError(
        'Cash payment is arranged offline. Please contact support.',
      );
      return;
    }

    final bookingId =
        tripProvider.enrolledBookingId ?? bookingProvider.bookingId;
    if (bookingId == null || bookingId.isEmpty) {
      ToastHelper.showError('No booking found. Complete a package first.');
      return;
    }

    if (payment == null) {
      ToastHelper.showError('Payment details unavailable. Pull to refresh.');
      return;
    }

    final pending = payment.pendingAmount;
    if (pending <= 0) {
      ToastHelper.showError('Nothing to pay.');
      return;
    }

    setState(() => _paying = true);
    try {
      final types = method.stripePaymentMethodTypes;
      PaymentFlowLog.log('_onPayNow: creating intent', {
        'bookingId': bookingId,
        'pending': pending,
        'method': method.name,
        'stripeTypes': types?.join(',') ?? '(null)',
      });
      final result = await PaymentService.instance.createPaymentIntent(
        bookingId: bookingId,
        amount: pending,
        currency: 'eur',
        paymentMethodTypes: types,
      );

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: result.clientSecret,
          merchantDisplayName: 'Travel',
          style: ThemeMode.light,
          // Only enable the wallet when the user chose it; avoids showing GPay for "Card only".
          googlePay: Platform.isAndroid && method == PaymentMethodEnum.googlePay
              ? PaymentSheetGooglePay(
                  merchantCountryCode: AppConstants.stripeMerchantCountryCode,
                  testEnv: kDebugMode,
                )
              : null,
          applePay: Platform.isIOS && method == PaymentMethodEnum.applepay
              ? PaymentSheetApplePay(
                  merchantCountryCode: AppConstants.stripeMerchantCountryCode,
                )
              : null,
        ),
      );

      PaymentFlowLog.log('_onPayNow: presentPaymentSheet');
      await Stripe.instance.presentPaymentSheet();

      PaymentFlowLog.log('_onPayNow: sheet completed, calling _onPaymentSucceeded');
      await _onPaymentSucceeded(pending);
    } on StripeException catch (e) {
      final code = e.error.code;
      if (code == FailureCode.Canceled) {
        PaymentFlowLog.log('_onPayNow: user canceled sheet');
        return;
      }
      PaymentFlowLog.log('_onPayNow: StripeException', {
        'code': code.toString(),
        'message': e.error.message,
      });
      ToastHelper.showError(e.error.message ?? 'Payment failed');
    } catch (e) {
      PaymentFlowLog.log('_onPayNow: error', {'error': e.toString()});
      ToastHelper.showError(e.toString());
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TripProvider>(
      builder: (context, tripProvider, _) {
        final payment = tripProvider.paymentDetails;
        final loading =
            tripProvider.isPaymentLoading || tripProvider.isEnrolledTripLoading;

        final bid = tripProvider.enrolledBookingId;
        if (bid != _lastHistoryBookingIdForLoad) {
          _lastHistoryBookingIdForLoad = bid;
          Future.microtask(() => _loadPastPayments(bid));
        }

        final historyToken = tripProvider.paymentHistoryRefreshToken;
        if (_lastSeenPaymentHistoryToken == -1) {
          _lastSeenPaymentHistoryToken = historyToken;
        } else if (historyToken != _lastSeenPaymentHistoryToken) {
          _lastSeenPaymentHistoryToken = historyToken;
          if (bid != null && bid.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _loadPastPayments(bid);
            });
          }
        }

        // No enrolled booking OR backend returned "all zeros" → show empty state CTA.
        // Some environments return `{ total:0, paid:0, pending:0 }` even without a booking.
        final allZero = payment != null &&
            payment.totalAmount.abs() < 0.0001 &&
            payment.paidAmount.abs() < 0.0001 &&
            payment.pendingAmount.abs() < 0.0001;
        if (!loading && ((bid == null || bid.isEmpty) || payment == null || allZero)) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.setOpacity(0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.primaryColor.setOpacity(0.18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppText(
                    text: 'No active booking yet',
                    style: textStyle16SemiBold.copyWith(
                      color: AppColors.secondary,
                      fontSize: 18.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  8.h.verticalSpace,
                  AppText(
                    text:
                        'Choose a package to start booking. You can pay after selecting your package.',
                    style: textStyle14Regular.copyWith(
                      color: AppColors.primaryColor.setOpacity(0.65),
                      fontSize: 14.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  16.h.verticalSpace,
                  AppButton(
                    title: 'Book now',
                    onTap: () async {
                      await tripProvider.ensureSelectedTripFromUpcoming();
                      // Use the same kind of trip object as Home upcoming list tap
                      // (must have a real `id` so TripDetailsScreen can load packages).
                      TripModel? t = tripProvider.selectedTrip;
                      if (t?.id == null || (t!.id?.isEmpty ?? true)) {
                        final upcomingWithId = tripProvider.upcomingTripList
                            .where((e) => (e.id ?? '').isNotEmpty)
                            .toList();
                        if (upcomingWithId.isNotEmpty) {
                          t = upcomingWithId.first;
                        }
                      }
                      if (t != null) tripProvider.selectTrip(t);
                      if (!context.mounted) return;
                      context.pushNamed(UserAppRoutes.tripDetailsScreen.name);
                    },
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.setOpacity(0.2),
                      blurRadius: 1,
                      offset: const Offset(0, 1),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.primaryColor.setOpacity(0.2),
                  ),
                ),
                child: loading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            text: payment?.packageName ?? '-',
                            style: textStyle14Regular.copyWith(
                              color: AppColors.primaryColor.setOpacity(0.8),
                              fontSize: 14.sp,
                            ),
                          ),
                          12.h.verticalSpace,
                          _priceRow(
                            'Total',
                            '€${payment?.totalAmount.toStringAsFixed(0) ?? '-'}',
                          ),
                          4.h.verticalSpace,
                          _priceRow(
                            'Paid',
                            '€${payment?.paidAmount.toStringAsFixed(0) ?? '-'}',
                          ),
                          4.h.verticalSpace,
                          _priceRow(
                            'Pending',
                            '€${payment?.pendingAmount.toStringAsFixed(0) ?? '-'}',
                          ),
                        ],
                      ),
              ),
            ),
            if (!loading && bid != null && bid.isNotEmpty)
              _pastPaymentsBlock(context, bid),
            if (!loading) ...[
              if (payment != null && payment.pendingAmount > 0) ...[
                Padding(  
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      PaymentOption(
                        onSelect: tripProvider.changeSelectedMethod,
                        value: PaymentMethodEnum.idealpay,
                        selectedValue: tripProvider.selectedMethod,
                      ),
                      PaymentOption(
                        onSelect: tripProvider.changeSelectedMethod,
                        value: PaymentMethodEnum.cash,
                        selectedValue: tripProvider.selectedMethod,
                      ),
                      PaymentOption(
                        onSelect: tripProvider.changeSelectedMethod,
                        value: PaymentMethodEnum.creditCard,
                        selectedValue: tripProvider.selectedMethod,
                      ),
                      PaymentOption(
                        onSelect: tripProvider.changeSelectedMethod,
                        value: PaymentMethodEnum.paypal,
                        selectedValue: tripProvider.selectedMethod,
                      ),
                    ],
                  ),
                ),
                16.h.verticalSpace,
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: AppButton(
                    title: 'Pay now',
                    isLoading: _paying,
                    onTap: _paying ? null : _onPayNow,
                  ),
                ),
                15.verticalSpace,
                if (_platformPaySupported == true) ...[
                  Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Opacity(
                          opacity: _paying ? 0.55 : 1,
                          child: AbsorbPointer(
                            absorbing: _paying,
                            child: SizedBox(
                              width: double.infinity,
                              height: 50.h,
                              child: PlatformPayButton(
                                type: Platform.isAndroid
                                    ? PlatformButtonType.googlePayMark
                                    : PlatformButtonType.book,
                                appearance: PlatformButtonStyle.automatic,
                                borderRadius: 8,
                                onPressed: () {
                                  if (!_paying) {
                                    _payWithPlatformPay();
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  20.h.verticalSpace,
                ],
              ] else if (payment != null && payment.pendingAmount <= 0) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: AppText(
                    text:
                        'No payment due. Your balance is fully paid — thank you!',
                    style: textStyle14Regular.copyWith(
                      color: AppColors.primaryColor.setOpacity(0.7),
                      fontSize: 15.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                24.h.verticalSpace,
              ],
              24.h.verticalSpace,
            ],
          ],
        );
      },
    );
  }

  Widget _pastPaymentsBlock(BuildContext context, String bookingId) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 4.h, 24.w, 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AppText(
                  text: 'Past Payment',
                  style: textStyle16SemiBold.copyWith(
                    color: AppColors.secondary,
                    fontSize: 18.sp,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  context.pushNamed(
                    UserAppRoutes.paymentHistoryScreen.name,
                    extra: <String, dynamic>{'bookingId': bookingId},
                  );
                },
                child: AppText(
                  text: 'View All',
                  style: textStyle14Medium.copyWith(
                    color: AppColors.blueColor,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.blueColor,
                  ),
                ),
              ),
            ],
          ),
          if (_pastPaymentsLoading)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Center(
                child: SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            )
          else if (_pastPayments.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: 8.h, bottom: 4.h),
              child: AppText(
                text: 'No payment activity yet.',
                style: textStyle14Regular.copyWith(
                  color: AppColors.primaryColor.setOpacity(0.5),
                ),
              ),
            )
          else
            ..._pastPayments.take(3).map(
                  (e) => PastPaymentItem(
                    id: _paymentDisplayId(e),
                    amount: _formatPaymentAmount(e),
                    date: _formatPaymentDate(e.date),
                    isConfirmed: e.isSucceeded,
                    onViewReceiptTap: () {
                      context.pushNamed(
                        UserAppRoutes.viewPaymentReceiptScreen.name,
                        extra: <String, dynamic>{'paymentId': e.paymentId},
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _priceRow(String title, String value) {
    Color textColor;
    if (title == 'Paid' || title == 'Pending') {
      textColor = AppColors.primaryColor.setOpacity(0.6);
    } else {
      textColor = AppColors.primaryColor;
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      child: Row(
        children: [
          Expanded(
            child: AppText(
              text: title,
              style: textStyle14Medium.copyWith(
                color: textColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          AppText(
            text: value,
            style: textStyle14Medium.copyWith(
              color: textColor,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
