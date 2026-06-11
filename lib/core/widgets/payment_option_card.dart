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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 2.h),
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            value.getIcon(),
            colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.onSurface,
              BlendMode.srcIn,
            ),
          ),
          10.w.horizontalSpace,
          AppText(
            text: value.getTitle(),
            style: textStyle14Regular.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Spacer(),
          Radio<PaymentMethodEnum>(
            side: BorderSide(
              width: 0.7,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            innerRadius: WidgetStatePropertyAll(6),
            activeColor: Theme.of(context).colorScheme.primary,
            value: value,
            groupValue: selectedValue,
            onChanged: (value) {
              {
                if (value != null) {
                  onSelect(value);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
