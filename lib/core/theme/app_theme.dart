import 'package:flutter/material.dart';
import 'builder/app_dark_theme_builder.dart';
import 'builder/app_light_theme_builder.dart';

export 'builder/app_dark_theme_builder.dart';
export 'builder/app_input_theme_builder.dart';
export 'builder/app_light_theme_builder.dart';
export 'builder/app_text_theme_builder.dart';
export 'tokens/app_tokens.dart';

class AppTheme {
  static ThemeData light([Locale? locale]) => buildLight(locale: locale);
  static ThemeData dark([Locale? locale]) => buildDark(locale: locale);

  static ThemeData buildLight({String? fontFamily, Locale? locale}) {
    return buildAppLightTheme(fontFamily: fontFamily, locale: locale);
  }

  static ThemeData buildDark({String? fontFamily, Locale? locale}) {
    return buildAppDarkTheme(fontFamily: fontFamily, locale: locale);
  }
}
