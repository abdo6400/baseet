import 'package:flutter/material.dart';

abstract class AppTypographyTokens {
  static const String arabicFontFamily = 'IBM Plex Sans Arabic';
  static const String englishFontFamily = 'Inter';

  // Weights
  static const FontWeight weightRegular = FontWeight.w400;
  static const FontWeight weightMedium = FontWeight.w500;
  static const FontWeight weightSemibold = FontWeight.w600;
  static const FontWeight weightBold = FontWeight.w700;

  // Font Sizes
  static const double displayLarge = 32.0;
  static const double displayMedium = 28.0;
  static const double displaySmall = 24.0;

  static const double headlineLarge = 22.0;
  static const double headlineMedium = 20.0;
  static const double headlineSmall = 18.0;

  static const double titleLarge = 17.0;
  static const double titleMedium = 16.0;
  static const double titleSmall = 15.0;

  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;

  static const double labelLarge = 14.0;
  static const double labelMedium = 12.0;
  static const double labelSmall = 10.0;

  // Line Heights
  static const double lineDisplayLarge = 40.0;
  static const double lineDisplayMedium = 36.0;
  static const double lineDisplaySmall = 32.0;

  static const double lineHeadlineLarge = 28.0;
  static const double lineHeadlineMedium = 26.0;
  static const double lineHeadlineSmall = 24.0;

  static const double lineBodyLarge = 24.0;
  static const double lineBodyMedium = 20.0;
  static const double lineBodySmall = 16.0;
}
