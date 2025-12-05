import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';

enum PaymentMethosEnum {
  googlePay,
  applepay,
  idealpay,
  cash,
  creditCard,
  paypal,
}

extension PaymentMethosExtension on PaymentMethosEnum {
  String getTitle() {
    return switch (this) {
      PaymentMethosEnum.googlePay => "Google Pay",
      PaymentMethosEnum.applepay => "Apple Pay",
      PaymentMethosEnum.idealpay => "iDEAL",
      PaymentMethosEnum.cash => "Cash",
      PaymentMethosEnum.creditCard => "Credit/Debit Cards",
      PaymentMethosEnum.paypal => "PayPal",
    };
  }

  String getIcon() {
    return switch (this) {
      PaymentMethosEnum.googlePay => AppAssets.google,
      PaymentMethosEnum.applepay => AppAssets.apple,
      PaymentMethosEnum.idealpay => AppAssets.ideal,
      PaymentMethosEnum.cash => AppAssets.cash,
      PaymentMethosEnum.creditCard => AppAssets.creditcard,
      PaymentMethosEnum.paypal => AppAssets.paypal,
    };
  }
}
