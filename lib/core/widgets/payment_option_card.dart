import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/enums/payment_option_enum.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';


class PaymentOption extends StatelessWidget {
  final PaymentMethosEnum value;
  final PaymentMethosEnum selectedValue;
  final Function(PaymentMethosEnum) onSelect;

  const PaymentOption({
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
        border: Border.all(color: AppColors.primaryColor.setOpacity(0.2)),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          SvgPicture.asset(value.getIcon()),
          10.w.horizontalSpace,
          AppText(
            text: value.getTitle(),
            style: textStyle14Regular.copyWith(color: AppColors.primaryColor),
          ),
          Spacer(),
          Radio<PaymentMethosEnum>(
            side: BorderSide(
              width: 0.7,
              color: AppColors.primaryColor.setOpacity(0.5),
            ),
            innerRadius: WidgetStatePropertyAll(6),
            activeColor: AppColors.blueColor,
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
