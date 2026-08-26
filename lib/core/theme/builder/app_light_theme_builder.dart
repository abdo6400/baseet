import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tokens/app_tokens.dart';
import 'app_input_theme_builder.dart';
import 'app_text_theme_builder.dart';

ThemeData buildAppLightTheme({String? fontFamily, Locale? locale}) {
  final textTheme = buildAppTextTheme(
    defaultColor: AppLightSemanticTokens.onBackground,
    fontFamily: fontFamily,
    locale: locale,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: fontFamily ??
        (locale?.languageCode == 'ar'
            ? AppTypographyTokens.arabicFontFamily
            : AppTypographyTokens.englishFontFamily),
    scaffoldBackgroundColor: AppLightSemanticTokens.background,
    primaryColor: AppLightSemanticTokens.primary,
    colorScheme: const ColorScheme.light(
      primary: AppLightSemanticTokens.primary,
      onPrimary: AppLightSemanticTokens.onPrimary,
      primaryContainer: AppLightSemanticTokens.primaryContainer,
      onPrimaryContainer: AppLightSemanticTokens.onPrimaryContainer,
      secondary: AppLightSemanticTokens.secondary,
      onSecondary: AppLightSemanticTokens.onSecondary,
      secondaryContainer: AppLightSemanticTokens.secondaryContainer,
      onSecondaryContainer: AppLightSemanticTokens.onSecondaryContainer,
      tertiary: AppLightSemanticTokens.tertiary,
      onTertiary: AppLightSemanticTokens.onTertiary,
      surface: AppLightSemanticTokens.surface,
      onSurface: AppLightSemanticTokens.onSurface,
      surfaceContainerLowest: AppLightSemanticTokens.surfaceContainerLowest,
      surfaceContainerLow: AppLightSemanticTokens.surfaceContainerLow,
      surfaceContainer: AppLightSemanticTokens.surfaceContainer,
      surfaceContainerHigh: AppLightSemanticTokens.surfaceContainerHigh,
      surfaceContainerHighest: AppLightSemanticTokens.surfaceContainerHighest,
      error: AppLightSemanticTokens.error,
      onError: AppLightSemanticTokens.onError,
      outline: AppLightSemanticTokens.borderSecondary,
      outlineVariant: AppLightSemanticTokens.borderTertiary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppLightSemanticTokens.surface,
      foregroundColor: AppLightSemanticTokens.primary,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppLightSemanticTokens.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppLightSemanticTokens.borderTertiary, width: 1.0),
      ),
    ),
    inputDecorationTheme: buildAppInputTheme(
      fillColor: AppLightSemanticTokens.surfaceContainerLowest,
      borderColor: AppLightSemanticTokens.borderTertiary,
      focusBorderColor: AppLightSemanticTokens.primary,
      errorBorderColor: AppLightSemanticTokens.error,
      labelColor: AppLightSemanticTokens.onSurfaceVariant,
      hintColor: AppPrimitiveTokens.slate400,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppLightSemanticTokens.primary,
        foregroundColor: AppLightSemanticTokens.onPrimary,
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
        foregroundColor: AppLightSemanticTokens.onSurface,
        side: const BorderSide(color: AppLightSemanticTokens.borderTertiary),
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
