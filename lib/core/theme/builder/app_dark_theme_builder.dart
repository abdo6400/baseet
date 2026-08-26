import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tokens/app_tokens.dart';
import 'app_input_theme_builder.dart';
import 'app_text_theme_builder.dart';

ThemeData buildAppDarkTheme({String? fontFamily, Locale? locale}) {
  final textTheme = buildAppTextTheme(
    defaultColor: AppDarkSemanticTokens.onBackground,
    fontFamily: fontFamily,
    locale: locale,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: fontFamily ??
        (locale?.languageCode == 'ar'
            ? AppTypographyTokens.arabicFontFamily
            : AppTypographyTokens.englishFontFamily),
    scaffoldBackgroundColor: AppDarkSemanticTokens.background,
    primaryColor: AppDarkSemanticTokens.primary,
    colorScheme: const ColorScheme.dark(
      primary: AppDarkSemanticTokens.primary,
      onPrimary: AppDarkSemanticTokens.onPrimary,
      primaryContainer: AppDarkSemanticTokens.primaryContainer,
      onPrimaryContainer: AppDarkSemanticTokens.onPrimaryContainer,
      secondary: AppDarkSemanticTokens.secondary,
      onSecondary: AppDarkSemanticTokens.onSecondary,
      secondaryContainer: AppDarkSemanticTokens.secondaryContainer,
      onSecondaryContainer: AppDarkSemanticTokens.onSecondaryContainer,
      tertiary: AppDarkSemanticTokens.tertiary,
      onTertiary: AppDarkSemanticTokens.onTertiary,
      surface: AppDarkSemanticTokens.surface,
      onSurface: AppDarkSemanticTokens.onSurface,
      surfaceContainerLowest: AppDarkSemanticTokens.surfaceContainerLowest,
      surfaceContainerLow: AppDarkSemanticTokens.surfaceContainerLow,
      surfaceContainer: AppDarkSemanticTokens.surfaceContainer,
      surfaceContainerHigh: AppDarkSemanticTokens.surfaceContainerHigh,
      surfaceContainerHighest: AppDarkSemanticTokens.surfaceContainerHighest,
      error: AppDarkSemanticTokens.error,
      onError: AppDarkSemanticTokens.onError,
      outline: AppDarkSemanticTokens.borderSecondary,
      outlineVariant: AppDarkSemanticTokens.borderTertiary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppDarkSemanticTokens.surface,
      foregroundColor: AppDarkSemanticTokens.primary,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppDarkSemanticTokens.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppDarkSemanticTokens.borderTertiary, width: 1.0),
      ),
    ),
    inputDecorationTheme: buildAppInputTheme(
      fillColor: AppDarkSemanticTokens.surfaceContainerLowest,
      borderColor: AppDarkSemanticTokens.borderTertiary,
      focusBorderColor: AppDarkSemanticTokens.primary,
      errorBorderColor: AppDarkSemanticTokens.error,
      labelColor: AppDarkSemanticTokens.onSurfaceVariant,
      hintColor: AppPrimitiveTokens.slate500,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppDarkSemanticTokens.primary,
        foregroundColor: AppDarkSemanticTokens.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppDarkSemanticTokens.onSurface,
        side: const BorderSide(color: AppDarkSemanticTokens.borderTertiary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    textTheme: textTheme,
  );
}
