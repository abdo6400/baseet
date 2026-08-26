import 'package:flutter/material.dart';

extension ResponsiveTextExtension on BuildContext {
  TextStyle label(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    );
  }
}
