import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/enums/payment_option_enum.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_button.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text_filed.dart';
import 'package:trael_app_abdelhamid/core/widgets/payment_option_card.dart';
import 'package:trael_app_abdelhamid/provider/home/home_provider.dart';
import 'package:trael_app_abdelhamid/routes/user_routes.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';


class PaymentOptionScreen extends StatefulWidget {
  const PaymentOptionScreen({super.key});

  @override
  State<PaymentOptionScreen> createState() => _PaymentOptionScreenState();
}

class _PaymentOptionScreenState extends State<PaymentOptionScreen> {
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
                      PaymentOption(
                        onSelect: (value) {
                          provider.changeSelectedMethod(value);
                        },
                        value: PaymentMethosEnum.googlePay,
                        selectedValue: provider.selectedMethod,
                      ),
                      PaymentOption(
                        onSelect: (value) {
                          provider.changeSelectedMethod(value);
                        },
                        value: PaymentMethosEnum.applepay,
                        selectedValue: provider.selectedMethod,
                      ),
                      PaymentOption(
                        onSelect: (value) {
                          provider.changeSelectedMethod(value);
                        },
                        value: PaymentMethosEnum.idealpay,
                        selectedValue: provider.selectedMethod,
                      ),
                      PaymentOption(
                        onSelect: (value) {
                          provider.changeSelectedMethod(value);
                        },
                        value: PaymentMethosEnum.cash,
                        selectedValue: provider.selectedMethod,
                      ),
                      PaymentOption(
                        onSelect: (value) {
                          provider.changeSelectedMethod(value);
                        },
                        value: PaymentMethosEnum.creditCard,
                        selectedValue: provider.selectedMethod,
                      ),
                      PaymentOption(
                        onSelect: (value) {
                          provider.changeSelectedMethod(value);
                        },
                        value: PaymentMethosEnum.paypal,
                        selectedValue: provider.selectedMethod,
                      ),
                      if (provider.selectedMethod ==
                          PaymentMethosEnum.creditCard)
                        _cardDetailsSection(),
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

  Widget _cardDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        42.h.verticalSpace,
        AppTextField(
          prefixIcon: Padding(
            padding: const EdgeInsets.all(13.0),
            child: SvgIcon(
              AppAssets.creditcard,
              color: AppColors.primaryColor.setOpacity(0.6),
            ),
          ),
          labelText: "Card number",
          hintText: "0000 0000 0000",
        ),

        15.h.verticalSpace,

        Row(
          children: [
            Expanded(
              child: AppTextField(labelText: "CVC", hintText: "CVV"),
            ),

            10.w.horizontalSpace,

            // CVV
            Expanded(
              child: AppTextField(labelText: "Expiry date", hintText: "MM/YY"),
            ),
          ],
        ),
        42.h.verticalSpace,
        AppButton(
          title: "Confirm & Pay Now",
          onTap: () {
            context.pushNamed(UserAppRoutes.paymentSuccessfullScreen.name);
          },
        ),
        42.h.verticalSpace,
      ],
    );
  }
}
