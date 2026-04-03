import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.labelText = '',
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.hintText,
    this.controller,
    this.autoValidateMode = AutovalidateMode.onUserInteraction,
    this.keyboardType,
    this.inputFormatters,
    this.prefixText,
    this.onTap,
    this.obSecureText,
    this.style,
    this.labelStyle,
    this.border,
    this.contentPadding,
    this.maxLength,
    this.suffix,
    this.prefix,
    this.errorBorder,
    this.maxLines,
    this.outlineInputBorder,
    this.hintStyle,
    this.enabled,
    this.isRequired = false,
    this.bottomText,
    this.bottomTextStyle,
    this.readOnly = false,
  });

  final String? labelText;
  final bool isRequired;
  final Widget? prefixIcon;
  final String? prefixText;
  final Widget? suffixIcon;
  final String? hintText;
  final TextStyle? hintStyle;
  final TextStyle? style;
  final TextStyle? labelStyle;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final Function(String?)? onChanged;
  final void Function()? onTap;
  final AutovalidateMode? autoValidateMode;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool? obSecureText;
  final InputBorder? border;
  final InputBorder? errorBorder;
  final OutlineInputBorder? outlineInputBorder;
  final EdgeInsetsGeometry? contentPadding;
  final int? maxLength;
  final Widget? suffix;
  final Widget? prefix;
  final int? maxLines;
  final bool? enabled;
  final String? bottomText;
  final TextStyle? bottomTextStyle;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final InputBorder normalBorder = border ??
        outlineInputBorder ??
        OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.primaryColor.setOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(8.r),
        );
    final InputBorder invalidBorder = errorBorder ??
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: AppColors.redColor),
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText?.isNotEmpty ?? false)
          Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(46.r),
            ),
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: labelText,
                    style:
                        labelStyle ??
                        textStyle14Medium.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
          )
        else
          const SizedBox.shrink(),
        Container(
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.setOpacity(0.1),
                blurRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            enabled: enabled ?? true,
            expands: false,
            readOnly: readOnly,
            maxLength: maxLength,
            validator: validator,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            controller: controller,
            obscureText: obSecureText ?? false,
            cursorColor: AppColors.primaryColor,
            showCursor: !readOnly,
            style: textStyle14Regular.copyWith(
              color: AppColors.black,
              decoration: TextDecoration.none,
            ),
            onTap: onTap,
            onTapOutside: (event) {
              FocusScope.of(context).unfocus();
            },
            decoration: InputDecoration(
              filled: false,
              prefixIcon: prefixIcon,
              prefixText: prefixText,
              prefixStyle: style,
              suffixIcon: suffixIcon,
              suffix: suffix,
              prefix: prefix,
              hintText: hintText,
              hintStyle: hintStyle ?? textStyle14Regular,
              errorStyle: textStyle14Regular.copyWith(
                color: AppColors.redColor,
                fontSize: 12.sp,
              ),
              contentPadding:
                  contentPadding ??
                  EdgeInsets.symmetric(horizontal: 22.w, vertical: 17.h),
              border: InputBorder.none,
              enabledBorder: normalBorder,
              focusedErrorBorder: invalidBorder,
              focusedBorder: normalBorder,
              disabledBorder: normalBorder,
              errorBorder: invalidBorder,
            ),
            onChanged: onChanged,
            maxLines: maxLines ?? 1,
            autovalidateMode: autoValidateMode,
          ),
        ),
        if (bottomText != null) ...[
          SizedBox(height: 4.h),
          Text(
            bottomText!,
            style: bottomTextStyle ??
                textStyle14Regular.copyWith(
                  color: AppColors.greyColor,
                  fontSize: 12.sp,
                ),
          ),
        ],
      ],
    );
  }
}
