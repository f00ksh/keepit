// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:keepit/core/theme/text_styles.dart';

/// A consistent text component with semantic meaning
class StyledText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool strong;
  final bool medium;
  final bool light;

  const StyledText.title(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.strong = false,
    this.medium = false,
    this.light = false,
  }) : style = null;

  const StyledText.body(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.strong = false,
    this.medium = false,
    this.light = false,
  }) : style = null;

  const StyledText.label(
    this.text, {
    super.key,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.strong = false,
    this.medium = false,
    this.light = false,
  }) : style = null;

  const StyledText(
    this.text, {
    super.key,
    required this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.strong = false,
    this.medium = false,
    this.light = false,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle;

    if (runtimeType == StyledText.title) {
      textStyle = context.textTheme.titleMedium!;
    } else if (runtimeType == StyledText.body) {
      textStyle = context.textTheme.bodyMedium!;
    } else if (runtimeType == StyledText.label) {
      textStyle = context.textTheme.labelMedium!;
    } else {
      textStyle = style ?? context.textTheme.bodyMedium!;
    }

    if (strong || medium || light) {
      textStyle = context.emphasize(
        textStyle,
        strong: strong,
        medium: medium,
        light: light,
      );
    }

    return Text(
      text,
      style: textStyle,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}
