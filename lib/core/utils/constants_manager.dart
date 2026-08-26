import 'package:flutter/material.dart';

abstract class ConstantsManager {
  static const String arabicLocale = 'ar';
  static const String englishLocale = 'en';

  static const List<Locale> supportedLocales = [
    Locale(arabicLocale),
    Locale(englishLocale),
  ];

  static final GlobalKey<ScaffoldMessengerState> snackBarKey =
      GlobalKey<ScaffoldMessengerState>();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();
}
