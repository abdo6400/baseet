import 'package:flutter/material.dart';
import '../tokens/app_tokens.dart';

InputDecorationTheme buildAppInputTheme({
  required Color fillColor,
  required Color borderColor,
  required Color focusBorderColor,
  required Color errorBorderColor,
  required Color labelColor,
  required Color hintColor,
}) {
  final baseBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.lg),
    borderSide: BorderSide(color: borderColor, width: 1.0),
  );

  return InputDecorationTheme(
    filled: true,
    fillColor: fillColor,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    labelStyle: TextStyle(color: labelColor, fontSize: 14),
    hintStyle: TextStyle(color: hintColor, fontSize: 14),
    border: baseBorder,
    enabledBorder: baseBorder,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: BorderSide(color: focusBorderColor, width: 2.0),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: BorderSide(color: errorBorderColor, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: BorderSide(color: errorBorderColor, width: 2.0),
    ),
  );
}
