import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';

enum PaymentMethodEnum {
  googlePay,
  applepay,
  idealpay,
  cash,
  creditCard,
  paypal,
}

extension PaymentMethodStripeX on PaymentMethodEnum {
  /// Cash is handled offline (no Stripe PaymentIntent).
  bool get isOfflineCash => this == PaymentMethodEnum.cash;

  /// Sent as `paymentMethodTypes` on `POST /api/payment/create-payment-intent`.
  ///
  /// **Card / wallets:** use `['card']` only. Google Pay and Apple Pay run on the card
  /// network in Stripe; if we use `null`, the backend enables *automatic* methods and
  /// the Payment Sheet may show Link, Amazon Pay, etc. — not only your radio choice.
  List<String>? get stripePaymentMethodTypes {
    switch (this) {
      case PaymentMethodEnum.idealpay:
        return ['ideal'];
      case PaymentMethodEnum.paypal:
        return ['paypal'];
      case PaymentMethodEnum.cash:
        return null;
      case PaymentMethodEnum.googlePay:
      case PaymentMethodEnum.applepay:
      case PaymentMethodEnum.creditCard:
        return ['card'];
    }
  }
}

extension PaymentMethosExtension on PaymentMethodEnum {
  String getTitle() {
    return switch (this) {
      PaymentMethodEnum.googlePay => "Google Pay",
      PaymentMethodEnum.applepay => "Apple Pay",
      PaymentMethodEnum.idealpay => "iDEAL",
      PaymentMethodEnum.cash => "Cash",
      PaymentMethodEnum.creditCard => "Credit/Debit Cards",
      PaymentMethodEnum.paypal => "PayPal",
    };
  }

  String getIcon() {
    return switch (this) {
      PaymentMethodEnum.googlePay => AppAssets.google,
      PaymentMethodEnum.applepay => AppAssets.apple,
      PaymentMethodEnum.idealpay => AppAssets.ideal,
      PaymentMethodEnum.cash => AppAssets.cash,
      PaymentMethodEnum.creditCard => AppAssets.creditcard,
      PaymentMethodEnum.paypal => AppAssets.paypal,
    };
  }
}
