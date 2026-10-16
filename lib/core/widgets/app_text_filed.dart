import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';

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
    this.fieldKey,
    this.borderOpacity = 0.18,
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
  final GlobalKey<FormFieldState<String>>? fieldKey;
  final double borderOpacity;

  bool _looksLikeHint(String value) {
    final lower = value.toLowerCase();
    return lower.startsWith('enter') ||
        lower.startsWith('select') ||
        lower.startsWith('write') ||
        lower.startsWith('type');
  }

  @override
  Widget build(BuildContext context) {
    final InputBorder normalBorder =
        border ??
        outlineInputBorder ??
        OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8.r),
        );
    final Color errorLineColor =
        errorBorder?.borderSide.color ?? Theme.of(context).colorScheme.error;

    final rawLabel = labelText?.trim() ?? '';
    final rawHint = hintText?.trim() ?? '';

    // Label above the field. If only a field name was passed as hintText, use it as label.
    String fieldLabel = rawLabel;
    String? fieldHint = rawHint.isEmpty ? null : rawHint;
    if (fieldLabel.isEmpty && rawHint.isNotEmpty && !_looksLikeHint(rawHint)) {
      fieldLabel = rawHint;
      fieldHint = null;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (fieldLabel.isNotEmpty) ...[
          RichText(
            text: TextSpan(
              text: fieldLabel,
              style:
                  labelStyle ??
                  textStyle14Regular.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              children: [
                if (isRequired)
                  TextSpan(
                    text: ' *',
                    style: textStyle14Regular.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
        ],
        FormField<String>(
          key: fieldKey,
          initialValue: controller?.text,
          validator: (value) {
            if (validator == null) {
              return null;
            }
            return validator!(controller?.text ?? value);
          },
          autovalidateMode: autoValidateMode,
          builder: (field) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: field.hasError
                          ? errorLineColor
                          : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: borderOpacity),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.shadow.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    enabled: enabled ?? true,
                    readOnly: readOnly,
                    maxLength: maxLength,
                    keyboardType: keyboardType,
                    inputFormatters: inputFormatters,
                    controller: controller,
                    obscureText: obSecureText ?? false,
                    cursorColor: Theme.of(context).colorScheme.primary,
                    showCursor: !readOnly,
                    style: textStyle14Regular.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
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
                      hintText: fieldHint,
                      hintStyle:
                          hintStyle ??
                          textStyle14Regular.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.45),
                          ),
                      contentPadding:
                          contentPadding ??
                          EdgeInsets.symmetric(
                            horizontal: 22.w,
                            vertical: 17.h,
                          ),
                      border: InputBorder.none,
                      enabledBorder: normalBorder,
                      focusedBorder: normalBorder,
                      disabledBorder: normalBorder,
                    ),
                    onChanged: (value) {
                      if (onChanged != null) {
                        onChanged!(value);
                      }
                      field.didChange(controller?.text ?? value);
                    },
                    maxLines: maxLines ?? 1,
                  ),
                ),
                if (field.errorText != null) ...[
                  SizedBox(height: 6.h),
                  Text(
                    field.errorText!,
                    style: textStyle14Regular.copyWith(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        if (bottomText != null) ...[
          SizedBox(height: 4.h),
          Text(
            bottomText!,
            style:
                bottomTextStyle ??
                textStyle14Regular.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12.sp,
                ),
          ),
        ],
      ],
    );
  }
}
