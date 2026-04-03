import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';

enum PaymentMethodEnum {
  googlePay,
  applepay,
  idealpay,
  cash,
  creditCard,
  paypal,
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
