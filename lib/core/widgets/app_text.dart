import 'package:flutter/cupertino.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';

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
    return Text(
      text,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      style: style != null
          ? style!.copyWith(decoration: textDecoration)
          : textStyle14Regular.copyWith(),
    );
  }
}