import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/app_constants.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/enums/payment_option_enum.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_button.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/core/widgets/payment_option_card.dart';
import 'package:trael_app_abdelhamid/features/home/payment_successfull_screen.dart';
import 'package:trael_app_abdelhamid/provider/booking/trip_booking_provider.dart';
import 'package:trael_app_abdelhamid/provider/chat/chat_provider.dart';
import 'package:trael_app_abdelhamid/provider/home/home_provider.dart';
import 'package:trael_app_abdelhamid/routes/user_routes.dart';
import 'package:trael_app_abdelhamid/core/utils/payment_flow_log.dart';
import 'package:trael_app_abdelhamid/core/utils/toast_helper.dart';
import 'package:trael_app_abdelhamid/services/payment_service.dart';
import 'package:trael_app_abdelhamid/services/trips_service.dart';

class PaymentOptionScreen extends StatefulWidget {
  const PaymentOptionScreen({super.key});

  @override
  State<PaymentOptionScreen> createState() => _PaymentOptionScreenState();
}

class _PaymentOptionScreenState extends State<PaymentOptionScreen> {
  bool _paying = false;
  bool? _platformPaySupported;

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

  /// Same as Trips tab: native Google Pay / Apple Pay sheet (not Stripe Payment Sheet).
  Future<void> _payWithPlatformPay() async {
    final bookingProvider = context.read<TripBookingProvider>();

    if (AppConstants.stripePublishableKey.isEmpty) {
      ToastHelper.showError(
        'Add your Stripe publishable key in AppConstants.stripePublishableKey',
      );
      return;
    }

    final bookingId = bookingProvider.bookingId;
    if (bookingId == null || bookingId.isEmpty) {
      ToastHelper.showError('No booking found. Select a package first.');
      return;
    }

    final amount = bookingProvider.totalAmount;
    if (amount <= 0) {
      ToastHelper.showError('Amount must be greater than 0.');
      return;
    }

    setState(() => _paying = true);
    try {
      PaymentFlowLog.log('PaymentOptionScreen: platform pay intent', {
        'bookingId': bookingId,
        'amount': amount,
      });
      final result = await PaymentService.instance.createPaymentIntent(
        bookingId: bookingId,
        amount: amount,
        currency: 'eur',
        paymentMethodTypes: const ['card'],
      );

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
        await Stripe.instance.confirmPlatformPayPaymentIntent(
          clientSecret: result.clientSecret,
          confirmParams: PlatformPayConfirmParams.applePay(
            applePay: ApplePayParams(
              merchantCountryCode: AppConstants.stripeMerchantCountryCode,
              currencyCode: 'eur',
              cartItems: [
                ApplePayCartSummaryItem.immediate(
                  label: 'Trip booking',
                  amount: amount.toStringAsFixed(2),
                ),
              ],
            ),
          ),
        );
      } else {
        return;
      }

      await _afterSuccessfulPayment(amount);
    } on StripeException catch (e) {
      final code = e.error.code;
      if (code == FailureCode.Canceled) return;
      ToastHelper.showError(e.error.message ?? 'Payment failed');
    } on StripeError catch (e) {
      ToastHelper.showError(e.message);
    } catch (e) {
      ToastHelper.showError(e.toString());
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  Future<void> _afterSuccessfulPayment(double amount) async {
    final bookingId = context.read<TripBookingProvider>().bookingId;
    final tripProvider = context.read<TripProvider>();
    tripProvider.rememberLatestPaymentBookingId(bookingId);
    await tripProvider.loadEnrolledTripForTripsTab(bookingId: bookingId);
    if (!mounted) return;
    if (bookingId != null && bookingId.isNotEmpty) {
      await TripsService.instance.markBookingActive(bookingId: bookingId);
    }
    if (!mounted) return;
    await context.read<ChatProvider>().loadConversations(silent: true);
    if (!mounted) return;
    tripProvider.notifyPaymentHistoryRefresh();
    ToastHelper.showSuccess('Payment successful');
    await context.pushNamed(
      UserAppRoutes.paymentSuccessfullScreen.name,
      extra: PaymentSuccessRouteExtra(amountEur: amount),
    );
    if (!mounted) return;
    await tripProvider.loadEnrolledTripForTripsTab(bookingId: bookingId);
    if (!mounted) return;
    await context.read<ChatProvider>().loadConversations(silent: true);
    if (!mounted) return;
    tripProvider.notifyPaymentHistoryRefresh();
  }

  Future<void> _payNow() async {
    final bookingProvider = context.read<TripBookingProvider>();
    final tripProvider = context.read<TripProvider>();
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

    // Wallet: native Google Pay / Apple Pay (same as Trips tab payment section).
    if (method == PaymentMethodEnum.googlePay ||
        method == PaymentMethodEnum.applepay) {
      await _payWithPlatformPay();
      return;
    }

    final bookingId = bookingProvider.bookingId;
    if (bookingId == null || bookingId.isEmpty) {
      ToastHelper.showError('No booking found. Select a package first.');
      return;
    }

    final amount = bookingProvider.totalAmount;
    if (amount <= 0) {
      ToastHelper.showError('Amount must be greater than 0.');
      return;
    }

    setState(() => _paying = true);
    try {
      final types = method.stripePaymentMethodTypes;
      PaymentFlowLog.log('PaymentOptionScreen: creating intent', {
        'bookingId': bookingId,
        'amount': amount,
        'method': method.name,
        'stripeTypes': types?.join(',') ?? '(null)',
      });

      final result = await PaymentService.instance.createPaymentIntent(
        bookingId: bookingId,
        amount: amount,
        currency: 'eur',
        paymentMethodTypes: types,
      );

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: result.clientSecret,
          merchantDisplayName: 'Travel',
          style: ThemeMode.light,
        ),
      );

      PaymentFlowLog.log('PaymentOptionScreen: presentPaymentSheet');
      await Stripe.instance.presentPaymentSheet();

      await _afterSuccessfulPayment(amount);
    } on StripeException catch (e) {
      final code = e.error.code;
      if (code == FailureCode.Canceled) return;
      ToastHelper.showError(e.error.message ?? 'Payment failed');
    } catch (e) {
      ToastHelper.showError(e.toString());
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Consumer<TripProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                40.h.verticalSpace,
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 27.w,
                    vertical: 30.h,
                  ),
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
                        text: "Payment Options",
                        style: textStyle32Bold.copyWith(
                          fontSize: 26.sp,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 27.w),
                  child: Column(
                    children: [
                      // PaymentOption(
                      //   onSelect: (value) {
                      //     provider.changeSelectedMethod(value);
                      //   },
                      //   value: PaymentMethodEnum.googlePay,
                      //   selectedValue: provider.selectedMethod,
                      // ),
                      // PaymentOption(
                      //   onSelect: (value) {
                      //     provider.changeSelectedMethod(value);
                      //   },
                      //   value: PaymentMethodEnum.applepay,
                      //   selectedValue: provider.selectedMethod,
                      // ),
                      PaymentOption(
                        onSelect: (value) {
                          provider.changeSelectedMethod(value);
                        },
                        value: PaymentMethodEnum.idealpay,
                        selectedValue: provider.selectedMethod,
                      ),
                      PaymentOption(
                        onSelect: (value) {
                          provider.changeSelectedMethod(value);
                        },
                        value: PaymentMethodEnum.cash,
                        selectedValue: provider.selectedMethod,
                      ),
                      PaymentOption(
                        onSelect: (value) {
                          provider.changeSelectedMethod(value);
                        },
                        value: PaymentMethodEnum.creditCard,
                        selectedValue: provider.selectedMethod,
                      ),
                      PaymentOption(
                        onSelect: (value) {
                          provider.changeSelectedMethod(value);
                        },
                        value: PaymentMethodEnum.paypal,
                        selectedValue: provider.selectedMethod,
                      ),
                      24.h.verticalSpace,
                      AppButton(
                        title: 'Confirm & Pay Now',
                        isLoading: _paying,
                        onTap: _paying ? null : _payNow,
                      ),
                      if (_platformPaySupported != null &&
                          _platformPaySupported!) ...[
                        12.h.verticalSpace,
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
                                  provider.changeSelectedMethod(
                                    Platform.isAndroid
                                        ? PaymentMethodEnum.googlePay
                                        : PaymentMethodEnum.applepay,
                                  );
                                  if (_paying) return;
                                  _payWithPlatformPay();
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
