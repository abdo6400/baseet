import 'package:flutter/material.dart';
import '../tokens/app_tokens.dart';

TextTheme buildAppTextTheme({
  required Color defaultColor,
  String? fontFamily,
  Locale? locale,
}) {
  final resolvedFont = fontFamily ??
      (locale?.languageCode == 'ar'
          ? AppTypographyTokens.arabicFontFamily
          : AppTypographyTokens.englishFontFamily);

  return TextTheme(
    displayLarge: TextStyle(
      fontFamily: resolvedFont,
      fontSize: AppTypographyTokens.displayLarge,
      fontWeight: AppTypographyTokens.weightBold,
      color: defaultColor,
      height: AppTypographyTokens.lineDisplayLarge / AppTypographyTokens.displayLarge,
    ),
    displayMedium: TextStyle(
      fontFamily: resolvedFont,
      fontSize: AppTypographyTokens.displayMedium,
      fontWeight: AppTypographyTokens.weightBold,
      color: defaultColor,
      height: AppTypographyTokens.lineDisplayMedium / AppTypographyTokens.displayMedium,
    ),
    displaySmall: TextStyle(
      fontFamily: resolvedFont,
      fontSize: AppTypographyTokens.displaySmall,
      fontWeight: AppTypographyTokens.weightBold,
      color: defaultColor,
      height: AppTypographyTokens.lineDisplaySmall / AppTypographyTokens.displaySmall,
    ),
    headlineLarge: TextStyle(
      fontFamily: resolvedFont,
      fontSize: AppTypographyTokens.headlineLarge,
      fontWeight: AppTypographyTokens.weightBold,
      color: defaultColor,
    ),
    headlineMedium: TextStyle(
      fontFamily: resolvedFont,
      fontSize: AppTypographyTokens.headlineMedium,
      fontWeight: AppTypographyTokens.weightSemibold,
      color: defaultColor,
    ),
    headlineSmall: TextStyle(
      fontFamily: resolvedFont,
      fontSize: AppTypographyTokens.headlineSmall,
      fontWeight: AppTypographyTokens.weightSemibold,
      color: defaultColor,
    ),
    titleLarge: TextStyle(
      fontFamily: resolvedFont,
      fontSize: AppTypographyTokens.titleLarge,
      fontWeight: AppTypographyTokens.weightSemibold,
      color: defaultColor,
    ),
    titleMedium: TextStyle(
      fontFamily: resolvedFont,
      fontSize: AppTypographyTokens.titleMedium,
      fontWeight: AppTypographyTokens.weightMedium,
      color: defaultColor,
    ),
    titleSmall: TextStyle(
      fontFamily: resolvedFont,
      fontSize: AppTypographyTokens.titleSmall,
      fontWeight: AppTypographyTokens.weightMedium,
      color: defaultColor,
    ),
    bodyLarge: TextStyle(
      fontFamily: resolvedFont,
      fontSize: AppTypographyTokens.bodyLarge,
      fontWeight: AppTypographyTokens.weightRegular,
      color: defaultColor,
    ),
    bodyMedium: TextStyle(
      fontFamily: resolvedFont,
      fontSize: AppTypographyTokens.bodyMedium,
      fontWeight: AppTypographyTokens.weightRegular,
      color: defaultColor,
    ),
    bodySmall: TextStyle(
      fontFamily: resolvedFont,
      fontSize: AppTypographyTokens.bodySmall,
      fontWeight: AppTypographyTokens.weightRegular,
      color: defaultColor,
    ),
    labelLarge: TextStyle(
      fontFamily: resolvedFont,
      fontSize: AppTypographyTokens.labelLarge,
      fontWeight: AppTypographyTokens.weightMedium,
      color: defaultColor,
    ),
    labelMedium: TextStyle(
      fontFamily: resolvedFont,
      fontSize: AppTypographyTokens.labelMedium,
      fontWeight: AppTypographyTokens.weightMedium,
      color: defaultColor,
    ),
    labelSmall: TextStyle(
      fontFamily: resolvedFont,
      fontSize: AppTypographyTokens.labelSmall,
      fontWeight: AppTypographyTokens.weightMedium,
      color: defaultColor,
    ),
  );
}
