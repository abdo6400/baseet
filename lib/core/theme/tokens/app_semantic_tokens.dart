import 'package:flutter/material.dart';
import 'app_primitive_tokens.dart';

abstract class AppLightSemanticTokens {
  static const Color primary = AppPrimitiveTokens.emerald800;
  static const Color primaryContainer = AppPrimitiveTokens.emerald700;
  static const Color onPrimary = AppPrimitiveTokens.baseWhite;
  static const Color onPrimaryContainer = AppPrimitiveTokens.emerald50;

  static const Color secondary = AppPrimitiveTokens.red800;
  static const Color secondaryContainer = AppPrimitiveTokens.red700;
  static const Color onSecondary = AppPrimitiveTokens.baseWhite;
  static const Color onSecondaryContainer = AppPrimitiveTokens.red50;

  static const Color tertiary = AppPrimitiveTokens.amber700;
  static const Color tertiaryContainer = AppPrimitiveTokens.amber600;
  static const Color onTertiary = AppPrimitiveTokens.baseWhite;

  static const Color background = AppPrimitiveTokens.slate50;
  static const Color onBackground = AppPrimitiveTokens.slate950;

  static const Color surface = AppPrimitiveTokens.baseWhite;
  static const Color onSurface = AppPrimitiveTokens.slate950;
  static const Color onSurfaceVariant = AppPrimitiveTokens.slate700;

  static const Color surfaceContainerLowest = AppPrimitiveTokens.baseWhite;
  static const Color surfaceContainerLow = Color(0xFFEFF4FF);
  static const Color surfaceContainer = Color(0xFFE5EEFF);
  static const Color surfaceContainerHigh = Color(0xFFDCE9FF);
  static const Color surfaceContainerHighest = Color(0xFFD3E4FE);

  static const Color borderPrimary = AppPrimitiveTokens.slate600;
  static const Color borderSecondary = AppPrimitiveTokens.slate300;
  static const Color borderTertiary = AppPrimitiveTokens.slate150;

  static const Color error = AppPrimitiveTokens.red800;
  static const Color onError = AppPrimitiveTokens.baseWhite;
  static const Color errorContainer = AppPrimitiveTokens.red100;

  static const Color success = AppPrimitiveTokens.emerald600;
  static const Color warning = AppPrimitiveTokens.amber500;
}

abstract class AppDarkSemanticTokens {
  static const Color primary = AppPrimitiveTokens.emerald300;
  static const Color primaryContainer = AppPrimitiveTokens.emerald900;
  static const Color onPrimary = AppPrimitiveTokens.emerald950;
  static const Color onPrimaryContainer = AppPrimitiveTokens.emerald50;

  static const Color secondary = AppPrimitiveTokens.red400;
  static const Color secondaryContainer = AppPrimitiveTokens.red900;
  static const Color onSecondary = AppPrimitiveTokens.red950;
  static const Color onSecondaryContainer = AppPrimitiveTokens.red100;

  static const Color tertiary = AppPrimitiveTokens.amber400;
  static const Color tertiaryContainer = AppPrimitiveTokens.amber800;
  static const Color onTertiary = AppPrimitiveTokens.amber900;

  static const Color background = Color(0xFF0F172A);
  static const Color onBackground = Color(0xFFF1F5F9);

  static const Color surface = Color(0xFF1E293B);
  static const Color onSurface = Color(0xFFF1F5F9);
  static const Color onSurfaceVariant = Color(0xFF94A3B8);

  static const Color surfaceContainerLowest = Color(0xFF0F172A);
  static const Color surfaceContainerLow = Color(0xFF1E293B);
  static const Color surfaceContainer = Color(0xFF334155);
  static const Color surfaceContainerHigh = Color(0xFF475569);
  static const Color surfaceContainerHighest = Color(0xFF64748B);

  static const Color borderPrimary = Color(0xFF475569);
  static const Color borderSecondary = Color(0xFF334155);
  static const Color borderTertiary = Color(0xFF1E293B);

  static const Color error = AppPrimitiveTokens.red500;
  static const Color onError = AppPrimitiveTokens.baseWhite;
  static const Color errorContainer = AppPrimitiveTokens.red900;

  static const Color success = AppPrimitiveTokens.emerald400;
  static const Color warning = AppPrimitiveTokens.amber400;
}
