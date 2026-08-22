import 'package:flutter/material.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';

class AppText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final TextDecoration? textDecoration;
  final int? maxLines;

  const AppText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.textDecoration,
    this.overflow,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        style?.color ?? Theme.of(context).colorScheme.onSurface;
    return Text(
      text,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      style: (style ?? textStyle14Regular).copyWith(
        color: effectiveColor,
        decoration: textDecoration,
      ),
    );
  }
}

