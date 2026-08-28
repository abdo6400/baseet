import 'package:flutter/material.dart';
import 'responsive_extension.dart';

extension ResponsiveTextExtension on BuildContext {
  TextStyle label(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
    double? letterSpacing,
    String? fontFamily,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontSize: sp(size),
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      fontFamily: fontFamily,
      decoration: decoration,
    );
  }
}
