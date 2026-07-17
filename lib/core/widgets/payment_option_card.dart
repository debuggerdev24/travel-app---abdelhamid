import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/enums/payment_option_enum.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';

class PaymentOption extends StatelessWidget {
  final PaymentMethodEnum value;
  final PaymentMethodEnum selectedValue;
  final Function(PaymentMethodEnum) onSelect;

  const PaymentOption({
    super.key,
    required this.onSelect,
    required this.value,
    required this.selectedValue,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelect(value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              value.getIcon(),
              width: 24.w,
              height: 24.w,
              colorFilter: value == PaymentMethodEnum.googlePay || value == PaymentMethodEnum.paypal || value == PaymentMethodEnum.idealpay
                  ? null // Keep original colors for these logos if possible
                  : ColorFilter.mode(
                      Theme.of(context).colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
            ),
            12.w.horizontalSpace,
            AppText(
              text: value.getTitle(),
              style: textStyle14Medium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Spacer(),
            Radio<PaymentMethodEnum>(
              side: BorderSide(
                width: 1,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              activeColor: Theme.of(context).colorScheme.primary,
              value: value,
              groupValue: selectedValue,
              onChanged: (val) {
                if (val != null) {
                  onSelect(val);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
